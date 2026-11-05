# S4-B 实施计划

目标：在 `1243a5b3e4eb2603ca7ea7c0641f724b5ccd5e8e` 起点完成账单详情金额口径、完整阅读、附件能力和来源权限收敛。

范围：`lib/features/shared/presentation/bills/`、`lib/features/shared/data/bill_attachment*`、`lib/features/bills/presentation/widgets/bill_tile.dart`，同域测试/fixture、必要 ARB/生成文案及本阶段台账。不 commit/push，不执行 S5-A。

1. 保存基线计数与 SHA，新增 RED：实付 100+3-5、标签 >3、附加备注/分类、长备注、统计/确认、非图片、图片关闭、来源禁用、宽屏关闭、忙碌、金额隐藏、component 路由。
2. 抽离共享账单金额展示/格式化辅助，列表与详情共用 settled/display 计算与方向，避免两个口径再次漂移；不修改存储算法。
3. 详情改为主金额＋原额/手续费/优惠分解，完整标签、附加明细、段落备注、统计/确认/来源只读状态；小高度仅动作固定，内容滚动。
4. 新增详情附件卡片和 `bill_attachment*` 最小打开/保存服务：bytes 校验、文件名/MIME、平台条件实现、明确结果；不把失败/不支持说成成功。图片黑底关闭用白字/深色半透明配对，宽屏详情有显式关闭。
5. 权限按 allowedActions/readOnlyReason 解析：EDIT/COPY/DELETE/CONFIRM/UNCONFIRM；普通账单保持现有兼容。编辑/复制路由保留 bookId/orderId/orderComponent/orderLedgerVersion，忙碌覆盖确认/删除真实任务且防重复。
6. 最终跑定向、全量、分析、真实业务渲染并实际看图；模拟器按用户新规则补验。写 issue-checks/handoff/runtime，nextStage=S5-A，不写 VERIFIED_CLOSED。
