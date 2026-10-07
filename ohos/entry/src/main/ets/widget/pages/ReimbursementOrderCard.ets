const orderCardStorage: LocalStorage = new LocalStorage();

class OrderCardRouterAction {
  action: string = 'router';
  abilityName: string = 'EntryAbility';
}

class OrderSelectParams {
  type: string = 'nextOrder';
}

class OrderSelectAction {
  action: string = 'message';
  params: OrderSelectParams = new OrderSelectParams();
}

@Entry(orderCardStorage)
@Component
struct ReimbursementOrderCard {
  @LocalStorageProp('orderTitle') @Watch('onBindChanged') orderTitle: string = '报销单';
  @LocalStorageProp('orderOutText') @Watch('onBindChanged') orderOutText: string = '—';
  @LocalStorageProp('orderInText') @Watch('onBindChanged') orderInText: string = '—';
  @LocalStorageProp('updatedAt') @Watch('onBindChanged') updatedAt: string = '';
  @LocalStorageProp('subtitle') subtitle: string = '左右切换报销单';

  @State displayTitle: string = '报销单';
  @State displayOut: string = '—';
  @State displayIn: string = '—';
  @State displayUpdated: string = '';

  aboutToAppear() {
    this.onBindChanged();
  }

  onBindChanged() {
    this.displayTitle = this.orderTitle.length > 0 ? this.orderTitle : '报销单';
    this.displayOut = this.orderOutText.length > 0 ? this.orderOutText : '—';
    this.displayIn = this.orderInText.length > 0 ? this.orderInText : '—';
    this.displayUpdated = this.updatedAt.length > 0 ? this.updatedAt : this.subtitle;
  }

  private postSelect(type: string): void {
    const action = new OrderSelectAction();
    action.params.type = type;
    postCardAction(this, action);
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(26)
          .fontWeight(FontWeight.Medium)
          .fontColor('#5B6475')
          .width(28)
          .height(32)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.postSelect('prevOrder');
          })

        Text(this.displayTitle)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1F36')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            postCardAction(this, new OrderCardRouterAction());
          })

        Text('›')
          .fontSize(26)
          .fontWeight(FontWeight.Medium)
          .fontColor('#5B6475')
          .width(28)
          .height(32)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.postSelect('nextOrder');
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Blank().layoutWeight(1)

      Text(`↑${this.displayIn}`)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#E11D48')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .onClick(() => {
          postCardAction(this, new OrderCardRouterAction());
        })

      Text(`↓${this.displayOut}`)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#059669')
        .margin({ top: 6 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .onClick(() => {
          postCardAction(this, new OrderCardRouterAction());
        })

      Blank().height(8)

      Text(this.displayUpdated)
        .fontSize(10)
        .fontColor('#A0A8B8')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({
      top: 14,
      right: 12,
      bottom: 12,
      left: 12,
    })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#FFFFFF')
    .borderRadius(18)
  }
}
