/*
 * Copyright (c) 2026 Huawei Device Co., Ltd. All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE_HW file.
 */

import MethodCall from '../../../plugin/common/MethodCall';
import MethodChannel, { MethodCallHandler, MethodResult } from '../../../plugin/common/MethodChannel';
import StandardMethodCodec from '../../../plugin/common/StandardMethodCodec';
import Log from '../../../util/Log';
import DartExecutor from '../dart/DartExecutor';
import { common } from '@kit.AbilityKit';

const TAG: string = 'DisplayMetricsChannel';

export default class DisplayMetricsChannel implements MethodCallHandler {
  public channel: MethodChannel;
  public context: common.Context;
  private customDpiActive: boolean = false;
 	private currentUri: string = '';

  onMethodCall(call: MethodCall, result: MethodResult): void {
    let method: string = call.method;
    Log.i(TAG, "Received '" + method + "' message.");
    try {
      // More methods are expected to be added here, hence the switch.
      switch (method) {
        case "updateDpiScale":
          if (this.customDpiActive && this.currentUri) {
            result.success(true);

            Log.i(TAG, "Custom DPI for this page" + this.currentUri);
            break;
          }
          let dpiScaleFactor: number = call.argument('dpiScale');
          Log.i(TAG, "Received dpiScaleFactor '" + dpiScaleFactor + "' message.");
          this.context.eventHub.emit('changeDevicePixelRatio', dpiScaleFactor)
          result.success(true);
          break;
        default:
          result.notImplemented();
          break;
      }
    } catch (error) {
      result.error("error", "UnHandled error: " + JSON.stringify(error), null)
    }
  }

  setCustomDpiActive(active: boolean): void {
    this.customDpiActive = active;
    Log.i(TAG, "setCustomDpiActive: " + active);
  }

  isCustomDpiActive(): boolean {
    return this.customDpiActive;
  }

  setCurrentUri(uri: string): void {
    this.currentUri = uri;
    Log.i(TAG, "setCurrentUri: " + uri);
  }

  getCurrentUri(): string {
    return this.currentUri;
  }
  
  constructor(dartExecutor: DartExecutor, context: common.Context) {
    this.channel = new MethodChannel(dartExecutor, "flutter/displaymetrics", StandardMethodCodec.INSTANCE);
    this.channel.setMethodCallHandler(this);
    this.context = context;
  }
}

