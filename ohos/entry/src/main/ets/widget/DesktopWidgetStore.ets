import dataPreferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import formBindingData from '@ohos.app.form.formBindingData';
import formInfo from '@ohos.app.form.formInfo';
import formProvider from '@ohos.app.form.formProvider';
import Want from '@ohos.app.ability.Want';

const PREFERENCES_NAME: string = 'fortuneboot_desktop_widget';
const FORM_IDS_KEY: string = 'formIds';
const KEY_SUBTITLE: string = 'subtitle';
const KEY_HIDE: string = 'hideAmounts';
const KEY_UPDATED: string = 'updatedAt';
const KEY_BOOK: string = 'bookId';
const KEY_MONTH_TITLE: string = 'monthTitle';
const KEY_WEEKDAYS: string = 'weekdays';
const KEY_CELLS_JSON: string = 'cellsJson';
const KEY_MONTH_INCOME: string = 'monthIncomeText';
const KEY_MONTH_EXPENSE: string = 'monthExpenseText';
const KEY_NET_ASSETS: string = 'netAssetsText';
const KEY_GROUP: string = 'groupId';
const KEY_CAL_YEAR: string = 'calendarYear';
const KEY_CAL_MONTH: string = 'calendarMonth';
const KEY_YEAR_TITLE: string = 'yearTitle';
const KEY_YEAR_CELLS: string = 'yearCellsJson';
const KEY_YEAR_INCOME: string = 'yearIncomeText';
const KEY_YEAR_EXPENSE: string = 'yearExpenseText';
const KEY_YEAR_VIEW: string = 'yearViewYear';
const KEY_ORDERS_PACKED: string = 'ordersPacked';
const KEY_ORDER_SELECTIONS: string = 'orderSelections';
const KEY_DEFAULT_ORDER_ID: string = 'defaultOrderId';
const FORM_NAMES_KEY: string = 'formNames';

export const FORM_NAME_DAY: string = 'income_expense_calendar_card';
export const FORM_NAME_STATS_DAY: string = 'stats_income_expense_calendar_card';
export const FORM_NAME_MONTH: string = 'month_income_expense_calendar_card';
export const FORM_NAME_ORDER: string = 'reimbursement_order_card';

export class DesktopWidgetSnapshot {
  subtitle: string = '翻月自动同步';
  hideAmounts: boolean = false;
  updatedAt: string = '';
  bookId: number = 0;
  groupId: number = 0;
  monthTitle: string = '日收支日历';
  weekdays: string = '一二三四五六日';
  cellsJson: string = '';
  monthIncomeText: string = '—';
  monthExpenseText: string = '—';
  netAssetsText: string = '—';
  calendarYear: number = 0;
  calendarMonth: number = 0;
  yearTitle: string = '月收支日历';
  yearCellsJson: string = '';
  yearIncomeText: string = '—';
  yearExpenseText: string = '—';
  yearViewYear: number = 0;
  ordersPacked: string = '';
  orderSelections: string = '';
  defaultOrderId: number = 0;
}

export class CalendarMonthAnchor {
  year: number = 0;
  month: number = 0;
}

export class UpdateFormsResult {
  updated: number = 0;
}

export class DesktopWidgetStore {
  static currentMonthPacked(now: Date = new Date()): string {
    return DesktopWidgetStore.monthPacked(now.getFullYear(), now.getMonth() + 1, now);
  }

  static monthPacked(year: number, month: number, now: Date = new Date()): string {
    const mm = month < 10 ? `0${month}` : `${month}`;
    const isCurrent = now.getFullYear() === year && (now.getMonth() + 1) === month;
    const todayDay = isCurrent ? now.getDate() : 0;
    return `${year}-${mm}|${todayDay}|`;
  }

  static currentMonthTitle(now: Date = new Date()): string {
    return DesktopWidgetStore.monthTitle(now.getFullYear(), now.getMonth() + 1);
  }

  static monthTitle(year: number, month: number): string {
    return `${year}年${month}月`;
  }

  static yearTitleOf(year: number): string {
    return `${year}年`;
  }

  static yearPacked(year: number, now: Date = new Date()): string {
    const currentMonth = (now.getFullYear() === year) ? (now.getMonth() + 1) : 0;
    return `${year}|${currentMonth}|`;
  }

