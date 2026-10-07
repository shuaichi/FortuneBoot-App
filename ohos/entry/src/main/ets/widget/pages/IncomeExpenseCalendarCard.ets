const calendarCardStorage: LocalStorage = new LocalStorage();

class CalendarCardRouterAction {
  action: string = 'router';
  abilityName: string = 'EntryAbility';
}

class MonthNavParams {
  type: string = 'prevMonth';
}

class MonthNavAction {
  action: string = 'message';
  params: MonthNavParams = new MonthNavParams();
}

class CalendarDayCell {
  d: number = 0;
  i: string = '';
  e: string = '';
  a: number = 0;
  t: number = 0;
}

@Entry(calendarCardStorage)
@Component
struct IncomeExpenseCalendarCard {
  @LocalStorageProp('monthTitle') @Watch('onBindChanged') monthTitle: string = '日收支日历';
  @LocalStorageProp('weekdays') weekdays: string = '一二三四五六日';
  // 紧凑格式：yyyy-MM|todayDay|day:incomeCents:expenseCents;...
  @LocalStorageProp('cellsJson') @Watch('onBindChanged') cellsJson: string = '';
  @LocalStorageProp('monthIncomeText') @Watch('onBindChanged') monthIncomeText: string = '—';
  @LocalStorageProp('monthExpenseText') @Watch('onBindChanged') monthExpenseText: string = '—';
  @LocalStorageProp('netAssetsText') @Watch('onBindChanged') netAssetsText: string = '—';
  @LocalStorageProp('updatedAt') @Watch('onBindChanged') updatedAt: string = '';
  @LocalStorageProp('subtitle') subtitle: string = '翻月自动同步';

  @State cells: CalendarDayCell[] = [];
  @State displayMonthTitle: string = '日收支日历';
  @State displayIncome: string = '—';
  @State displayExpense: string = '—';
  @State displayNetAssets: string = '—';
  @State displayUpdated: string = '';

  aboutToAppear() {
    this.onBindChanged();
  }

  onBindChanged() {
    this.displayMonthTitle = this.monthTitle.length > 0 ? this.monthTitle : '日收支日历';
    this.displayIncome = this.monthIncomeText.length > 0 ? this.monthIncomeText : '—';
    this.displayExpense = this.monthExpenseText.length > 0 ? this.monthExpenseText : '—';
    this.displayNetAssets = this.netAssetsText.length > 0 ? this.netAssetsText : '—';
    this.displayUpdated = this.updatedAt.length > 0 ? this.updatedAt : this.subtitle;
    this.cells = this.parseCells(this.cellsJson);
  }

  private isDigits(raw: string): boolean {
    if (raw.length === 0) {
      return false;
    }
    for (let i = 0; i < raw.length; i++) {
      const code = raw.charCodeAt(i);
      if (code < 48 || code > 57) {
        return false;
      }
    }
    return true;
  }

  private displayAmount(raw: string): string {
    if (raw.length === 0) {
      return '—';
    }
    if (raw === '*') {
      return '****';
    }
    // 新格式：分；旧格式：compact 文本。
    if (this.isDigits(raw)) {
      const cents = Number(raw);
      const value = cents / 100;
      if (value >= 10000) {
        return `${(value / 10000).toFixed(1)}万`;
      }
      if (value >= 1000) {
        return value.toFixed(0);
      }
      if (Math.abs(value - Math.floor(value)) < 0.001) {
        return `${Math.floor(value)}`;
      }
      return value.toFixed(2);
    }
    return raw;
  }

  private isLeap(year: number): boolean {
    return (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0);
  }

  private daysInMonth(year: number, month: number): number {
    if (month === 2) {
      return this.isLeap(year) ? 29 : 28;
    }
    if (month === 4 || month === 6 || month === 9 || month === 11) {
      return 30;
    }
    return 31;
  }

