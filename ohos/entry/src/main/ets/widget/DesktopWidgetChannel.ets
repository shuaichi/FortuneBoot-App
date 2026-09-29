import common from '@ohos.app.ability.common';
import { FlutterEngine } from '@ohos/flutter_ohos';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import MethodChannel, {
  MethodCallHandler,
  MethodResult,
} from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import {
  CalendarMonthAnchor,
  DesktopWidgetSnapshot,
  DesktopWidgetStore,
  UpdateFormsResult,
} from './DesktopWidgetStore';

const CHANNEL_NAME: string = 'fortuneboot/ohos_desktop_widget';
const MANUAL_ADD_MESSAGE: string =
  '请长按桌面空白处，选择服务卡片 → 好记 →「统计收支日历」（6×4）';

class AddDesktopResult {
  ok: boolean = false;
  mode: string = 'manual';
  message: string = MANUAL_ADD_MESSAGE;
}

export class DesktopWidgetChannel implements MethodCallHandler {
  private static active: DesktopWidgetChannel | null = null;
  private channel: MethodChannel | null = null;
  private context: common.Context | null = null;
  private updateChain: Promise<number> = Promise.resolve(0);

  static register(engine: FlutterEngine, context: common.Context): DesktopWidgetChannel {
    const bridge = new DesktopWidgetChannel();
    bridge.context = context;
    bridge.channel = new MethodChannel(engine.getDartExecutor(), CHANNEL_NAME);
    bridge.channel.setMethodCallHandler(bridge);
    DesktopWidgetChannel.active = bridge;
    return bridge;
  }