  static createDefaultSnapshot(): DesktopWidgetSnapshot {
    const snapshot = new DesktopWidgetSnapshot();
    const now = new Date();
    snapshot.calendarYear = now.getFullYear();
    snapshot.calendarMonth = now.getMonth() + 1;
    snapshot.monthTitle = DesktopWidgetStore.monthTitle(snapshot.calendarYear, snapshot.calendarMonth);
    snapshot.cellsJson = DesktopWidgetStore.monthPacked(snapshot.calendarYear, snapshot.calendarMonth, now);
    snapshot.yearViewYear = now.getFullYear();
    snapshot.yearTitle = DesktopWidgetStore.yearTitleOf(snapshot.yearViewYear);
    snapshot.yearCellsJson = DesktopWidgetStore.yearPacked(snapshot.yearViewYear, now);
    return snapshot;
  }

  static applyMonthSkeleton(snapshot: DesktopWidgetSnapshot, year: number, month: number): void {
    snapshot.calendarYear = year;
    snapshot.calendarMonth = month;
    snapshot.monthTitle = DesktopWidgetStore.monthTitle(year, month);
    snapshot.cellsJson = DesktopWidgetStore.monthPacked(year, month);
    snapshot.monthIncomeText = '—';
    snapshot.monthExpenseText = '—';
    snapshot.updatedAt = '';
    snapshot.subtitle = '翻月自动同步';
  }

  static applyYearSkeleton(snapshot: DesktopWidgetSnapshot, year: number): void {
    snapshot.yearViewYear = year;
    snapshot.yearTitle = DesktopWidgetStore.yearTitleOf(year);
    snapshot.yearCellsJson = DesktopWidgetStore.yearPacked(year);
    snapshot.yearIncomeText = '—';
    snapshot.yearExpenseText = '—';
    snapshot.updatedAt = '';
    snapshot.subtitle = '翻年自动同步';
  }

  private static resolveContext(context: common.Context): common.Context {
    try {
      const appContext = context.getApplicationContext();
      if (appContext) {
        return appContext;
      }
    } catch (_e) {
      // ignore
    }
    return context;
  }

  static async ensure(context: common.Context): Promise<dataPreferences.Preferences> {
    const resolved = DesktopWidgetStore.resolveContext(context);
    try {
      await dataPreferences.removePreferencesFromCache(resolved, PREFERENCES_NAME);
    } catch (_e) {
      // ignore cache miss
    }
    return await dataPreferences.getPreferences(resolved, PREFERENCES_NAME);
  }