  // Monday=0 ... Sunday=6
  private weekdayMondayIndex(year: number, month: number, day: number): number {
    const t: number[] = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4];
    let y = year;
    const m = month;
    if (m < 3) {
      y -= 1;
    }
    const w = (y + Math.floor(y / 4) - Math.floor(y / 100) + Math.floor(y / 400) + t[m - 1] + day) % 7;
    return w === 0 ? 6 : w - 1;
  }

  private nowYear(): number {
    return new Date().getFullYear();
  }

  private nowMonth(): number {
    return new Date().getMonth() + 1;
  }

  private nowDay(): number {
    return new Date().getDate();
  }

  private buildMonthCells(year: number, month: number, todayDay: number, amountSlots: CalendarDayCell[]): CalendarDayCell[] {
    const result: CalendarDayCell[] = [];
    const leading = this.weekdayMondayIndex(year, month, 1);
    const dim = this.daysInMonth(year, month);
    for (let i = 0; i < leading; i++) {
      result.push(new CalendarDayCell());
    }
    for (let day = 1; day <= dim; day++) {
      const cell = new CalendarDayCell();
      cell.d = day;
      cell.t = (todayDay === day) ? 1 : 0;
      const existing = amountSlots[day];
      if (existing !== undefined && existing.a === 1) {
        cell.i = existing.i;
        cell.e = existing.e;
        cell.a = 1;
      }
      result.push(cell);
    }
    while (result.length < 42) {
      result.push(new CalendarDayCell());
    }
    const trimmed: CalendarDayCell[] = [];
    for (let i = 0; i < 42 && i < result.length; i++) {
      trimmed.push(result[i]);
    }
    return trimmed;
  }

  private emptyAmountSlots(): CalendarDayCell[] {
    const slots: CalendarDayCell[] = [];
    for (let i = 0; i <= 31; i++) {
      slots.push(new CalendarDayCell());
    }
    return slots;
  }

  private parseAmountSlots(entriesRaw: string): CalendarDayCell[] {
    const slots = this.emptyAmountSlots();
    if (entriesRaw.length === 0) {
      return slots;
    }
    const sep = entriesRaw.indexOf(';') >= 0 ? ';' : ',';
    const entries: string[] = entriesRaw.split(sep);
    for (let i = 0; i < entries.length; i++) {
      const token = entries[i].trim();
      if (token.length === 0) {
        continue;
      }
      const parts: string[] = token.split(':');
      if (parts.length < 3) {
        continue;
      }
      const day = Number(parts[0]);
      if (Number.isNaN(day) || day < 1 || day > 31) {
        continue;
      }
      slots[day].d = day;
      slots[day].i = parts[1];
      slots[day].e = parts[2];
      slots[day].a = 1;
    }
    return slots;
  }

  private parseCells(raw: string): CalendarDayCell[] {
    const yearNow = this.nowYear();
    const monthNow = this.nowMonth();
    const dayNow = this.nowDay();

    if (raw.length === 0 || raw === '[]') {
      return this.buildMonthCells(yearNow, monthNow, dayNow, this.emptyAmountSlots());
    }
    if (raw.charAt(0) === '[') {
      return this.buildMonthCells(yearNow, monthNow, dayNow, this.emptyAmountSlots());
    }

    try {
      const sections: string[] = raw.split('|');
      if (sections.length < 2) {
        return this.buildMonthCells(yearNow, monthNow, dayNow, this.emptyAmountSlots());
      }
      const monthKey = sections[0];
      const todayDayRaw = Number(sections[1]);
      const entriesRaw = sections.length >= 3 ? sections[2] : '';
      const ym: string[] = monthKey.split('-');
      if (ym.length !== 2) {
        return this.buildMonthCells(yearNow, monthNow, dayNow, this.emptyAmountSlots());
      }
      const year = Number(ym[0]);
      const month = Number(ym[1]);
      if (Number.isNaN(year) || Number.isNaN(month) || month < 1 || month > 12) {
        return this.buildMonthCells(yearNow, monthNow, dayNow, this.emptyAmountSlots());
      }
      const todayDay = Number.isNaN(todayDayRaw) ? 0 : todayDayRaw;
      return this.buildMonthCells(year, month, todayDay, this.parseAmountSlots(entriesRaw));
    } catch (_e) {
      return this.buildMonthCells(yearNow, monthNow, dayNow, this.emptyAmountSlots());
    }
  }

  private weekdayChars(): string[] {
    const chars: string[] = [];
    const raw = this.weekdays.length > 0 ? this.weekdays : '一二三四五六日';
    for (let i = 0; i < raw.length && chars.length < 7; i++) {
      chars.push(raw.charAt(i));
    }
    while (chars.length < 7) {
      chars.push('');
    }
    return chars;
  }

  private visibleWeekCount(): number {
    // 末尾整行空白周不画，给有效格子更多高度。
    let last = 4;
    for (let week = 5; week >= 4; week--) {
      let hasDay = false;
      for (let col = 0; col < 7; col++) {
        const idx = week * 7 + col;
        if (idx < this.cells.length && this.cells[idx].d > 0) {
          hasDay = true;
          break;
        }
      }
      if (hasDay) {
        last = week;
        break;
      }
    }
    return last + 1;
  }

  private weekCells(week: number): CalendarDayCell[] {
    const row: CalendarDayCell[] = [];
    for (let col = 0; col < 7; col++) {
      const idx = week * 7 + col;
      if (idx < this.cells.length) {
        row.push(this.cells[idx]);
      } else {
        row.push(new CalendarDayCell());
      }
    }
    return row;
  }

  private weekIndexes(): number[] {
    const count = this.visibleWeekCount();
    const indexes: number[] = [];
    for (let i = 0; i < count; i++) {
      indexes.push(i);
    }
    return indexes;
  }

  private hasIncome(cell: CalendarDayCell): boolean {
    return cell.a === 1 && cell.i.length > 0 && cell.i !== '0';
  }

  private hasExpense(cell: CalendarDayCell): boolean {
    return cell.a === 1 && cell.e.length > 0 && cell.e !== '0';
  }

  @Builder
  DayCell(cell: CalendarDayCell) {
    Column() {
      if (cell.d > 0) {
        Text(`${cell.d}`)
          .fontSize(11)
          .fontWeight(cell.t === 1 ? FontWeight.Bold : FontWeight.Medium)
          .fontColor(cell.t === 1 ? '#2F6BFF' : '#3D4558')
          .margin({ bottom: 2 })

        if (this.hasIncome(cell)) {
          Text(`↑${this.displayAmount(cell.i)}`)
            .fontSize(8)
            .fontColor('#E11D48')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        if (this.hasExpense(cell)) {
          Text(`↓${this.displayAmount(cell.e)}`)
            .fontSize(8)
            .fontColor('#059669')
            .margin({ top: this.hasIncome(cell) ? 1 : 0 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 2, bottom: 2 })
    .backgroundColor(cell.d <= 0
      ? Color.Transparent
      : (cell.t === 1 ? '#EEF3FF' : (cell.a === 1 ? '#F5F7FA' : Color.Transparent)))
    .borderRadius(8)
    .border(cell.t === 1 ? {
      width: 1,
      color: '#2F6BFF',
    } : {
      width: 0,
      color: Color.Transparent,
    })
  }

  @Builder
  WeekRow(week: number) {
    Row() {
      ForEach(this.weekCells(week), (cell: CalendarDayCell, col: number) => {
        Column() {
          this.DayCell(cell)
        }
        .layoutWeight(1)
        .height('100%')
        .padding({ left: 1.5, right: 1.5 })
      }, (cell: CalendarDayCell, col: number) =>
        `w${week}_${col}_${cell.d}_${cell.i}_${cell.e}_${cell.a}_${cell.t}`)
    }
    .width('100%')
    .layoutWeight(1)
  }

  private postMonthNav(type: string): void {
    const action = new MonthNavAction();
    action.params.type = type;
    postCardAction(this, action);
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(28)
          .fontWeight(FontWeight.Medium)
          .fontColor('#5B6475')
          .width(28)
          .height(36)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.postMonthNav('prevMonth');
          })

        Column() {
          Text(this.displayMonthTitle)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1F36')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.displayUpdated)
            .fontSize(10)
            .fontColor('#A0A8B8')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)
        .onClick(() => {
          postCardAction(this, new CalendarCardRouterAction());
        })

        Text('›')
          .fontSize(28)
          .fontWeight(FontWeight.Medium)
          .fontColor('#5B6475')
          .width(28)
          .height(36)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.postMonthNav('nextMonth');
          })

        Column() {
          Text(`↑${this.displayIncome}`)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#E11D48')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(`↓${this.displayExpense}`)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#059669')
            .margin({ top: 4 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        // 以较长金额为列宽，较短一方在该宽度内居中。
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .margin({ left: 8 })

        Column() {
          Text('净资产')
            .fontSize(10)
            .fontColor('#9AA3B2')
            .maxLines(1)
          Text(this.displayNetAssets)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1F36')
            .margin({ top: 4 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.End)
        .justifyContent(FlexAlign.Center)
        .margin({ left: 10 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row()
        .width('100%')
        .height(0.5)
        .backgroundColor('#EEF0F4')
        .margin({ top: 10, bottom: 8 })

      Row() {
        ForEach(this.weekdayChars(), (label: string, index: number) => {
          Text(label)
            .layoutWeight(1)
            .fontSize(11)
            .fontColor('#9AA3B2')
            .textAlign(TextAlign.Center)
        }, (label: string, index: number) => `wd_${index}_${label}`)
      }
      .width('100%')
      .margin({ bottom: 6 })

      Column() {
        ForEach(this.weekIndexes(), (week: number) => {
          this.WeekRow(week)
        }, (week: number) => `week_${week}_${this.displayUpdated}`)
      }
      .width('100%')
      .layoutWeight(1)
      .onClick(() => {
        postCardAction(this, new CalendarCardRouterAction());
      })
    }
    .width('100%')
    .height('100%')
    .padding({
      top: 14,
      right: 14,
      bottom: 12,
      left: 14,
    })
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }
}
