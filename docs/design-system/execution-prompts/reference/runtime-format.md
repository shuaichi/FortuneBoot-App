# 交接、实例和审查数据格式

主计划stage-map.json和issues.json是只读分工基准。执行状态写runtime/progress.json，问题实例执行证据写runtime/issue-checks/<stage>.json，不覆盖历史审计。

每条issue-check至少：issueId、stageId、state（NOT_CHECKED/CONFIRMED/IMPLEMENTED_LOCAL/VERIFIED_LOCAL/DISPROVED/BLOCKED_EXTERNAL/NOT_APPLICABLE）、sourcePaths、sourceSha256、observedBehavior、evidencePaths、unverified、reason。选择NOT_APPLICABLE/DISPROVED必须有当前反证，不能仅引用报告猜测。跨页实例独立，不能一个页面通过就关闭全局ID。

S2每轮写reviews/<stage>/attempt-N/review.json：reviewId、stageId、sourceSnapshot、verdict、issueResults、defects。defect包含唯一reviewIssueId、originAuditIds、priority、fileAndLine、trigger、expected、actual、impact、ownerSession、repairPrompt、affectedConsumers、requiredChecks、status。若同因影响多个owner，分别明确修复节点和顺序。

repair-routing.json包含reviewId、sourceSnapshot、orderedRepairs（promptId、session、defectIds、requires、reason）、returnTo=S2-C。无缺陷orderedRepairs=[]。初审S2-A固定回S1-B后再S2-A；中途合同请求走S1-E并回requesterStage。

runtime/contract-requests.json每条：requestId、requesterStage、ownerSession=S1、currentContractVersion、reproduction、requiredSemantics、blockedIssueIds、candidateMinimalChange、status、responseEvidence。没有真实caller就不创建抽象公共能力。

证据目录attempt-N不可覆写。handoff可以更新“最新摘要”，必须链接历次attempt。runtime写临时同目录文件、校验JSON及字段后原子replace，不截断其它会话结果。全程串行，不需要分布式锁或另造任务系统。
