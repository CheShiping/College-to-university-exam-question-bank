# 进度

> 原则：改动后在这里登记"做了什么 + 验证证据 + 下一步"。证据指向文件/命令结果，不要只写一句话。

## 2026-09-17 · 新增 GitHub 仓库悬浮按钮

- **改动**：`SCGSstudy/build.py` AI_HTML 组件新增 `#ghFab`（26px 圆形、GitHub 官方 SVG 白标、`target="_blank"` 跳转 `https://github.com/CheShiping/College-to-university-exam-question-bank`、`data-tip="GitHub 仓库"`），置于浮动按钮组最底部（bottom:16px）；`#aiFab` 上移至 bottom:52px、`#subFab` 上移至 bottom:88px；AI 面板 bottom 50→86px（桌面 + ≤480px 移动端同改），Tooltip 选择器纳入 `#ghFab`。
- **验证**：`python SCGSstudy/build.py` 全量重建成功；grep 产物 10 个 HTML 均含 `id="ghFab"` 且 href 指向目标仓库；`#ghFab{bottom:16px}`、`#aiFab{bottom:52px}`、tooltip 三按钮选择器就位。
- 下一步：push 触发部署后在线复核新按钮跳转与 Tooltip。

## 2026-09-17 · 修复 GitHub Pages 部署后公式不渲染 + 返回入口链接失效

- **根因**：部署工作流把 KaTeX 与入口页摊平到站点根（`_site/katex/`、`_site/index.html`），但三科 `题库页.html`/`错题集/*.html` 内部引用仍是本地布局的 `../SCGSstudy/katex/...` 与 `../SCGSstudy/index.html`。站点挂在 `/College-to-university-exam-question-bank/` 子路径下，`../SCGSstudy/...` 解析到 `.../SCGSstudy/...` → 404，KaTeX 加载失败 → `$...$` 公式源码裸显；「返回错题本总入口」同样 404。
- **修复**：`.github/workflows/pages.yml` 新增步骤，对 `_site/*/题库页.html` 与 `_site/*/错题集/*.html` 统一 sed `SCGSstudy/katex→katex`、`SCGSstudy/index.html→index.html`（`../`/`../../` 前缀保留，深度自动正确）；验证步骤改为检查 `href|src` 范围内无 `SCGSstudy/`（正文文案与 API 域名 `ai.scgsstudy.top` 不计入）。
- **验证证据**：本地模拟完整装配 `_site` 并执行替换——
  1. `高数/题库页.html`：`href="../katex/katex.min.css"`、`src="../katex/katex.min.js"`、`href="../index.html"`。
  2. `高数/错题集/复习页.html`：`href="../../katex/..."`、`href="../../index.html"`。
  3. 三科全部页面 `(href|src)="[^"]*SCGSstudy/` 残留 = 0；`_site/katex/katex.min.{js,css}`、`_site/index.html` 均存在（Test-Path True）。
- 下一步：push 触发 Pages 重新部署后，在线打开 `https://cheshiping.github.io/College-to-university-exam-question-bank/高数/题库页.html` 复核公式渲染与返回入口跳转。

## 2026-09-17 · 交互动效修复 + 悬浮按钮缩小并加 Tooltip