  static async readSnapshot(context: common.Context): Promise<DesktopWidgetSnapshot> {
    const prefs = await DesktopWidgetStore.ensure(context);
    const snapshot = DesktopWidgetStore.createDefaultSnapshot();

    DesktopWidgetStore.applyString(snapshot, 'subtitle', await prefs.get(KEY_SUBTITLE, snapshot.subtitle));
    DesktopWidgetStore.applyString(snapshot, 'updatedAt', await prefs.get(KEY_UPDATED, snapshot.updatedAt));
    DesktopWidgetStore.applyString(snapshot, 'monthTitle', await prefs.get(KEY_MONTH_TITLE, snapshot.monthTitle));
    DesktopWidgetStore.applyString(snapshot, 'weekdays', await prefs.get(KEY_WEEKDAYS, snapshot.weekdays));
    DesktopWidgetStore.applyString(snapshot, 'cellsJson', await prefs.get(KEY_CELLS_JSON, snapshot.cellsJson));
    DesktopWidgetStore.applyString(snapshot, 'monthIncomeText', await prefs.get(KEY_MONTH_INCOME, snapshot.monthIncomeText));
    DesktopWidgetStore.applyString(snapshot, 'monthExpenseText', await prefs.get(KEY_MONTH_EXPENSE, snapshot.monthExpenseText));
    DesktopWidgetStore.applyString(snapshot, 'netAssetsText', await prefs.get(KEY_NET_ASSETS, snapshot.netAssetsText));
    DesktopWidgetStore.applyString(snapshot, 'yearTitle', await prefs.get(KEY_YEAR_TITLE, snapshot.yearTitle));
    DesktopWidgetStore.applyString(snapshot, 'yearCellsJson', await prefs.get(KEY_YEAR_CELLS, snapshot.yearCellsJson));
    DesktopWidgetStore.applyString(snapshot, 'yearIncomeText', await prefs.get(KEY_YEAR_INCOME, snapshot.yearIncomeText));
    DesktopWidgetStore.applyString(snapshot, 'yearExpenseText', await prefs.get(KEY_YEAR_EXPENSE, snapshot.yearExpenseText));
    DesktopWidgetStore.applyString(snapshot, 'ordersPacked', await prefs.get(KEY_ORDERS_PACKED, snapshot.ordersPacked));
    DesktopWidgetStore.applyString(snapshot, 'orderSelections', await prefs.get(KEY_ORDER_SELECTIONS, snapshot.orderSelections));

    const hideAmounts = await prefs.get(KEY_HIDE, snapshot.hideAmounts);
    if (typeof hideAmounts === 'boolean') {
      snapshot.hideAmounts = hideAmounts;
    }
    const bookId = await prefs.get(KEY_BOOK, snapshot.bookId);
    if (typeof bookId === 'number') {
      snapshot.bookId = bookId;
    }
    const groupId = await prefs.get(KEY_GROUP, snapshot.groupId);
    if (typeof groupId === 'number') {
      snapshot.groupId = groupId;
    }
    const year = await prefs.get(KEY_CAL_YEAR, snapshot.calendarYear);
    if (typeof year === 'number' && year >= 1900 && year <= 2100) {
      snapshot.calendarYear = year;
    }
    const month = await prefs.get(KEY_CAL_MONTH, snapshot.calendarMonth);
    if (typeof month === 'number' && month >= 1 && month <= 12) {
      snapshot.calendarMonth = month;
    }
    const yearView = await prefs.get(KEY_YEAR_VIEW, snapshot.yearViewYear);
    if (typeof yearView === 'number' && yearView >= 1900 && yearView <= 2100) {
      snapshot.yearViewYear = yearView;
    }
    const defaultOrderId = await prefs.get(KEY_DEFAULT_ORDER_ID, snapshot.defaultOrderId);
    if (typeof defaultOrderId === 'number') {
      snapshot.defaultOrderId = defaultOrderId;
    }
    return snapshot;
  }

  private static applyString(
    snapshot: DesktopWidgetSnapshot,
    key: string,
    value: dataPreferences.ValueType,
  ): void {
    if (typeof value !== 'string') {
      return;
    }
    if (key === 'subtitle') {
      snapshot.subtitle = value;
    } else if (key === 'updatedAt') {
      snapshot.updatedAt = value;
    } else if (key === 'monthTitle' && value.length > 0) {
      snapshot.monthTitle = value;
    } else if (key === 'weekdays' && value.length > 0) {
      snapshot.weekdays = value;
    } else if (key === 'cellsJson' && value.length > 0 && value !== '[]') {
      snapshot.cellsJson = value;
    } else if (key === 'monthIncomeText' && value.length > 0) {
      snapshot.monthIncomeText = value;
    } else if (key === 'monthExpenseText' && value.length > 0) {
      snapshot.monthExpenseText = value;
    } else if (key === 'netAssetsText' && value.length > 0) {
      snapshot.netAssetsText = value;
    } else if (key === 'yearTitle' && value.length > 0) {
      snapshot.yearTitle = value;
    } else if (key === 'yearCellsJson' && value.length > 0 && value !== '[]') {
      snapshot.yearCellsJson = value;
    } else if (key === 'yearIncomeText' && value.length > 0) {
      snapshot.yearIncomeText = value;
    } else if (key === 'yearExpenseText' && value.length > 0) {
      snapshot.yearExpenseText = value;
    } else if (key === 'ordersPacked') {
      snapshot.ordersPacked = value;
    } else if (key === 'orderSelections') {
      snapshot.orderSelections = value;
    }
  }

