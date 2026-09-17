# Northpeak 设计系统 · 题库界面改造计划

## 一、摘要

按 `Northpeak-设计系统文档.md` v2.0 的视觉语言，将题库三科（计算机 / 高数 / 英语）的全部页面从"白卡 + 各科彩色（蓝/青/紫）+ Roboto"改造为"暖米白画布 + 1px 细边卡片 + pine 墨绿色系 + Inter + 克制动效"的文档式风格。

**明确不做**：不做后台/管理界面（不引入侧栏、顶栏、图表仪表盘布局），保持现有"单列居中、卡片式刷题"的布局，只改视觉风格与组件样式。

**动效策略**：现有交互动效（判对错 shake/pulse、hover 过渡、翻卡、进度条、toast 滑入等）**全部保留并打磨**——参数对齐设计系统 §2.6 动效原语（时长 140/200/280ms、`--ease-out`/`--ease-standard` 曲线、位移 ≤4px、只动 transform/opacity），实现阶段**调用 `animate` 技能**统一设计与书写动效集。

**已确认决策**：
1. 三科保留各自的强调色，但统一取自设计系统的 pine 色阶（与墨绿主题协调）：
   - 计算机 = `#046461`（pine-600 深墨绿）
   - 高数 = `#457C6C`（pine-500 中绿）
   - 英语 = `#A1D8D3`（pine-400 亮青，文字对比用深墨绿 `#03514F` 补足）
2. 主操作按钮（随机抽题 / 存入错题本 / 随机抽词等）底色 = 墨绿 `#046461`。

## 二、现状分析

所有页面由 `SCGSstudy/build.py` 的 Python 模板字符串生成（HTML 是构建产物），另有 3 个独立模板文件：

| 产物 | 生成来源 |
| --- | --- |
| `计算机/题库页.html`、`高数/题库页.html`、`英语/题库页.html` | build.py `TIKU_HTML`（约 L2592） |
| `计算机/错题集/复习页.html`、`高数/...`、`英语/...` | build.py `REVIEW_HTML`（约 L1636） |
| `英语/错题集/单词卡.html` | build.py `WORD_HTML`（约 L2275） |
| `英语/错题集/单词本.html` | build.py 读 `SCGSstudy/wordbook_tpl.html` |
| `英语/错题集/生词本.html` | build.py 读 `SCGSstudy/shengci_tpl.html` |
| `SCGSstudy/index.html`（总入口） | build.py `INDEX_HTML`（约 L3421） |
| `SCGSstudy/contribute.html`（贡献页） | 静态文件，直接编辑 |

**当前旧风格统一特征**：
- `:root{--accent:各科色;--accent-d:#33475C;--text:#1A1B1C;--sub:#6B7280;--bg:#F4F3EE;--card:#FFFFFF;--border:#E4E3DD;}`
- body：Roboto，灰底 `#F4F3EE`，白卡片
- 判对错：`#52C41A` 绿 / `#EA6668` 红 / `#FAAD14` 琥珀，带 `shake`/`pulse` 关键帧动画
- 字重多用 700，数字非等宽

## 三、改造方案

### 3.1 共享设计令牌（新建 `NP_ROOT` CSS 常量）

在 build.py 顶部新增一段 `NP_ROOT` 字符串常量，注入 4 个模板的 `<style>` 开头，替换原 `:root{...}` 行。独立模板文件同步复制这段（值相同）。

令牌内容（改编自设计文档 §8.1，符合暖画布 + pine 强调）：

