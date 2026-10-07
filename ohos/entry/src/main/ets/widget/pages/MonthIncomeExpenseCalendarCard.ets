const monthCalendarCardStorage: LocalStorage = new LocalStorage();

class MonthCalendarCardRouterAction {
  action: string = 'router';
  abilityName: string = 'EntryAbility';
}

class YearNavParams {
  type: string = 'prevYear';
}

class YearNavAction {
  action: string = 'message';
  params: YearNavParams = new YearNavParams();
}

class CalendarMonthCell {
  m: number = 0;
  i: string = '';
  e: string = '';
  a: number = 0;
  t: number = 0;
}

@Entry(monthCalendarCardStorage)
@Component
struct MonthIncomeExpenseCalendarCard {
  @LocalStorageProp('yearTitle') @Watch('onBindChanged') yearTitle: string = '月收支日历';
  // 紧凑格式：yyyy|currentMonth|month:incomeCents:expenseCents;...
  @LocalStorageProp('yearCellsJson') @Watch('onBindChanged') yearCellsJson: string = '';
  @LocalStorageProp('yearIncomeText') @Watch('onBindChanged') yearIncomeText: string = '—';
  @LocalStorageProp('yearExpenseText') @Watch('onBindChanged') yearExpenseText: string = '—';
  @LocalStorageProp('netAssetsText') @Watch('onBindChanged') netAssetsText: string = '—';
  @LocalStorageProp('updatedAt') @Watch('onBindChanged') updatedAt: string = '';
  @LocalStorageProp('subtitle') subtitle: string = '翻年自动同步';

  @State cells: CalendarMonthCell[] = [];
  @State displayYearTitle: string = '月收支日历';
  @State displayIncome: string = '—';
  @State displayExpense: string = '—';
  @State displayNetAssets: string = '—';
  @State displayUpdated: string = '';

  aboutToAppear() {
    this.onBindChanged();
  }

