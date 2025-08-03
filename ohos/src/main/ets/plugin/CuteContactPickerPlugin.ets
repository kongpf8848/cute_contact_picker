/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import MethodChannel, {
  MethodCallHandler,
  MethodResult
} from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import { AbilityAware, AbilityPluginBinding, Log } from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';
import { contact } from '@kit.ContactsKit';
import { requestContactPermission } from '../utils/Permissions';
import { HashMap } from '@kit.ArkTS';

const PERMISSION = 'ohos.permission.READ_CONTACTS';
const CHANNEL = "plugins.flutter.io/cute_contact_picker";
const METHOD_CALL_NATIVE = "selectContactNative";
const METHOD_CALL_LIST = "selectContactList";
const TAG = "CuteContactPickerPlugin"


export default class CuteContactPickerPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware {
  private channel: MethodChannel | null = null;
  private context: common.UIAbilityContext | null = null;
  private result: MethodResult | null = null;

  constructor() {
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.context = binding.getAbility().context;
  }

  onDetachedFromAbility(): void {
    this.context = null;
  }

  getUniqueClassName(): string {
    return "CuteContactPickerPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null)
  }

  async onMethodCall(call: MethodCall, result: MethodResult) {
    Log.d(TAG, `onMethodCall，method:${call.method}`);
    this.result = result;
    switch (call.method) {
      case METHOD_CALL_NATIVE:
        this.pickContact();
        break;
      case METHOD_CALL_LIST:
        this.getContactList();
        break;
    }
  }

  private async pickContact() {
    Log.d(TAG, "pickContact 00");
    try {
      const contactData = await contact.selectContacts();
      if (contactData === null || contactData.length <= 0) {
        this.result?.success(null);
        return;
      }
      let map: HashMap<string, ESObject> = new HashMap<string, ESObject>();
      map.set('fullName', contactData[0].name?.fullName || "");
      map.set('phoneNumber', this.formatPhone(contactData[0].phoneNumbers?.[0]?.phoneNumber || ""));
      this.result?.success(map);
    } catch (e) {
      Log.d(TAG, `pickContact error: ${e}`);
      let error = e as Error;
      this.result?.error("-1", error.message, null);
    }
  }

  private async getContactList() {
    Log.d(TAG, "getContactList 00");
    try {
      const hasPermission = await requestContactPermission(this.context!)
      Log.d(TAG, `getContactList hasPermission:${hasPermission}`);
      if (hasPermission) {
        const contacts = await contact.queryContacts(
          this.context!
        );
        let list: Array<HashMap<string, ESObject>> = [];
        contacts.forEach(contactData => {
          let map: HashMap<string, ESObject> = new HashMap<string, ESObject>();
          map.set('fullName', contactData.name?.fullName || "");
          map.set('phoneNumber', this.formatPhone(contactData.phoneNumbers?.[0]?.phoneNumber || ""));
          list.push(map);
        });
        this.result?.success(list);
      } else {
        this.result?.error("-3", "no permission", null);
      }
    } catch (e) {
      Log.d(TAG, `getContactList error: ${e}`);
      let error = e as Error;
      this.result?.error("-2", error.message, null);
    }
  }

  private formatPhone(phone: string): string {
    return phone.replace(/[- ]/g, '');
  }
}