```css
:root{
  /* 暖中性 */
  --np-neutral-0:#FFFFFF; --np-neutral-25:#FCFBFA; --np-neutral-50:#F8F7F5;
  --np-neutral-100:#F1EFEA; --np-neutral-200:#E6E3DC; --np-neutral-300:#D5D1C8;
  --np-neutral-400:#ABA69C; --np-neutral-500:#837E75; --np-neutral-600:#605B53;
  --np-neutral-700:#3D3833; --np-neutral-800:#24211D; --np-neutral-900:#16140F;
  --np-neutral-950:#0B0B0A;
  /* pine 色阶（品牌） */
  --np-pine-50:#F1F9F5; --np-pine-100:#DEEFE5; --np-pine-200:#CCF8E7;
  --np-pine-300:#B4CFCA; --np-pine-400:#A1D8D3; --np-pine-500:#457C6C;
  --np-pine-600:#046461; --np-pine-700:#03514F; --np-pine-800:#023C3B; --np-pine-900:#022A29;
  /* 语义原色（暖调） */
  --np-green-100:#DFF2E6; --np-green-600:#1B7A4B; --np-green-700:#14603B;
  --np-amber-100:#FBEDD8; --np-amber-600:#B87A1C; --np-amber-700:#8E5C10;
  --np-red-100:#FBE4E0;   --np-red-600:#C0392B;   --np-red-700:#9A2C20;
  --np-blue-100:#E4EDF4;  --np-blue-600:#35678F;
  /* 语义色 + 旧变量映射（保持既有 var() 引用有效） */
  --accent:__COLOR__;   /* 三科各自 pine 色阶强调色 */
  --accent-d:__COLOR_D__; /* 对应深一档，见 3.2 */
  --text:#0B0B0A; --sub:#605B53; --bg:#F8F7F5; --card:#F8F7F5; --border:#E6E3DC;
  --bg-subtle:#F1EFEA; --bg-hover:#F1EFEA; --bg-active:#E6E3DC; --bg-selected:#DEEFE5;
  --border-strong:#D5D1C8;
  /* 阴影 / 动效 */
  --shadow-e1:0 1px 2px rgba(11,11,10,.05);
  --shadow-e2:0 4px 12px rgba(11,11,10,.07);
  --shadow-e3:0 8px 24px rgba(11,11,10,.09);
  --d-fast:140ms; --d-base:200ms; --d-slow:280ms;
  --ease-out:cubic-bezier(0,0,.2,1);
  --ease-standard:cubic-bezier(.2,.8,.2,1);
  --font-sans:'Inter','PingFang SC','HarmonyOS Sans SC','Microsoft YaHei','Segoe UI',sans-serif;
  --radius-sm:6px; --radius-md:8px; --radius-lg:12px; --radius-full:999px;
}
/* 数字等宽 */
.stat .n, .frow .ct, .daily-count, .daily-total b, .fprog, .posinfo, .ct{font-variant-numeric:tabular-nums;}
```

### 3.2 三科强调色（修改 build.py `SUBJECTS` 的 color + 新增 color_d）

| 科目 | `color`（accent） | `color_d`（accent-d） | 依据 |
| --- | --- | --- | --- |
| 计算机 | `#046461` pine-600 | `#03514F` pine-700 | 主品牌色 |
| 高数 | `#457C6C` pine-500 | `#03514F` pine-700 | 中绿 |
| 英语 | `#A1D8D3` pine-400 | `#03514F` pine-700 | 亮青，深色文字补对比 |

`build_tiku`/`build_review` 等函数中把 `__COLOR__` 替换保留，并新增 `__COLOR_D__` 替换。INDEX_HTML 中 `__TIKU_CARDS__`/`__WORD_CARDS__` 的卡片 `--c` 内联值同步用新色；`meta theme-color` 改 `#046461`。

### 3.3 组件样式映射（所有模板统一执行）