  onBindChanged() {
    this.displayYearTitle = this.yearTitle.length > 0 ? this.yearTitle : '月收支日历';
    this.displayIncome = this.yearIncomeText.length > 0 ? this.yearIncomeText : '—';
    this.displayExpense = this.yearExpenseText.length > 0 ? this.yearExpenseText : '—';
    this.displayNetAssets = this.netAssetsText.length > 0 ? this.netAssetsText : '—';
    this.displayUpdated = this.updatedAt.length > 0 ? this.updatedAt : this.subtitle;
    this.cells = this.parseCells(this.yearCellsJson);
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

  private parseAmountSlots(entriesRaw: string): CalendarMonthCell[] {
    const slots: CalendarMonthCell[] = [];
    if (entriesRaw.length === 0) {
      return slots;
    }
    const parts = entriesRaw.split(';');
    for (let i = 0; i < parts.length; i++) {
      const item = parts[i];
      if (item.length === 0) {
        continue;
      }
      const fields = item.split(':');
      if (fields.length < 3) {
        continue;
      }
      const month = Number(fields[0]);
      if (Number.isNaN(month) || month < 1 || month > 12) {
        continue;
      }
      const cell = new CalendarMonthCell();
      cell.m = month;
      cell.i = fields[1];
      cell.e = fields[2];
      cell.a = 1;
      slots.push(cell);
    }
    return slots;
  }

  private buildYearCells(year: number, currentMonth: number, amountSlots: CalendarMonthCell[]): CalendarMonthCell[] {
    const byMonth: Record<string, CalendarMonthCell> = {};
    for (let i = 0; i < amountSlots.length; i++) {
      byMonth[`${amountSlots[i].m}`] = amountSlots[i];
    }
    const cells: CalendarMonthCell[] = [];
    for (let month = 1; month <= 12; month++) {
      const cell = new CalendarMonthCell();
      cell.m = month;
      cell.t = (currentMonth === month) ? 1 : 0;
      const hit = byMonth[`${month}`];
      if (hit !== undefined) {
        cell.i = hit.i;
        cell.e = hit.e;
        cell.a = 1;
      }
      cells.push(cell);
    }
    return cells;
  }

  private parseCells(raw: string): CalendarMonthCell[] {
    const now = new Date();
    const fallbackYear = now.getFullYear();
    if (!raw || raw.length === 0 || raw === '[]') {
      return this.buildYearCells(fallbackYear, now.getMonth() + 1, []);
    }
    try {
      // yyyy|currentMonth|month:income:expense;...
      const sections = raw.split('|');
      if (sections.length < 2) {
        return this.buildYearCells(fallbackYear, now.getMonth() + 1, []);
      }
      const year = Number(sections[0]);
      const currentMonthRaw = Number(sections[1]);
      const entriesRaw = sections.length >= 3 ? sections[2] : '';
      if (Number.isNaN(year) || year < 1900) {
        return this.buildYearCells(fallbackYear, now.getMonth() + 1, []);
      }
      const currentMonth = Number.isNaN(currentMonthRaw) ? 0 : currentMonthRaw;
      return this.buildYearCells(year, currentMonth, this.parseAmountSlots(entriesRaw));
    } catch (_e) {
      return this.buildYearCells(fallbackYear, now.getMonth() + 1, []);
    }
  }

  private rowCells(row: number): CalendarMonthCell[] {
    const start = row * 4;
    const result: CalendarMonthCell[] = [];
    for (let i = 0; i < 4; i++) {
      const idx = start + i;
      if (idx < this.cells.length) {
        result.push(this.cells[idx]);
      } else {
        result.push(new CalendarMonthCell());
      }
    }
    return result;
  }

  private hasIncome(cell: CalendarMonthCell): boolean {
    return cell.a === 1 && cell.i.length > 0 && cell.i !== '0';
  }

  private hasExpense(cell: CalendarMonthCell): boolean {
    return cell.a === 1 && cell.e.length > 0 && cell.e !== '0';
  }

  @Builder
  MonthCell(cell: CalendarMonthCell) {
    Column() {
      if (cell.m > 0) {
        Text(`${cell.m}月`)
          .fontSize(12)
          .fontWeight(cell.t === 1 ? FontWeight.Bold : FontWeight.Medium)
          .fontColor(cell.t === 1 ? '#2F6BFF' : '#3D4558')
          .margin({ bottom: 4 })

        if (this.hasIncome(cell)) {
          Text(`↑${this.displayAmount(cell.i)}`)
            .fontSize(10)
            .fontColor('#E11D48')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        if (this.hasExpense(cell)) {
          Text(`↓${this.displayAmount(cell.e)}`)
            .fontSize(10)
            .fontColor('#059669')
            .margin({ top: this.hasIncome(cell) ? 2 : 0 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 4, bottom: 4, left: 2, right: 2 })
    .backgroundColor(cell.m <= 0
      ? Color.Transparent
      : (cell.t === 1 ? '#EEF3FF' : (cell.a === 1 ? '#F5F7FA' : Color.Transparent)))
    .borderRadius(10)
    .border(cell.t === 1 ? {
      width: 1,
      color: '#2F6BFF',
    } : {
      width: 0,
      color: Color.Transparent,
    })
  }

  @Builder
  MonthRow(row: number) {
    Row() {
      ForEach(this.rowCells(row), (cell: CalendarMonthCell, col: number) => {
        Column() {
          this.MonthCell(cell)
        }
        .layoutWeight(1)
        .height('100%')
        .padding({ left: 3, right: 3 })
      }, (cell: CalendarMonthCell, col: number) =>
        `r${row}_${col}_${cell.m}_${cell.i}_${cell.e}_${cell.a}_${cell.t}`)
    }
    .width('100%')
    .layoutWeight(1)
  }

  private postYearNav(type: string): void {
    const action = new YearNavAction();
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
            this.postYearNav('prevYear');
          })

        Column() {
          Text(this.displayYearTitle)
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
          postCardAction(this, new MonthCalendarCardRouterAction());
        })

        Text('›')
          .fontSize(28)
          .fontWeight(FontWeight.Medium)
          .fontColor('#5B6475')
          .width(28)
          .height(36)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.postYearNav('nextYear');
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

      Column() {
        ForEach([0, 1, 2], (row: number) => {
          this.MonthRow(row)
        }, (row: number) => `mrow_${row}_${this.displayUpdated}`)
      }
      .width('100%')
      .layoutWeight(1)
      .onClick(() => {
        postCardAction(this, new MonthCalendarCardRouterAction());
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
