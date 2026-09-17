# 进度

> 原则：改动后在这里登记"做了什么 + 验证证据 + 下一步"。证据指向文件/命令结果，不要只写一句话。

## 2026-09-17 · 新增根 README

- 新增 `README.md`：站点链接、项目介绍（三科题库/错题/单词）、扩展题库方式（改数据源 / 构建器 / 网页投稿）。

## 2026-09-17 · 配置 GitHub Pages 部署

- 新增 `.github/workflows/pages.yml`：push 到 main 后自动把 `_site` 部署到 Pages。`_site` = SCGSstudy 站点静态文件（index/manifest/图标/contribute/katex）+ 三科 `题库页.html` 与 `错题集/*.html` 同级摆放；入口页 `../计算机` 前缀经 sed 改为同级链接。
- 入口页即仓库现有 `SCGSstudy/index.html`（上传文件与其 SHA256 完全一致），未改动。
- 删除了我先前误建的根目录 `index.html`。
- 验证证据：本地模拟 sed 替换后无残留 `../`，链接均解析到三科同级目录；根目录 *.mjs 全部 `node --check` 通过（0 失败）。
- ⚠️ 待确认：仓库跟踪了 `SCGSstudy/.admin_key`（27B 密钥），若仓库公开会泄露，需移出 git 并轮换。

## 2026-09-17 · 初始化 harness

- 创建 `AGENTS.md`（约束）、`feature_list.json`（功能清单）、`progress.md`（本文件）、`init.sh`（验证脚本）。
- 证据：仓库根目录现存在上述 4 个文件；`git status` 干净。
- 下一步：审计 `真题收集/` 目录内容；对根目录 `.mjs` 逐个跑 `node --check`；为三科题目补来源到省/年。

## 待办 / 下一步

- [ ] 审计 `真题收集/` 目录有哪些资料，登记进 feature_list（zhenti_collection 由 pending → in_progress）。
- [ ] 对 `build_plan.mjs / rebuild_daily.mjs / update_official.mjs / fix_schedule.mjs / clean_tracker.mjs / optimize_math_order.mjs / restore_sep8.mjs / update_after_feedback.mjs / update_curfew.mjs / update_exam_analysis.mjs` 跑 `node --check`，看哪些还能跑。
- [ ] 抽查三科 `题库.md`，把"来源：往年专升本试题汇总"这类含糊来源按省/年补全（遵守 AGENTS.md 铁律 1）。
- [ ] 确认各科 `题库页.html` 是否需要按数据源重新生成（不要手改 HTML）。