  static async writeSnapshot(
    context: common.Context,
    snapshot: DesktopWidgetSnapshot,
  ): Promise<void> {
    const prefs = await DesktopWidgetStore.ensure(context);
    await prefs.put(KEY_SUBTITLE, snapshot.subtitle);
    await prefs.put(KEY_HIDE, snapshot.hideAmounts);
    await prefs.put(KEY_UPDATED, snapshot.updatedAt);
    await prefs.put(KEY_BOOK, snapshot.bookId);
    await prefs.put(KEY_GROUP, snapshot.groupId);
    await prefs.put(KEY_MONTH_TITLE, snapshot.monthTitle);
    await prefs.put(KEY_WEEKDAYS, snapshot.weekdays);
    await prefs.put(KEY_CELLS_JSON, snapshot.cellsJson);
    await prefs.put(KEY_MONTH_INCOME, snapshot.monthIncomeText);
    await prefs.put(KEY_MONTH_EXPENSE, snapshot.monthExpenseText);
    await prefs.put(KEY_NET_ASSETS, snapshot.netAssetsText);
    await prefs.put(KEY_YEAR_TITLE, snapshot.yearTitle);
    await prefs.put(KEY_YEAR_CELLS, snapshot.yearCellsJson);
    await prefs.put(KEY_YEAR_INCOME, snapshot.yearIncomeText);
    await prefs.put(KEY_YEAR_EXPENSE, snapshot.yearExpenseText);
    await prefs.put(KEY_ORDERS_PACKED, snapshot.ordersPacked);
    await prefs.put(KEY_ORDER_SELECTIONS, snapshot.orderSelections);
    await prefs.put(KEY_DEFAULT_ORDER_ID, snapshot.defaultOrderId);
    if (snapshot.calendarYear >= 1900 && snapshot.calendarYear <= 2100) {
      await prefs.put(KEY_CAL_YEAR, snapshot.calendarYear);
    }
    if (snapshot.calendarMonth >= 1 && snapshot.calendarMonth <= 12) {
      await prefs.put(KEY_CAL_MONTH, snapshot.calendarMonth);
    }
    if (snapshot.yearViewYear >= 1900 && snapshot.yearViewYear <= 2100) {
      await prefs.put(KEY_YEAR_VIEW, snapshot.yearViewYear);
    }
    await prefs.flush();
  }

  static async readCalendarAnchor(context: common.Context): Promise<CalendarMonthAnchor> {
    const snapshot = await DesktopWidgetStore.readSnapshot(context);
    const anchor = new CalendarMonthAnchor();
    if (snapshot.calendarYear >= 1900 && snapshot.calendarMonth >= 1 && snapshot.calendarMonth <= 12) {
      anchor.year = snapshot.calendarYear;
      anchor.month = snapshot.calendarMonth;
      return anchor;
    }
    // 从 cellsJson 回退解析。
    const packed = snapshot.cellsJson;
    if (packed.length > 0 && packed.indexOf('|') > 0) {
      const key = packed.split('|')[0];
      const parts = key.split('-');
      if (parts.length === 2) {
        const y = Number(parts[0]);
        const m = Number(parts[1]);
        if (!Number.isNaN(y) && !Number.isNaN(m) && m >= 1 && m <= 12) {
          anchor.year = y;
          anchor.month = m;
          return anchor;
        }
      }
    }
    const now = new Date();
    anchor.year = now.getFullYear();
    anchor.month = now.getMonth() + 1;
    return anchor;
  }

  static async shiftCalendarMonth(context: common.Context, delta: number): Promise<DesktopWidgetSnapshot> {
    const snapshot = await DesktopWidgetStore.readSnapshot(context);
    const anchor = await DesktopWidgetStore.readCalendarAnchor(context);
    let year = anchor.year;
    let month = anchor.month + delta;
    while (month < 1) {
      month += 12;
      year -= 1;
    }
    while (month > 12) {
      month -= 12;
      year += 1;
    }
    // 不允许翻到当前月之后。
    const now = new Date();
    const nowYear = now.getFullYear();
    const nowMonth = now.getMonth() + 1;
    if (year > nowYear || (year === nowYear && month > nowMonth)) {
      year = nowYear;
      month = nowMonth;
    }
    DesktopWidgetStore.applyMonthSkeleton(snapshot, year, month);
    await DesktopWidgetStore.writeSnapshot(context, snapshot);
    return snapshot;
  }