- **改动文件**：`SCGSstudy/build.py`（三处模板共有的 CSS 一次性替换）+ 重新生成全部产物。
- **随机抽题 hover**：`.toolbar select,.toolbar button` 补 `transition:border-color var(--d-fast) var(--ease-out),background var(--d-fast) var(--ease-out)`（TIKU/REVIEW/WORD 三模板）；`.toolbar button.primary:hover` 显式补 `color:#fff`，杜绝白字浅底不可见。
- **弹框动画根因修复**（`display:none` 切换不触发 transition）：`#passageModal` 由 `display:none→flex` 改为常驻 `display:flex` + `opacity:0;visibility:hidden;pointer-events:none`，`.show` 切换 opacity/visibility（遮罩淡入 + 子卡片 translateY(4px) scale(.96)→0/1）；`#toast` 同理；`#aiPanel` 从纯 display 切换改为 `visibility/opacity/transform translateY(8px) scale(.97)` + `.show` 类，JS 由 `style.display` 改为 `classList.toggle("show",open)`。
- **悬浮按钮缩小一半 + Tooltip**：`#aiFab` 52→26px、`#subFab` 50→26px（font 24/22→12px），`title` 改为 `data-tip` + `aria-label`；按设计系统 §4.14 浮层族加 Tooltip——深底 `#16140F` 白字 12px、padding `6px 10px`、radius-sm、shadow-e2、左缘 8px 间距、300ms 延迟出现、`fast/ease-out` 淡入 + `translateX(-4px)→0`、`pointer-events:none`；`#aiPanel` bottom 80→50px（配合小按钮）。
- **验证证据**：
  1. `python SCGSstudy/build.py` 全量生成成功。
  2. 产物 grep：三科 `题库页.html` 均含 `toolbar button.primary:hover{...color:#fff}`、`#passageModal{display:flex;opacity:0;visibility:hidden}`、`#aiPanel.show`；`复习页.html`/`单词卡.html` 含 toolbar transition + primary:hover color:#fff。
  3. 产物 grep：全部页面（3×题库页、3×复习页、index）含 `#aiFab{...width:26px`、`#subFab ... data-tip="投稿题目" ... width:26px`、`#aiFab::after,#subFab::after{` Tooltip 规则。
  4. 浏览器代理验证：hover/tooltip/弹框动画静态检查 PASS（file:// 导航被浏览器策略拦截，未做运行时截图）。
- 下一步：浏览器（http 或拖入窗口）目视复核 tooltip 出现动效与两个弹框淡入；确认无误后可提交。

## 2026-09-17 · Northpeak 设计系统界面改造（全站）

- 按 `Northpeak-设计系统文档.md` v2.0 改造全部页面样式（仅改视觉风格，保留单列居中刷题布局，未引入后台界面），计划见 `.trae/documents/Northpeak设计系统题库界面改造.md`。
- **改动文件**：`SCGSstudy/build.py`（REVIEW_HTML / TIKU_HTML / WORD_HTML / INDEX_HTML 四个模板的 `<style>` 全部改写为 Northpeak 令牌；SUBJECTS 三科强调色改为 pine 色阶并新增 `__COLOR_D__` 替换逻辑；AI 面板与投稿组件 SUBMIT_HTML 的蓝紫色改为墨绿；JS 内联旧色 #EA6668/#B44244/#9BBBF4 等全部替换为语义色）+ `SCGSstudy/wordbook_tpl.html`、`SCGSstudy/shengci_tpl.html`、`SCGSstudy/contribute.html`（三个独立模板同步改写）。
- **核心决策**：三科强调色统一取自 pine 色阶——计算机 `#046461`、高数 `#457C6C`、英语 `#A1D8D3`，`--accent-d` 统一 `#03514F`；主按钮底 `#046461`；动效按 animate 技能定稿（shake ±3px/280ms、pulse 圆环 ::after、toast/弹窗用 transition+.show 类、hover 140ms `--ease-out` 门控、reduced-motion 降级）。
- **验证证据**：
  1. `python SCGSstudy/build.py` 全量生成成功（计算机 1037 题 / 高数 1219 题 / 英语 853 题 / 单词本 5210 词）。
  2. 产物全局 grep 旧色值（`#22304A|#33475C|#52C41A|#EA6668|#FAAD14|#9BBBF4|#C9A7E8|#7A5AA8|#4F7CF7|#8B5CF6|#3E8C13|#8A5B00|#B44244|#8C6D1F|Roboto`）→ **0 匹配**。
  3. 抽查 13 个页面均含 `--np-pine-600:#046461` / `--ease-out:cubic-bezier(0,0,.2,1)` / `prefers-reduced-motion`；三科 `--accent` 值逐一核对正确（计算机 #046461 / 高数 #457C6C / 英语 #A1D8D3，accent-d 统一 #03514F）。
  4. `git ls-files | Select-String "错题本.md"` → 无输出（错题本未入库）；`git status --short` 仅 14 个预期文件改动（模板 + 产物），无越界文件。
- 下一步：浏览器打开 `SCGSstudy/index.html` 与三科 `题库页.html` / `复习页.html` 目视复核视觉效果与动效；确认无误后可提交。

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