| 现状 class | 新样式（Northpeak 对应规范） |
| --- | --- |
| `body` | 背景 `var(--bg)`（#F8F7F5），字体 `--font-sans`，行高 1.6 保留 |
| `h1` | 24px / 600（介于设计 h1 26 与文档式克制之间），色 `--text` |
| `.back` | 12px `--sub`，hover 转 accent-d |
| `.sub` | 13px `--sub` |
| `.stat`（统计卡） | 卡 = 暖表面 `--card` + 1px `--border` + 圆角 `--radius-lg`(12px) + 内边距 12px，无阴影；`.n` 22px/600 等宽；`.l` 12px `--sub`；`.stat.hot` 边框 `var(--accent)` |
| `.toolbar` 按钮 / select（§4.1 次级按钮 + §4.2 输入） | 13px、内边距 7px 10px、1px `--border`、圆角 `--radius-md`(8px)、底 `--card`、字 `#3D3833`；hover：底 `--bg-hover` + 边框 `--border-strong`，140ms `--ease-out`；focus 描边 `rgba(4,100,97,.30)` |
| `.toolbar button.primary` / `.basket .actions .exp` / `.toolbar a.go` / `#btnExport`（主按钮） | 底 `#046461`、白字、边框同底、600；hover 深一档 `#03514F`；active `transform:scale(.97)` |
| `.toolbar button.on` | 选中态：底 `--bg-selected`(#DEEFE5) + 字 `#03514F` + 边框 `#B4CFCA`，600 |
| `.toolbar button.danger` | 底 `#FBE4E0` + 字 `#9A2C20` + 边框 `#C0392B`，600 |
| `.card`（题目卡） | `--card` + 1px `--border` + `--radius-lg` + 内边距 16px，无阴影 |
| `.meta` | gap 6px 保留 |
| `.tag`（§4.5 状态胶囊） | 高 22px、内边距 2px 8px、`--radius-full`、12px/500。主题标签 = 底 `#DEEFE5` 字 `#03514F`；`.qid`/`.src` = 底 `--bg-subtle` 字 `--sub`；`.review`(待复习) = 底 `#FBE4E0` 字 `#9A2C20`；`.mastered`(已掌握) = 底 `#DFF2E6` 字 `#14603B`；`.err`(错误次数) = 底 `#FBEDD8` 字 `#8E5C10`；`.reason` = 底 `#E4EDF4` 字 `#35678F` |
| `.material`（阅读材料） | 底 `--bg-subtle` + 左 3px `var(--accent)` + 圆角 0 8px 8px 0 |
| `.word-clickable` | 边框虚线下划线 `#B4CFCA`、字 `#03514F`，hover 底 `#DEEFE5`；`.word-saved` 转 danger（底 `#FBE4E0`、字 `#9A2C20`） |
| `.qtext` | 15px/600 保留 |
| `.opts li`（选项，§4.1 交互态） | 底 `#FCFBFA`、1.5px `--border`、圆角 10px、margin 8px；hover：边框 `var(--accent)` + 底 `--bg-selected` 半透明；`.sel` = 边框 `var(--accent-d)` + 底 `#DEEFE5`；`.right` = 边框 `#1B7A4B` 底 `#DFF2E6`；`.wrong` = 边框 `#C0392B` 底 `#FBE4E0`；`.opt-letter` 24px 圆角 6px 底 `--bg-subtle`，选中态底 accent-d 白字 |
| `@keyframes shake/pulse` | **保留并打磨**：shake 振幅收窄到 ±3px（≤4px 位移）、时长 280ms `--ease-out`；pulse 改为柔和圆环扩散（140ms 扩散 + 渐隐，色用 `rgba(27,122,75,.35)` 成功语义），重绘色板对齐新语义色；具体参数由 `animate` 技能统一输出 |
| `.answer` / `.answer .k` | 底 `#DEEFE5`、左 3px `var(--accent-d)`、圆角 0 8px 8px 0；`.k` 700→600 色 accent-d |
| `.feedback.ok/.no` | ok = 底 `#DFF2E6` 字 `#14603B`；no = 底 `#FBE4E0` 字 `#9A2C20`；圆角 `--radius-md` |
| `.btns button`（做对/做错/存疑） | `.g` = 底 `#DFF2E6` 边框 `#1B7A4B` 字 `#14603B`；`.r` = 底 `#FBE4E0` 边框 `#C0392B` 字 `#9A2C20`；`.d` = 底 `#FBEDD8` 边框 `#B87A1C` 字 `#8E5C10` |
| `.nav button` / `.fnav button` | 次级按钮样式同 toolbar，disabled opacity .35 |
| `.basket` | `--card` + 1px 虚线 `var(--accent)`（英语页虚线用 `#A1D8D3`）+ `--radius-lg` |
| `#toast` / `.toast`（§4.25） | 白底 `#FFFFFF` + 1px `--border` + `--shadow-e3` + 圆角 `--radius-md`，固定右下 24px，max-width 340px；进入用 transition（opacity + translateX） |
| `.empty`（§4.27 空状态） | 居中、`--sub`、13px、虚线 `--border`、圆角 `--radius-lg`、内边距 30px |
| `.hint` | 11.5px `--sub` |
| `.progress` / `.fbar` / `.frow .fbar i` | 轨道底 `--bg-subtle`、高 6-10px、圆角 sm；填充 `var(--accent)`，transition width 200ms |
| `.factor .t` / `.frow .nm` | 11px `--sub`；`.frow .ct` 600 等宽 |
| `.similar a` | 字 `var(--accent-d)`，hover 下划线 |
| `#passageModal` 内联样式 | 遮罩 `rgba(11,11,10,.45)`，弹窗白底 `#FFFFFF` 圆角 `--radius-lg`(12px)（符合 §4.14 Dialog 白底） |

**单词卡（WORD_HTML）专属**：`.word` 26→28px/600；`.phon` 13px `--sub`；`.detail .pos` 字 accent-d 600；`.nav button.k/.f/.n` 用上表成功/警示/危险三色。

**单词本 / 生词本（wordbook_tpl / shengci_tpl）**：`.stat .n` 等宽；`.alpha button.on`、`.toolbar button.on` 选中态同 §3.3；`.wl li` 白卡改暖表面 + 1px 边框 + 圆角 `--radius-md`；`.wd` 600；`.star` 色 `var(--accent)`、`.star.on` 用 danger 粉调 `#EAA7B2` 保留；`.tag-通用/四级/专升本` 分别映射成功/警示/accent 胶囊（底 `#DFF2E6`/`#FBEDD8`/`#DEEFE5`，字 `#14603B`/`#8E5C10`/`#03514F`）；`.fcard` 圆角 `--radius-lg`、`.fw` 34px/600；`.fctrl button.known/so/unk` 同上三色；`.toast` 同 §4.25。

**总入口 index（INDEX_HTML）**：`.sc` 卡 = 暖表面 + 1px 边框 + `--radius-lg`，hover 边框转 `--border-strong` + `--shadow-e1` 微抬；`.sc.sc2`（刷题入口）改实线边框（去掉 dashed，靠图标 chip 区分）；`.sc-icon` 38px 圆角 10px 底 `#DEEFE5` 字 `var(--c)`（三科 pine 色）；`.sc-name` 16px/600；`.sc-stat` 12px/600 `var(--accent-d)`；`.h2` 组标题 14px/600 `#3D3833`；📌 学习数据提示条 → 警示样式（底 `#FBEDD8` 边框 `#B87A1C` 字 `#8E5C10` 圆角 `--radius-md`）；`.daily-count` 20px/600 等宽；`.quality-ok` 字 `#14603B`、`.quality-bad`/`.quality-list .error` 字 `#9A2C20`、`.warning` 字 `#8E5C10`；`.note` 虚线边框卡片同 §4.27。

**贡献页 contribute.html**：`body` 暖画布 + `--font-sans`；`.card` 暖表面 + 1px 边框 + `--radius-lg`；`label` 14px/600；`select/input/textarea` 底 `#FCFBFA` 1.5px `--border` 圆角 10px，focus 边框 `#046461`；`.subject-btn`/`.type-tag` 选中态 = 边框 `#046461` + 底 `#DEEFE5` + 字 `#03514F`；`.btn-primary` 底 `#046461` 白字 600；`.steps` 底 `#DEEFE5` 左 3px `#046461`；`.upload-hint` 警示样式。

### 3.4 动效统一（§2.6 + `animate` 技能）

**实现前置**：动效设计与书写**调用 `animate` 技能**（按"该不该动 → 目的 → 动什么属性 → 曲线时长 → 打断与退出"顺序）输出一套全站统一的动效集，再落到各模板。

**动效集清单**（全部保留现有动效，参数对齐设计系统原语）：

| 动效 | 参数（设计系统令牌） |
| --- | --- |
| hover / 状态切换（按钮、选项、卡片、链接） | `transition: color/background/border 140ms var(--ease-out)`，只动颜色/背景/边框 |
| 判错 `shake` | 保留关键帧，振幅收窄 ±3px，时长 280ms，`--ease-out` |
| 判对 `pulse` | 保留，柔和圆环扩散 + 渐隐（成功语义色），重绘色板 |
| 选项 `:active` | `transform:scale(.97)`，140ms 按压反馈 |
| 进度条 / 错因条形 | `transition: width 200ms var(--ease-out)`（数据生长用 ease-out） |
| toast 滑入 | 进入 `opacity 0→1` + `translateX(100%)→none`，280ms `--ease-out`；**用 `transition` 不用 `@keyframes`**（可被连续触发，§2.6 规则 2） |
| 弹窗（passageModal） | 遮罩淡入 200ms + 弹窗 `translateY(4px) scale(.96)→none` 200ms `--ease-out` |
| 卡片 hover（入口页） | 边框转 `--border-strong` + `--shadow-e1` 微抬，140ms |
| 降级 | `@media (prefers-reduced-motion: reduce)`：全部 duration 压到 `.01ms`、移除 transform（§2.6 降级段） |

### 3.5 实施步骤与文件清单

**步骤 0（动效前置）**：调用 `animate` 技能，确定全站动效集（§3.4 清单的参数定稿 + 是否新增微交互）。

**修改（4 个）**：
1. `SCGSstudy/build.py` — 新增 `NP_ROOT` 常量 + `SUBJECTS` 配色（含 `color_d`）+ 4 个模板（TIKU_HTML / REVIEW_HTML / WORD_HTML / INDEX_HTML）的 `:root` 与组件 CSS 改写（含动效集）+ `__COLOR_D__` 替换逻辑
2. `SCGSstudy/wordbook_tpl.html`
3. `SCGSstudy/shengci_tpl.html`
4. `SCGSstudy/contribute.html`

**重新生成（不手改）**：`python SCGSstudy/build.py` → 计算机/高数/英语 的 `题库页.html`、`复习页.html`、`英语/错题集/单词卡.html`、`单词本.html`、`生词本.html`、`SCGSstudy/index.html`

**记录**：`progress.md` 追加改造证据与下一步。

## 四、假设与决策

- 不改任何数据源 `.md`（铁律 2）；HTML 全部由 build.py 重新生成。
- 不引入侧栏/顶栏/图表布局——保持文档式单列刷题布局，只换视觉语言（用户已确认）。
- 三科强调色取 pine 色阶（用户已确认），英语亮青 `#A1D8D3` 仅用于边框/填充/图标，文字对比一律用深墨绿 `#03514F`。
- 主按钮统一墨绿 `#046461`（用户已确认）。
- 卡片与画布同色 `#F8F7F5` + 1px 边框（设计文档 §4.6），交互选项底用 `#FCFBFA` 轻微区分（避免纯白冷感）。
- 字重上限 600（设计文档 §2.2），数字开 tabular-nums。
- **现有交互动效全部保留**（用户反馈），参数对齐设计系统 §2.6 动效原语（时长/曲线/≤4px 位移），由 `animate` 技能统一编写；不做"删除动效"的保守处理。
- 弹窗/浮层（passageModal）保持白底（§4.14 Dialog 规范），遮罩改暖黑 45%。

## 五、验证步骤

1. `python SCGSstudy/build.py`（PowerShell；如 `python` 不可用则 `py SCGSstudy/build.py`）——无报错，确认输出 7 类 HTML。
2. 抽查 `计算机/题库页.html` 与 `SCGSstudy/index.html`：`<style>` 内含 `--np-pine-600` 令牌、无 `#9BBBF4`/`#52C41A`/`#EA6668` 残留。
3. `git status --short`：确认无 `错题本.md` 被跟踪、HTML 产物已更新（符合 AGENTS.md 验证要求）。
4. `progress.md` 记录改动文件、验证结果、下一步。