  static async shiftCalendarYear(context: common.Context, delta: number): Promise<DesktopWidgetSnapshot> {
    const snapshot = await DesktopWidgetStore.readSnapshot(context);
    let year = snapshot.yearViewYear;
    if (year < 1900) {
      year = new Date().getFullYear();
    }
    year += delta;
    const nowYear = new Date().getFullYear();
    if (year > nowYear) {
      year = nowYear;
    }
    if (year < 1900) {
      year = 1900;
    }
    DesktopWidgetStore.applyYearSkeleton(snapshot, year);
    await DesktopWidgetStore.writeSnapshot(context, snapshot);
    return snapshot;
  }

  static async addFormId(context: common.Context, formId: string, formName: string = ''): Promise<void> {
    if (!formId) {
      return;
    }
    const prefs = await DesktopWidgetStore.ensure(context);
    const ids = await DesktopWidgetStore.readPersistedFormIds(context);
    if (ids.indexOf(formId) < 0) {
      ids.push(formId);
      await prefs.put(FORM_IDS_KEY, ids.join(','));
    }
    if (formName.length > 0) {
      await DesktopWidgetStore.putFormName(prefs, formId, formName);
    }
    await prefs.flush();
  }

  private static async putFormName(
    prefs: dataPreferences.Preferences,
    formId: string,
    formName: string,
  ): Promise<void> {
    const map = await DesktopWidgetStore.readFormNameMapFromPrefs(prefs);
    map[formId] = formName;
    const parts: string[] = [];
    const keys = Object.keys(map);
    for (let i = 0; i < keys.length; i++) {
      parts.push(`${keys[i]}=${map[keys[i]]}`);
    }
    await prefs.put(FORM_NAMES_KEY, parts.join(','));
  }

  private static async readFormNameMapFromPrefs(
    prefs: dataPreferences.Preferences,
  ): Promise<Record<string, string>> {
    const map: Record<string, string> = {};
    const raw = await prefs.get(FORM_NAMES_KEY, '');
    if (typeof raw !== 'string' || raw.length === 0) {
      return map;
    }
    const entries = raw.split(',');
    for (let i = 0; i < entries.length; i++) {
      const item = entries[i];
      const eq = item.indexOf('=');
      if (eq <= 0) {
        continue;
      }
      const id = item.substring(0, eq).trim();
      const name = item.substring(eq + 1).trim();
      if (id.length > 0 && name.length > 0) {
        map[id] = name;
      }
    }
    return map;
  }

  static async resolveFormName(context: common.Context, formId: string): Promise<string> {
    const prefs = await DesktopWidgetStore.ensure(context);
    const map = await DesktopWidgetStore.readFormNameMapFromPrefs(prefs);
    const cached = map[formId];
    if (cached !== undefined && cached.length > 0) {
      return cached;
    }
    try {
      const running = await formProvider.getPublishedRunningFormInfos();
      for (let i = 0; i < running.length; i++) {
        const info = running[i];
        if (info.formId === formId && info.formName) {
          await DesktopWidgetStore.putFormName(prefs, formId, info.formName);
          await prefs.flush();
          return info.formName;
        }
      }
    } catch (_e) {
      // ignore
    }
    return FORM_NAME_DAY;
  }

  static isDayForm(formName: string): boolean {
    return formName === FORM_NAME_DAY ||
      formName === FORM_NAME_STATS_DAY ||
      formName.indexOf('stats_income_expense_calendar') >= 0;
  }

  static isMonthForm(formName: string): boolean {
    return formName === FORM_NAME_MONTH || formName.indexOf('month_income_expense') >= 0;
  }

  static isOrderForm(formName: string): boolean {
    return formName === FORM_NAME_ORDER || formName.indexOf('reimbursement_order') >= 0;
  }

  static getSelectedOrderId(formId: string, snapshot: DesktopWidgetSnapshot): number {
    if (formId.length > 0 && snapshot.orderSelections.length > 0) {
      const parts = snapshot.orderSelections.split(',');
      for (let i = 0; i < parts.length; i++) {
        const item = parts[i];
        const eq = item.indexOf('=');
        if (eq <= 0) {
          continue;
        }
        if (item.substring(0, eq) === formId) {
          const id = Number(item.substring(eq + 1));
          if (!Number.isNaN(id) && id > 0) {
            return id;
          }
        }
      }
    }
    return snapshot.defaultOrderId > 0 ? snapshot.defaultOrderId : 0;
  }

