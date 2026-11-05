# 文档索引

## 保持维护的入口

- [工程说明](../README.md)：真实目录、开发与验证命令。
- [平台环境](environment.md)：Android / 鸿蒙 SDK、本机配置和构建入口。

## 本地设计整改资料

`docs/design-system/` 整体由 `.gitignore` 忽略，包含当前正在使用的全量审计和 S 系列提示词。它们不是无用产物，清理工作区时必须保留任务仍依赖的完整文件集合。

本机入口：

- `docs/design-system/2026-11-05-global-audit.md`：全局审计与模块报告索引。
- `docs/design-system/execution-prompts/README.md`：执行顺序、会话返回图与44份独立提示词。
- `docs/design-system/execution-prompts/runtime/progress.json`：阶段实际执行状态，不等于会话已结束。
- `docs/design-system/verification.md`：设计底座历史验证记录；新改动须重新验证。

这些文件是本地交付资料，新的 Git 检出不保证存在。若以后需要共享，应明确选定一套完整任务包再纳入版本管理，不能仅提交 JSON 或图片而遗漏其 Markdown 依赖。

## 历史接口参考

本机 `docs/reference/http-api-legacy.md` 和 `docs/reference/statistics-api-snapshot.md` 保留过去的源码扫描快照，目录整体忽略。

- 旧综合文档列的是旧单据接口，不能作为 `/fortune/finance/order/v2` 契约。
- 统计快照未记录可核对的后端提交 SHA，只用于定位接口与参数；修改客户端前核对目标后端。
- 当前客户端请求实现主要在 `lib/features/*/data/`、`lib/request/`。后端的权威定义仍应以对应服务版本为准。

## 清理原则

已完成的临时计划、过期执行记录、构建日志、模板占位说明和与现行规则冲突的旧指导应移出项目，不保留多个互相冲突的“当前方案”。清理前保存工作区外备份；签名、本地 SDK 配置、依赖缓存和当前构建产物不因 Git 忽略而自动判定可删。

2026-11-05 清理已移出旧财务改单阶段05/06记录、已实施的人工核对计划、已完成底座计划、两份旧 UI 指南、旧流程日志和模板说明。备份位于本机 `.joycode/workspace-cleanup-backups/`，具体清单以备份中的 `manifest.json` 为准。
