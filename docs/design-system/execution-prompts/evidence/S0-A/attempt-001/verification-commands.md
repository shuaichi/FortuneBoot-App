# S0-A attempt-001 验证命令

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。源码快照：`6061359de0d6db6597176a9158ee826de490f6c4`。

| 命令 | 退出码 | 结果与原始证据 |
| --- | ---: | --- |
| `flutter --version` | 0 | Flutter 3.41.9 / Dart 3.11.5；首次沙箱内写 SDK `engine.stamp` 被拒绝，经授权后在沙箱外执行成功 |
| `python3 docs/design-system/execution-prompts/tools/validate_pack.py` | 0 | 28主线+16返修、334 ID、唯一owner和完整实例通过；见`commands.jsonl` |
| `python3 docs/design-system/execution-prompts/tools/validate_pack.py --generation-baseline` | 0 | 原lib/test/tool和审计产物哈希未变 |
| `flutter test --no-pub --reporter json` | 0 | 387通过、1跳过、0失败，runner success=true；原始流`flutter-test.json`，解析`results.json` |
| `flutter analyze --no-pub` | 1 | 1159诊断：0 error / 252 warning / 907 info；完整日志与结构化列表已保存 |
| `python3 .../build_fact_indexes.py` | 0 | 生成59个共享符号消费者事实索引和334项S0分诊记录 |
| `python3 .../build_visual_index.py` | 0 | 69图索引与页面迁移地图生成，69个源文件引用均存在 |

测试跳过项：`uses In-App Purchase for donations on Apple platforms`，保持原入口关闭，不擅自启用。

本轮全量测试流中直接提取的6项决定性回归全部通过：无边框金额输入1、亮暗实色卡反馈2、大字按钮1、附件网格2；见`targeted-tests.json`。没有重复运行伪装额外测试次数。

分析只与历史`verification.json`做计数比较，差值0。仓库没有历史1159条原始诊断列表，因此没有伪造逐条差异；本轮完整`analysis-diagnostics.json`供后续比较。