  static setSelectedOrderId(snapshot: DesktopWidgetSnapshot, formId: string, orderId: number): void {
    const map: Record<string, string> = {};
    if (snapshot.orderSelections.length > 0) {
      const parts = snapshot.orderSelections.split(',');
      for (let i = 0; i < parts.length; i++) {
        const item = parts[i];
        const eq = item.indexOf('=');
        if (eq <= 0) {
          continue;
        }
        map[item.substring(0, eq)] = item.substring(eq + 1);
      }
    }
    map[formId] = `${orderId}`;
    const rebuilt: string[] = [];
    const keys = Object.keys(map);
    for (let i = 0; i < keys.length; i++) {
      rebuilt.push(`${keys[i]}=${map[keys[i]]}`);
    }
    snapshot.orderSelections = rebuilt.join(',');
  }

  static toOrderBindingData(
    snapshot: DesktopWidgetSnapshot,
    formId: string,
  ): formBindingData.FormBindingData {
    const selectedId = DesktopWidgetStore.getSelectedOrderId(formId, snapshot);
    let title = '报销单';
    let outText = '—';
    let inText = '—';
    const packed = snapshot.ordersPacked;
    if (packed.length > 0) {
      const parts = packed.split(';');
      let matched = false;
      let firstTitle = '';
      let firstOut = '—';
      let firstIn = '—';
      for (let i = 0; i < parts.length; i++) {
        const fields = parts[i].split('|');
        if (fields.length < 4) {
          continue;
        }
        const id = Number(fields[0]);
        const hide = fields[2] === '*' || snapshot.hideAmounts;
        const outDisp = hide ? '****' : DesktopWidgetStore.centsToText(Number(fields[2]));
        const inDisp = hide ? '****' : DesktopWidgetStore.centsToText(Number(fields[3]));
        if (firstTitle.length === 0) {
          firstTitle = fields[1];
          firstOut = outDisp;
          firstIn = inDisp;
        }
        if (id === selectedId) {
          title = fields[1].length > 0 ? fields[1] : '报销单';
          outText = outDisp;
          inText = inDisp;
          matched = true;
          break;
        }
      }
      if (!matched && firstTitle.length > 0) {
        title = firstTitle;
        outText = firstOut;
        inText = firstIn;
      }
    }
    const subtitle = '长按切换报销单';
    const json =
      '{"orderTitle":' + JSON.stringify(title) +
        ',"orderOutText":' + JSON.stringify(outText) +
        ',"orderInText":' + JSON.stringify(inText) +
        ',"updatedAt":' + JSON.stringify(snapshot.updatedAt) +
        ',"subtitle":' + JSON.stringify(subtitle) +
        '}';
    return formBindingData.createFormBindingData(json);
  }

  private static centsToText(cents: number): string {
    if (Number.isNaN(cents)) {
      return '—';
    }
    const value = cents / 100;
    const fixed = value.toFixed(2);
    const parts = fixed.split('.');
    let intPart = parts[0];
    const decPart = parts.length > 1 ? parts[1] : '00';
    const negative = intPart.indexOf('-') === 0;
    if (negative) {
      intPart = intPart.substring(1);
    }
    let grouped = '';
    let count = 0;
    for (let i = intPart.length - 1; i >= 0; i--) {
      grouped = intPart.charAt(i) + grouped;
      count++;
      if (count === 3 && i > 0) {
        grouped = ',' + grouped;
        count = 0;
      }
    }
    return `${negative ? '-' : ''}${grouped}.${decPart}`;
  }

  static async removeFormId(context: common.Context, formId: string): Promise<void> {
    const prefs = await DesktopWidgetStore.ensure(context);
    const current = await DesktopWidgetStore.readPersistedFormIds(context);
    const next: string[] = [];
    for (let i = 0; i < current.length; i++) {
      if (current[i] !== formId) {
        next.push(current[i]);
      }
    }
    await prefs.put(FORM_IDS_KEY, next.join(','));
    const map = await DesktopWidgetStore.readFormNameMapFromPrefs(prefs);
    const rebuilt: string[] = [];
    const keys = Object.keys(map);
    for (let i = 0; i < keys.length; i++) {
      if (keys[i] !== formId) {
        rebuilt.push(`${keys[i]}=${map[keys[i]]}`);
      }
    }
    await prefs.put(FORM_NAMES_KEY, rebuilt.join(','));
    await prefs.flush();
  }