  static notifyMonthChanged(year: number, month: number): void {
    const bridge = DesktopWidgetChannel.active;
    if (bridge === null || bridge.channel === null) {
      return;
    }
    try {
      const payload = new CalendarMonthAnchor();
      payload.year = year;
      payload.month = month;
      bridge.channel.invokeMethod('onCalendarMonthChanged', payload);
    } catch (e) {
      console.error(`DesktopWidgetChannel.notifyMonthChanged failed: ${String(e)}`);
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    const context = this.context;
    if (context === null) {
      result.error('no_context', 'Ability context unavailable', null);
      return;
    }

    if (call.method === 'updateSnapshot') {
      this.handleUpdateSnapshot(context, call, result);
      return;
    }
    if (call.method === 'publishNow') {
      this.updateChain = this.updateChain
        .catch(() => 0)
        .then(() => DesktopWidgetStore.publishToForms(context));
      this.updateChain
        .then((updated: number) => {
          const payload = new UpdateFormsResult();
          payload.updated = updated;
          result.success(payload);
        })
        .catch((e: Object) => {
          result.error('publish_failed', String(e), null);
        });
      return;
    }
    if (call.method === 'getCalendarMonth') {
      DesktopWidgetStore.readCalendarAnchor(context)
        .then((anchor: CalendarMonthAnchor) => {
          result.success(anchor);
        })
        .catch((e: Object) => {
          result.error('get_month_failed', String(e), null);
        });
      return;
    }
    if (call.method === 'getCalendarYear') {
      DesktopWidgetStore.readSnapshot(context)
        .then((snapshot: DesktopWidgetSnapshot) => {
          const payload = new CalendarMonthAnchor();
          payload.year = snapshot.yearViewYear > 0
            ? snapshot.yearViewYear
            : new Date().getFullYear();
          payload.month = 1;
          result.success(payload);
        })
        .catch((e: Object) => {
          result.error('get_year_failed', String(e), null);
        });
      return;
    }
    if (call.method === 'requestAddToDesktop') {
      this.handleRequestAddToDesktop(result);
      return;
    }
    if (call.method === 'isSupported') {
      result.success(true);
      return;
    }
    result.notImplemented();
  }

  private handleUpdateSnapshot(
    context: common.Context,
    call: MethodCall,
    result: MethodResult,
  ): void {
    this.updateChain = this.updateChain
      .catch(() => 0)
      .then(() => DesktopWidgetStore.readSnapshot(context))
      .then((snapshot: DesktopWidgetSnapshot) => {
        this.applyCallArgs(snapshot, call);
        return DesktopWidgetStore.writeSnapshot(context, snapshot)
          .then(() => DesktopWidgetStore.publishToForms(context));
      });
    this.updateChain
      .then((updated: number) => {
        console.info(`DesktopWidgetChannel.updateSnapshot updated=${updated}`);
        const payload = new UpdateFormsResult();
        payload.updated = updated;
        result.success(payload);
      })
      .catch((e: Object) => {
        console.error(`DesktopWidgetChannel.updateSnapshot failed: ${String(e)}`);
        result.error('update_failed', String(e), null);
      });
  }

  private applyCallArgs(snapshot: DesktopWidgetSnapshot, call: MethodCall): void {
    const subtitle = DesktopWidgetChannel.asString(call.argument('subtitle'));
    const hideAmountsRaw: boolean | string | number | null = call.argument('hideAmounts');
    const updatedAt = DesktopWidgetChannel.asString(call.argument('updatedAt'));
    const bookIdValue: number | string | null = call.argument('bookId');
    const monthTitle = DesktopWidgetChannel.asString(call.argument('monthTitle'));
    const weekdays = DesktopWidgetChannel.asString(call.argument('weekdays'));
    const cellsJson = DesktopWidgetChannel.asString(call.argument('cellsJson'));
    const monthIncomeText = DesktopWidgetChannel.asString(call.argument('monthIncomeText'));
    const monthExpenseText = DesktopWidgetChannel.asString(call.argument('monthExpenseText'));
    const netAssetsText = DesktopWidgetChannel.asString(call.argument('netAssetsText'));
    const yearTitle = DesktopWidgetChannel.asString(call.argument('yearTitle'));
    const yearCellsJson = DesktopWidgetChannel.asString(call.argument('yearCellsJson'));
    const yearIncomeText = DesktopWidgetChannel.asString(call.argument('yearIncomeText'));
    const yearExpenseText = DesktopWidgetChannel.asString(call.argument('yearExpenseText'));
    const ordersPacked = DesktopWidgetChannel.asString(call.argument('ordersPacked'));
    const orderSelections = DesktopWidgetChannel.asString(call.argument('orderSelections'));
    const groupIdValue: number | string | null = call.argument('groupId');
    const calendarYearRaw: number | string | null = call.argument('calendarYear');
    const calendarMonthRaw: number | string | null = call.argument('calendarMonth');
    const yearViewYearRaw: number | string | null = call.argument('yearViewYear');
    const defaultOrderIdRaw: number | string | null = call.argument('defaultOrderId');

    if (subtitle !== null) {
      snapshot.subtitle = subtitle;
    }
    if (typeof hideAmountsRaw === 'boolean') {
      snapshot.hideAmounts = hideAmountsRaw;
    } else if (hideAmountsRaw === 'true' || hideAmountsRaw === 1) {
      snapshot.hideAmounts = true;
    } else if (hideAmountsRaw === 'false' || hideAmountsRaw === 0) {
      snapshot.hideAmounts = false;
    }
    if (updatedAt !== null) {
      snapshot.updatedAt = updatedAt;
    }
    if (typeof bookIdValue === 'number') {
      snapshot.bookId = bookIdValue;
    } else if (typeof bookIdValue === 'string') {
      const parsed = Number(bookIdValue);
      if (!Number.isNaN(parsed)) {
        snapshot.bookId = parsed;
      }
    }
    if (typeof groupIdValue === 'number') {
      snapshot.groupId = groupIdValue;
    } else if (typeof groupIdValue === 'string') {
      const parsedGroup = Number(groupIdValue);
      if (!Number.isNaN(parsedGroup)) {
        snapshot.groupId = parsedGroup;
      }
    }
    if (monthTitle !== null) {
      snapshot.monthTitle = monthTitle;
    }
    if (weekdays !== null) {
      snapshot.weekdays = weekdays;
    }
    if (cellsJson !== null) {
      snapshot.cellsJson = cellsJson;
      console.info(`DesktopWidgetChannel.cellsJson len=${cellsJson.length}`);
    }
    if (monthIncomeText !== null) {
      snapshot.monthIncomeText = monthIncomeText;
    }
    if (monthExpenseText !== null) {
      snapshot.monthExpenseText = monthExpenseText;
    }
    if (netAssetsText !== null) {
      snapshot.netAssetsText = netAssetsText;
    }
    if (yearTitle !== null) {
      snapshot.yearTitle = yearTitle;
    }
    if (yearCellsJson !== null) {
      snapshot.yearCellsJson = yearCellsJson;
    }
    if (yearIncomeText !== null) {
      snapshot.yearIncomeText = yearIncomeText;
    }
    if (yearExpenseText !== null) {
      snapshot.yearExpenseText = yearExpenseText;
    }
    if (ordersPacked !== null) {
      snapshot.ordersPacked = ordersPacked;
    }
    if (orderSelections !== null) {
      snapshot.orderSelections = orderSelections;
    }
    const year = DesktopWidgetChannel.asNumber(calendarYearRaw);
    const month = DesktopWidgetChannel.asNumber(calendarMonthRaw);
    const yearView = DesktopWidgetChannel.asNumber(yearViewYearRaw);
    const defaultOrderId = DesktopWidgetChannel.asNumber(defaultOrderIdRaw);
    if (year !== null && year >= 1900 && year <= 2100) {
      snapshot.calendarYear = year;
    }
    if (month !== null && month >= 1 && month <= 12) {
      snapshot.calendarMonth = month;
    }
    if (yearView !== null && yearView >= 1900 && yearView <= 2100) {
      snapshot.yearViewYear = yearView;
    }
    if (defaultOrderId !== null && defaultOrderId > 0) {
      snapshot.defaultOrderId = defaultOrderId;
    }
  }

  private static asNumber(value: number | string | null): number | null {
    if (typeof value === 'number' && !Number.isNaN(value)) {
      return value;
    }
    if (typeof value === 'string') {
      const parsed = Number(value);
      if (!Number.isNaN(parsed)) {
        return parsed;
      }
    }
    return null;
  }

  private static asString(value: Object | string | number | boolean | null): string | null {
    if (value === null) {
      return null;
    }
    if (typeof value === 'string') {
      return value;
    }
    if (typeof value === 'number' || typeof value === 'boolean') {
      return String(value);
    }
    try {
      return String(value);
    } catch (_e) {
      return null;
    }
  }

  private handleRequestAddToDesktop(result: MethodResult): void {
    const payload = new AddDesktopResult();
    payload.ok = false;
    payload.mode = 'manual';
    payload.message = MANUAL_ADD_MESSAGE;
    result.success(payload);
  }
}
