package com.kongpf8848.cute_contact_picker;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.provider.ContactsContract;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

public class CuteContactPickerPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {

  private static final String CHANNEL = "plugins.flutter.io/cute_contact_picker";
  // 跳转原生选择联系人页面
  private static final String METHOD_CALL_NATIVE = "selectContactNative";
  // 获取联系人列表
  private static final String METHOD_CALL_LIST = "selectContactList";
  private Activity activity;
  private ActivityPluginBinding binding;
  private MethodChannel methodChannel;
  private Result result;
  private final String PHONE_BOOK_LABEL = "phonebook_label";
  private final String[] COLUMNS = new String[]{
          ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
          ContactsContract.CommonDataKinds.Phone.NUMBER,
          PHONE_BOOK_LABEL
  };
  private final Uri CONTACT_URI = ContactsContract.CommonDataKinds.Contactables.CONTENT_URI;
  private final int REQUEST_CODE = 1010;
  private static final String TAG = "CuteContactPickerPlugin";

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
    this.methodChannel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (this.methodChannel != null) {
      this.methodChannel.setMethodCallHandler(null);
      this.methodChannel = null;
    }
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }


  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
    this.binding = binding;
    binding.addActivityResultListener(this);
  }

  @Override
  public void onDetachedFromActivity() {
    activity = null;
    if (binding != null) {
      binding.removeActivityResultListener(this);
      binding = null;
    }
  }


  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    this.result = result;
    if (call.method.equals(METHOD_CALL_NATIVE)) {
      intentToContact();
    } else if (call.method.equals(METHOD_CALL_LIST)) {
      result.success(getContacts(CONTACT_URI));
    }
  }

  /**
   * 跳转到联系人界面.
   */
  private void intentToContact() {
    Intent intent = new Intent(Intent.ACTION_PICK);
    intent.addCategory(Intent.CATEGORY_DEFAULT);
    intent.setType(ContactsContract.CommonDataKinds.Phone.CONTENT_TYPE);
    activity.startActivityForResult(intent, REQUEST_CODE);
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    if (requestCode == REQUEST_CODE && resultCode == Activity.RESULT_OK) {
      Uri uri = data.getData();
      Log.d(TAG, "onActivityResult() called with: requestCode = [" + requestCode + "], resultCode = [" + resultCode + "], uri = [" + uri + "]");
      List<Map<String, String>> list = getContacts(uri);
      if (list.size() > 0) {
        result.success(list.get(0));
      } else {
        result.success(null);
      }
    }
    return false;
  }

  private List<Map<String, String>> getContacts(Uri uri) {
    List<Map<String, String>> contacts = new ArrayList<>();
    Cursor cursor = activity.getContentResolver().query(uri, COLUMNS, null, null, ContactsContract.CommonDataKinds.Phone.SORT_KEY_PRIMARY);
    if (cursor != null) {
      while (cursor.moveToNext()) {
        Map<String, String> map = new HashMap<>();
        String fullName = cursor.getString(Math.max(0, cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)));
        String phoneNumber = cursor.getString(Math.max(0, cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)));
        String firstLetter = cursor.getString(Math.max(0, cursor.getColumnIndex(PHONE_BOOK_LABEL)));
        if (!TextUtils.isEmpty(phoneNumber)) {
          phoneNumber = phoneNumber.replaceAll("[-\\s]", "");
        }
        map.put("fullName", fullName);
        map.put("phoneNumber", phoneNumber);
        map.put("firstLetter", firstLetter);
        contacts.add(map);
      }
      cursor.close();
    }
    return contacts;

  }
}