  static async readPersistedFormIds(context: common.Context): Promise<string[]> {
    const prefs = await DesktopWidgetStore.ensure(context);
    const raw = await prefs.get(FORM_IDS_KEY, '');
    if (typeof raw !== 'string' || raw.length === 0) {
      return [];
    }
    const parts: string[] = raw.split(',');
    const result: string[] = [];
    for (let i = 0; i < parts.length; i++) {
      const item = parts[i].trim();
      if (item.length > 0) {
        result.push(item);
      }
    }
    return result;
  }

  static async collectFormIds(context: common.Context): Promise<string[]> {
    const merged: string[] = [];
    const persisted = await DesktopWidgetStore.readPersistedFormIds(context);
    for (let i = 0; i < persisted.length; i++) {
      if (merged.indexOf(persisted[i]) < 0) {
        merged.push(persisted[i]);
      }
    }

    try {
      const running = await formProvider.getPublishedRunningFormInfos();
      for (let i = 0; i < running.length; i++) {
        const id = running[i].formId;
        if (id && merged.indexOf(id) < 0) {
          merged.push(id);
        }
      }
    } catch (e) {
      console.error('DesktopWidgetStore.getPublishedRunningFormInfos failed', e);
    }

    if (merged.length > 0) {
      const prefs = await DesktopWidgetStore.ensure(context);
      await prefs.put(FORM_IDS_KEY, merged.join(','));
      await prefs.flush();
    }
    return merged;
  }

  static toBindingData(snapshot: DesktopWidgetSnapshot): formBindingData.FormBindingData {
    return DesktopWidgetStore.toDayBindingData(snapshot);
  }

  static toDayBindingData(snapshot: DesktopWidgetSnapshot): formBindingData.FormBindingData {
    const monthIncome = snapshot.hideAmounts ? '****' : snapshot.monthIncomeText;
    const monthExpense = snapshot.hideAmounts ? '****' : snapshot.monthExpenseText;
    const netAssets = snapshot.hideAmounts ? '****' : snapshot.netAssetsText;
    let cellsJson = snapshot.cellsJson;
    if (cellsJson.length === 0 || cellsJson === '[]') {
      cellsJson = DesktopWidgetStore.currentMonthPacked();
    }
    const monthTitle = snapshot.monthTitle.length > 0
      ? snapshot.monthTitle
      : DesktopWidgetStore.currentMonthTitle();

    const json =
      '{"monthTitle":' + JSON.stringify(monthTitle) +
        ',"weekdays":' + JSON.stringify(snapshot.weekdays) +
        ',"cellsJson":' + JSON.stringify(cellsJson) +
        ',"monthIncomeText":' + JSON.stringify(monthIncome) +
        ',"monthExpenseText":' + JSON.stringify(monthExpense) +
        ',"netAssetsText":' + JSON.stringify(netAssets) +
        ',"updatedAt":' + JSON.stringify(snapshot.updatedAt) +
        ',"subtitle":' + JSON.stringify(snapshot.subtitle) +
        '}';
    return formBindingData.createFormBindingData(json);
  }

  static toYearBindingData(snapshot: DesktopWidgetSnapshot): formBindingData.FormBindingData {
    const yearIncome = snapshot.hideAmounts ? '****' : snapshot.yearIncomeText;
    const yearExpense = snapshot.hideAmounts ? '****' : snapshot.yearExpenseText;
    const netAssets = snapshot.hideAmounts ? '****' : snapshot.netAssetsText;
    let yearCellsJson = snapshot.yearCellsJson;
    if (yearCellsJson.length === 0 || yearCellsJson === '[]') {
      yearCellsJson = DesktopWidgetStore.yearPacked(
        snapshot.yearViewYear > 0 ? snapshot.yearViewYear : new Date().getFullYear(),
      );
    }
    const yearTitle = snapshot.yearTitle.length > 0
      ? snapshot.yearTitle
      : DesktopWidgetStore.yearTitleOf(
        snapshot.yearViewYear > 0 ? snapshot.yearViewYear : new Date().getFullYear(),
      );

    const json =
      '{"yearTitle":' + JSON.stringify(yearTitle) +
        ',"yearCellsJson":' + JSON.stringify(yearCellsJson) +
        ',"yearIncomeText":' + JSON.stringify(yearIncome) +
        ',"yearExpenseText":' + JSON.stringify(yearExpense) +
        ',"netAssetsText":' + JSON.stringify(netAssets) +
        ',"updatedAt":' + JSON.stringify(snapshot.updatedAt) +
        ',"subtitle":' + JSON.stringify(snapshot.subtitle) +
        '}';
    return formBindingData.createFormBindingData(json);
  }

  static bindingForFormName(
    snapshot: DesktopWidgetSnapshot,
    formName: string,
    formId: string = '',
  ): formBindingData.FormBindingData {
    if (DesktopWidgetStore.isOrderForm(formName)) {
      return DesktopWidgetStore.toOrderBindingData(snapshot, formId);
    }
    if (DesktopWidgetStore.isMonthForm(formName)) {
      return DesktopWidgetStore.toYearBindingData(snapshot);
    }
    return DesktopWidgetStore.toDayBindingData(snapshot);
  }

  static async publishToForms(context: common.Context): Promise<number> {
    const snapshot = await DesktopWidgetStore.readSnapshot(context);
    console.info(`DesktopWidgetStore.publishToForms dayLen=${snapshot.cellsJson.length} yearLen=${snapshot.yearCellsJson.length} ordersLen=${snapshot.ordersPacked.length}`);
    let updated = 0;

    try {
      const running = await formProvider.getPublishedRunningFormInfos();
      const seen: string[] = [];
      const prefs = await DesktopWidgetStore.ensure(context);
      for (let i = 0; i < running.length; i++) {
        const info = running[i];
        const formId = info.formId;
        if (!formId || seen.indexOf(formId) >= 0) {
          continue;
        }
        seen.push(formId);
        const formName = info.formName && info.formName.length > 0
          ? info.formName
          : FORM_NAME_DAY;
        try {
          await DesktopWidgetStore.putFormName(prefs, formId, formName);
          await formProvider.updateForm(
            formId,
            DesktopWidgetStore.bindingForFormName(snapshot, formName, formId),
          );
          try {
            await formProvider.setFormNextRefreshTime(formId, 5);
          } catch (_e) {
            // optional
          }
          updated++;
        } catch (e) {
          console.error(`DesktopWidgetStore.updateForm failed: ${formId}`, e);
        }
      }
      if (seen.length > 0) {
        await prefs.put(FORM_IDS_KEY, seen.join(','));
        await prefs.flush();
        return updated;
      }
    } catch (e) {
      console.error('DesktopWidgetStore.getPublishedRunningFormInfos failed', e);
    }

    const formIds = await DesktopWidgetStore.collectFormIds(context);
    for (let i = 0; i < formIds.length; i++) {
      const formId = formIds[i];
      try {
        const formName = await DesktopWidgetStore.resolveFormName(context, formId);
        await formProvider.updateForm(
          formId,
          DesktopWidgetStore.bindingForFormName(snapshot, formName, formId),
        );
        try {
          await formProvider.setFormNextRefreshTime(formId, 5);
        } catch (_e) {
          // optional
        }
        updated++;
      } catch (e) {
        console.error(`DesktopWidgetStore.updateForm failed: ${formId}`, e);
      }
    }
    return updated;
  }

  static formIdFromWant(want: Want): string {
    const params = want.parameters;
    if (!params) {
      return '';
    }
    let identity: Object | string | number | undefined =
      params[formInfo.FormParam.IDENTITY_KEY];
    if (identity === undefined || identity === null) {
      identity = params['ohos.extra.param.key.form_identity'];
    }
    if (identity === undefined || identity === null) {
      return '';
    }
    return String(identity);
  }

  static formNameFromWant(want: Want): string {
    const params = want.parameters;
    if (!params) {
      return FORM_NAME_DAY;
    }
    let name: Object | string | number | undefined = params[formInfo.FormParam.NAME_KEY];
    if (name === undefined || name === null) {
      name = params['ohos.extra.param.key.form_name'];
    }
    if (name === undefined || name === null) {
      return FORM_NAME_DAY;
    }
    const raw = String(name);
    return raw.length > 0 ? raw : FORM_NAME_DAY;
  }
}
