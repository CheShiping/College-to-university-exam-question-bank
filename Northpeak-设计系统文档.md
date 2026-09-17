# Northpeak 设计系统 · 设计文档 v2.0

> 本文档是 Northpeak 产品线的**界面契约**：向上统一所有页面与组件的视觉语言，向下约束令牌、动效与无障碍行为。
> 所有令牌以 **CSS 变量** 为唯一事实来源（Single Source of Truth），Figma 变量、Tailwind 主题、组件库均从本文档映射。
> **可执行原型**：`Northpeak · Overview 原型.html`（单文件、零外部依赖，6 个路由页 + 完整组件样张）是本文档的参考实现；文档与原型出现分歧时，**以本文档为准，并回头修原型**。

**说明与假设**
1. 品牌名取自原型中的产品名 `Northpeak`。若公司名称不同，请全局替换 `np-` 前缀与品牌名，其余内容不受影响。
2. v1.1 依据品牌方给定色值重构色彩体系：画布 `#F8F7F5`，墨绿主色 `#046461`，并正式纳入冷暖渐变梯度（`#CCF8E7 / #A1D8D3 / #B4CFCA / #DEEFE5 / #457C6C`）。
3. 除品牌方给定的 6 个色值外，其余同族色阶（`pine-50/700/800/900`、`neutral-*`）为按同色相推导的配套值，需在实机上做一次目视校准。
4. v2.0 起，**原型从"参考图"升级为"参考实现"**：文档新增的每一条动效原语、组件状态、无障碍属性，都在原型的组件样张页（Components）里有可运行的对照物。新增组件前先看原型，能避免规格与实现两张皮。

**变更记录**
- **v2.0**（本次）：与原型同步。① 把「动效」从三条原则扩为一套**原语体系**（进入/退出曲线、`transition` vs `keyframes` 的取舍、`transform-origin` 归属、延迟隐藏技巧、例外清单补全）；② 组件规范由 15 节扩到 **28 节**（§4.1–§4.28），补齐 Tabs、Segmented、Accordion、Checkbox/Radio/Switch、Slider、Progress、Form Field、Chip、Breadcrumb、Alert、Toast、Command Palette、Kbd，以及 Stat Tile / 横向条形 / 热力图 / 看板四个业务零件；③ 布局章节落到**真实的 6 个页面与 4 个断点**，新增路由清单；④ 修正 `--np-color-bg-hover` 与画布同色导致的 hover 失效（根因级修复）；⑤ §8.1 补全此前只在正文出现、未落进 CSS 块的令牌（`--np-duration-chart` / `--np-ease-out` / 图表与头像尺寸）；⑥ 新增 §8.2「动效原语」可直接复制的 CSS。
- **v1.1**：画布改暖米白 `#F8F7F5`；中性色由冷灰改为暖灰；品牌色改为青调墨绿 `#046461` 并扩充为 10 级色阶；新增「渐变 Gradient」令牌族（8 条）；侧栏活动项改为透明白色标记；状态色与图表色板做暖调对齐。
- **v1.0**：首版，提炼自原型图。

---

## 1. 设计语言总览

### 1.1 定位

Northpeak 是一套**面向 B2B 数据产品的界面系统**。核心场景是长时间盯盘、多维对比、快速定位异常。因此界面不追求视觉张力，而追求**信息的密度与秩序**：数据是主角，界面是安静的容器。

### 1.2 风格关键词

| 关键词 | 含义 | 在原型中的体现 |
| --- | --- | --- |
| Warm Canvas | 画布是**暖米白**，不是冷灰，界面有纸质温度 | 内容区 `#F8F7F5` |
| Cool Accent | 强调色是**偏青的墨绿**，与暖画布形成温度互补 | 折线、面积图 `#046461` |
| Deep Sidebar | 侧栏**近黑**，用透明白表达层次，不引入第二个色相 | `#0B0B0A` + `rgba(255,255,255,.08)` |
| Quiet Luxury | 克制的质感，靠留白、对齐、微差层次取胜 | 卡片仅 1px 细边，几乎不用阴影 |
| Tabular Data | 数字等宽对齐，可纵向扫描 | 表格数值右对齐、等宽数字 |
| Mint Gradient | 浅薄荷到深墨绿的渐变是唯一的"发光"手段 | 面积图填充、品牌区块 |
| Muted Data | 多序列图表使用同色相阶梯 + 低饱和大地色 | 深墨绿 / 中绿 / 亮青 / 青灰 / 暖灰 |
| Quiet Motion | 动效只解释"状态变了"，不做装饰。位移 ≤ 4px，只动 `transform` 与 `opacity` | 弹层 `zoom 96→100` + 上移 4px，140–200ms |
| Layered Density | 同一页提供「概览 → 拆解 → 明细」三种密度，用户自己选深浅 | Overview 的 KPI / 图表 / 表格；Analytics 的统计块 / 漏斗 / 热力图 |

### 1.3 八条设计原则

1. **数据先于装饰。** 任何视觉元素若不能帮助理解数据，就删除。禁止发光按钮、玻璃拟态、霓虹描边、彩虹渐变。
2. **暖画布，冷强调。** `#F8F7F5` 暖米白是底色，墨绿 `#046461` 是唯一强色。二者的温度差就是整套 UI 的张力来源——无需再加第三个色相。
3. **层次靠对比，不靠阴影。** 层级用背景明度差（`#0B0B0A` → `#F8F7F5` → `#FFFFFF`）+ 1px 细边表达。阴影只服务于真正的浮层。
4. **侧栏用透明度分层。** 近黑侧栏内不使用任何品牌色，选中、悬浮、分隔一律用白色透明度（`.04 / .08 / .12`）表达。
5. **对齐即秩序。** 全站 4px 基准网格；数字右对齐、标签左对齐、图标与首行文字基线对齐。
6. **颜色必须有语义。** 绿色不总是好、红色不总是坏——趋势色的语义由**指标方向**决定（见 2.1.5）。
7. **shadcn 实现规范。** 组件层、令牌命名、Tailwind 主题、无障碍行为对齐 **shadcn/ui + Radix**：只用 `--background/--foreground/--primary/...` 这一套语义令牌，交互组件一律基于 Radix 原语，禁止手写弹层与 `:hover` 散射态（Tailwind 写法见 §8.4）。
8. **动效解释状态，不做装饰。** 一屏里动效只用来回答"刚才发生了什么"。位移 ≤ 4px、只动 `transform` 与 `opacity`（4 处例外见 §2.6）；**会被连续触发的元素（Toast、表格行高亮）一律用 `transition` 而非 `@keyframes`**——动画只播一次，重放时 `@keyframes` 会丢帧。曲线统一取 `--np-ease-*`，时长取 `--np-duration-*`。

### 1.4 视觉基因速览

```
┌──────────┬────────────────────────────────────────────────┐
│          │  Topbar 64px  标题区 + (范围选择 · 搜索 · 通知)  │
│ 近黑侧栏  ├────────────────────────────────────────────────┤
│ #0B0B0A  │  暖米白画布 #F8F7F5  padding 32  gap 24         │
│ 240px    │  ┌────────────┐ ┌────────────┐ ┌────────────┐  │
│ (收起 64) │  │ 暖卡 #F8F7F5│ │ 暖卡 #F8F7F5│ │ 暖卡 #F8F7F5│  │  ← 与画布同色，靠 1px 暖灰边分离
│          │  │ 指标 + 火花│ │ 指标 + 火花│ │ 指标 + 火花│  │
│ 活动项:   │  └────────────┘ └────────────┘ └────────────┘  │
│ 白·8%底   │  ┌──────────────────────┐ ┌──────────────────┐ │
│ 白·70%条  │  │ 面积图（span 8）        │ │ 堆叠柱（span 4）   │ │
│          │  │ #CCF8E7→#A1D8D3→      │ │ #046461/#457C6C/  │ │
│ 分隔:8%白 │  │ #046461 渐变填充       │ │ #A1D8D3/#B4CFCA   │ │
│          │  └──────────────────────┘ └──────────────────┘ │
│ 底部用户  │  ┌────────────────────────────────────────────┐│
│ + 套餐卡  │  │ 数据表：状态胶囊 + 等宽数字 + 分页           ││
└──────────┴────────────────────────────────────────────────┘
   ↑ 收起态：图标居中，悬浮弹出右侧 Tooltip（深底白字 12px / 延迟 300ms）
```

**六个页面各有一套视觉重心**（详见 §3.3）：Overview = KPI + 面积图 + 表格；Analytics = 统计块 + 漏斗 + 热力图；Projects = 看板；Reports = 告警 + 明细表 + 手风琴；Components = 组件样张；Settings = 二级导航 + 表单分组。

---

## 2. 设计令牌 Design Tokens

令牌分三层，**组件层只能引用语义层，语义层只能引用基础层**，禁止跨层直引。

```
基础层 Primitive  →  语义层 Semantic  →  组件层 Component
--np-pine-600          --np-color-accent      --np-btn-primary-bg
（固定色值，不用）      （表达用途，业务用）     （组件内部使用）
```

### 2.1 色彩

#### 2.1.1 基础色阶 Primitive

**暖中性 Neutral（色相 ≈ 40°，暖米灰）**

> 关键：画布为暖色，因此所有中性色都必须带同向暖调。**禁止在暖画布上混用冷灰 `#F5F5F5` 类色值**，会立刻显脏。

| 令牌 | 色值 | 用途示例 |
| --- | --- | --- |
| `--np-neutral-0` | `#FFFFFF` | 纯白：仅用于深底上的文字/图标（`text-inverse`）与极少强对比内嵌元素，**不用于卡片表面** |
| `--np-neutral-25` | `#FCFBFA` | 预留极浅暖白；语义层当前以 `neutral-100` 作表头/内嵌区块 |
| `--np-neutral-50` | `#F8F7F5` | **应用画布**（暖米白，同时是卡片底） |
| `--np-neutral-100` | `#F1EFEA` | 骨架屏、禁用底 |
| `--np-neutral-200` | `#E6E3DC` | 分隔线、输入框边框、卡片描边 |
| `--np-neutral-300` | `#D5D1C8` | 强分隔、控件描边 |
| `--np-neutral-400` | `#ABA69C` | 占位文字、禁用图标 |
| `--np-neutral-500` | `#837E75` | 三级文字 |
| `--np-neutral-600` | `#605B53` | 二级文字 |
| `--np-neutral-700` | `#3D3833` | 正文次级标题 |
| `--np-neutral-800` | `#24211D` | 深色浮层、深底悬浮态 |
| `--np-neutral-900` | `#16140F` | 主按钮底、中性墨黑 |
| `--np-neutral-950` | `#0B0B0A` | **侧栏近黑**、主文字色 |

**品牌色 Pine（青调墨绿）**

> 6 个加粗色值为品牌方给定，其余为同色相推导。**300 与 400 是"同亮度、不同饱和度"的一对**：大面积铺色用 300（低饱和青灰），小面积描边/描点用 400（高饱和亮青）。

| 令牌 | 色值 | 来源 | 用途示例 |
| --- | --- | --- | --- |
| `--np-pine-50` | `#F1F9F5` | 推导 | 极浅底、选中行底 |
| `--np-pine-100` | `#DEEFE5` | **给定** | 浅底强调块、信息块底、表格选中行 |
| `--np-pine-200` | `#CCF8E7` | **给定** | 明亮薄荷：高亮底、渐变起点、图表最浅序列 |
| `--np-pine-300` | `#B4CFCA` | **给定** | 青灰（低饱和）：大面积柔和填充、次级序列 |
| `--np-pine-400` | `#A1D8D3` | **给定** | 亮青（高饱和）：图表次序列、描点边、装饰描边 |
| `--np-pine-500` | `#457C6C` | **给定** | 中间调：hover、次级/深底上的强调文字 |
| `--np-pine-600` | `#046461` | **给定** | **主品牌色**：折线、主序列、关键数值强调 |
| `--np-pine-700` | `#03514F` | 推导 | 强调文字（浅底上） |
| `--np-pine-800` | `#023C3B` | 推导 | 深底强调、深色区块底 |
| `--np-pine-900` | `#022A29` | 推导 | 深墨绿区块、深色主题底 |

**语义原色 Semantic Raw（暖调校准）**

| 令牌 | 色值 | 说明 |
| --- | --- | --- |
| `--np-green-100 / 600 / 700` | `#DFF2E6` / `#1B7A4B` / `#14603B` | 正向 |
| `--np-amber-100 / 600 / 700` | `#FBEDD8` / `#B87A1C` / `#8E5C10` | 警示 |
| `--np-red-100 / 600 / 700` | `#FBE4E0` / `#C0392B` / `#9A2C20` | 负向 / 阻断 |
| `--np-blue-100 / 600` | `#E4EDF4` / `#35678F` | 中性信息、链接（次要） |

#### 2.1.2 语义色 Semantic

| 令牌 | 引用 | 说明 |
| --- | --- | --- |
| `--np-color-bg-canvas` | `#F8F7F5` | **应用画布（暖米白）** |
| `--np-color-bg-surface` | `neutral-50` | 卡片 / 面板（**与画布同色 `#F8F7F5`**，靠边框分离） |
| `--np-color-bg-surface-subtle` | `neutral-100` | 表头、内嵌区块（比画布略深一阶） |
| `--np-color-bg-inverse` | `neutral-950` | **侧栏近黑 `#0B0B0A`** |
| `--np-color-bg-hover` | `neutral-100` | 行/项 hover。**不得回落 `neutral-50`**：它同时是画布与卡片底，用在暖画布上等于没有 hover |
| `--np-color-bg-active` | `neutral-200` | 行/项 按下（比 hover 再深一阶，维持"降 1 阶"语言） |
| `--np-color-bg-selected` | `pine-100` | 选中行 `#DEEFE5` |
| `--np-color-bg-overlay` | `rgba(11,11,10,.45)` | 弹窗遮罩 |
| `--np-color-border-default` | `neutral-200` | 默认边框 |
| `--np-color-border-strong` | `neutral-300` | 输入框 / 强调分割 |
| `--np-color-border-subtle` | `neutral-100` | 表格行分隔线 |
| `--np-color-text-primary` | `neutral-950` | 标题、数值 |
| `--np-color-text-secondary` | `neutral-600` | 副标题、表头 |
| `--np-color-text-tertiary` | `neutral-500` | 辅助说明、时间戳 |
| `--np-color-text-disabled` | `neutral-400` | 禁用 |
| `--np-color-text-inverse` | `neutral-0` | 深底上的文字 |
| `--np-color-text-inverse-muted` | `rgba(255,255,255,.55)` | 侧栏未选中文字 |
| `--np-color-accent` | `pine-600` | 品牌强调 `#046461` |
| `--np-color-accent-hover` | `pine-500` | `#457C6C` |
| `--np-color-accent-subtle` | `pine-100` | `#DEEFE5` |
| `--np-color-action-primary-bg` | `neutral-900` | **主按钮底（墨黑）** |
| `--np-color-action-primary-bg-hover` | `neutral-800` | |
| `--np-color-focus-ring` | `rgba(4,100,97,.30)` | 聚焦环（品牌墨绿 30%） |
| `--np-color-success / -bg` | `green-700` / `green-100` | 文字 `#14603B` / 底 `#DFF2E6` |
| `--np-color-warning / -bg` | `amber-700` / `amber-100` | 文字 `#8E5C10` / 底 `#FBEDD8` |
| `--np-color-danger / -bg` | `red-700` / `red-100` | 文字 `#9A2C20` / 底 `#FBE4E0` |
| `--np-color-info / -bg` | `blue-600` / `blue-100` | 文字 `#35678F` / 底 `#E4EDF4` |
| `--np-color-trend-up` | `green-600` | 指标向好 `#1B7A4B` |
| `--np-color-trend-down` | `red-600` | 指标向差 `#C0392B` |

**侧栏专用（透明白体系）**

| 令牌 | 值 | 用途 |
| --- | --- | --- |
| `--np-color-nav-bg` | `#0B0B0A` | 侧栏底（近黑） |
| `--np-color-nav-divider` | `rgba(255,255,255,.08)` | 分组分隔线 |
| `--np-color-nav-item-hover-bg` | `rgba(255,255,255,.05)` | 未选中项悬浮 |
| `--np-color-nav-item-active-bg` | `rgba(255,255,255,.08)` | **活动项底（透明白）** |
| `--np-color-nav-item-pressed-bg` | `rgba(255,255,255,.12)` | 按下 |
| `--np-color-nav-indicator` | `rgba(255,255,255,.70)` | **活动项左侧 2px 标记（透明白）** |
| `--np-color-nav-text` | `rgba(255,255,255,.55)` | 未选中文字/图标 |
| `--np-color-nav-text-active` | `#FFFFFF` | 选中文字/图标 |
| `--np-color-nav-badge-bg` | `rgba(255,255,255,.12)` | 计数徽标底 |

#### 2.1.3 数据可视化色板

多序列图表按顺序取色。**前 4 位是主序列**（同色相阶梯，彼此天然和谐），后 4 位为扩展的低饱和大地色。整体保持 HSL 饱和度 ≤ 45%（除 `#046461`）。

| 序位 | 令牌 | 色值 | 原型对应 |
| --- | --- | --- | --- |
| 1 | `--np-chart-series-1` | `#046461` | Organic Search（深墨绿） |
| 2 | `--np-chart-series-2` | `#457C6C` | 中间调墨绿 |
| 3 | `--np-chart-series-3` | `#A1D8D3` | Direct（亮青） |
| 4 | `--np-chart-series-4` | `#B4CFCA` | Referral（青灰） |
| 5 | `--np-chart-series-5` | `#C9C5BC` | Other（暖灰） |
| 6 | `--np-chart-series-6` | `#8A9E96` | 扩展：灰绿 |
| 7 | `--np-chart-series-7` | `#B58C7E` | 扩展：陶土褐 |
| 8 | `--np-chart-series-8` | `#D4C3A8` | 扩展：沙色 |

**图表辅助色**

| 令牌 | 色值 | 用途 |
| --- | --- | --- |
| `--np-chart-grid` | `#ECEAE5` | 水平网格线（暖灰，仅水平） |
| `--np-chart-axis-text` | `--np-neutral-500` | 轴标签 11–12px |
| `--np-chart-line` | `--np-pine-600` `#046461` | 主折线 2px |
| `--np-chart-area` | 见 `--np-gradient-area` | 面积填充（多色标渐变） |
| `--np-chart-dot` | `#FFFFFF` | 描点填充（2px 主色边） |
| `--np-chart-tooltip-bg` | `#FFFFFF` | 详情浮层 |

#### 2.1.4 渐变 Gradient

渐变是本系统**唯一允许的"发光/氛围"手段**，用来把浅薄荷 `#CCF8E7` 一路过渡到深墨绿 `#046461`。

| 令牌 | 定义 | 用途 |
| --- | --- | --- |
| `--np-gradient-brand` | `linear-gradient(135deg, #CCF8E7 0%, #A1D8D3 32%, #457C6C 68%, #046461 100%)` | 品牌区块、启动页、空状态插画、营销卡 |
| `--np-gradient-brand-soft` | `linear-gradient(135deg, #DEEFE5 0%, #CCF8E7 55%, #A1D8D3 100%)` | 浅底强调块、图表容器底、标签底 |
| `--np-gradient-area` | `linear-gradient(180deg, rgba(4,100,97,.30) 0%, rgba(161,216,211,.14) 45%, rgba(4,100,97,0) 100%)` | **面积图填充（垂直）** |
| `--np-gradient-spark` | `linear-gradient(180deg, rgba(4,100,97,.22) 0%, rgba(204,248,231,0) 100%)` | KPI 火花线填充 |
| `--np-gradient-sage` | `linear-gradient(160deg, #DEEFE5 0%, #B4CFCA 100%)` | 青灰柔和大面积底 |
| `--np-gradient-ink` | `linear-gradient(180deg, #023C3B 0%, #022A29 60%, #0B0B0A 100%)` | 深色区块、深色主题页头 |
| `--np-gradient-nav` | `linear-gradient(90deg, rgba(255,255,255,.10) 0%, rgba(255,255,255,.04) 100%)` | 侧栏活动项底（替代纯色） |
| `--np-gradient-glow` | `radial-gradient(120% 100% at 50% 0%, rgba(204,248,231,.28) 0%, rgba(4,100,97,0) 70%)` | 顶部聚光，用于空状态/引导页 |

**渐变规则**
1. **使用范围**：仅限 ① 大面积背景 ② 图表填充 ③ 品牌/空状态插画。**禁止**用于按钮底、文字、图标、边框、状态胶囊、表格行。
2. **色标来源**：只能取自 `pine-100 → pine-600` 阶梯 + `neutral` 家族，**不得引入色相外的颜色**（禁止紫/粉/蓝渐变）。
3. **方向统一**：块面用 `135deg`（斜向），图表填充与深色区用 `180deg`（垂直）。全站不出现 `45deg` 及其他方向。
4. **色标数量**：≥ 3 个，保证过渡是"薄荷→青→墨绿"的自然下沉，而不是两点线性插值。
5. **对比度**：渐变跨度明度差 > 60% 时，其上的文字必须落在浅端，或加 `rgba(11,11,10,.35)` 遮罩，保证 4.5:1。
6. **面积上限**：同屏渐变覆盖面积 ≤ 20%。渐变是调味，不是主菜。

#### 2.1.5 色彩使用规则

- **温度互补是核心。** 暖画布 `#F8F7F5` + 冷强调 `#046461`。不要再引入第三种温度（如冷蓝底、冷紫）。中性色一律取 `--np-neutral-*` 暖灰。
- **卡片与画布同色。** 卡片底色 = 画布 `#F8F7F5`（深色模式同表面色），与背景"融为一体"，层次只靠 1px 暖灰边框表达。**禁止用纯白 `#FFFFFF`** 把卡片从暖背景里"抠"出来——这是违背 shadcn 融合式卡片语言的根源。
- **趋势色 = 语义色，不是箭头色。** 先判断"对业务是好还是坏"，再上色。
  - 收入 ↑ → 绿；流失率 ↑ → 红；流失率 ↓ → 绿。
- **品牌薄荷 ≠ 成功色。** `#CCF8E7`（品牌）与 `#DFF2E6`（success）视觉近似，**品牌薄荷不得用于任何状态表达**；状态必须用 `--np-color-*-bg` + 对应深色文字 + 文字标签，禁止只靠色块区分。
- **侧栏零品牌色。** 近黑侧栏内只用白色透明度表达层次。品牌墨绿最多以 Logo 标记形式出现一次，绝不用作选中底。
- **高饱和面积上限。** `#046461` 及相关高饱和色的覆盖面积不超过画布 5%，仅用于数据表达与选中态。
- **状态色一律"浅底 + 深字"**，禁止实心饱和底色填充胶囊。
- 正文文本与背景对比度：≥ 4.5:1；大字号（≥ 24px）≥ 3:1；图表轴标签 ≥ 4.5:1。

### 2.2 字体排印

#### 字族

```css
--np-font-sans: "Inter", "Inter Variable", -apple-system, BlinkMacSystemFont,
                "Segoe UI", "PingFang SC", "HarmonyOS Sans SC",
                "Microsoft YaHei", "Noto Sans SC", sans-serif;
--np-font-mono: "JetBrains Mono", "SF Mono", ui-monospace, Consolas, monospace;
```

- 拉丁字符用 Inter，中文用 PingFang SC / HarmonyOS Sans SC，保证中英混排 x-height 接近。
- **所有数字必须开启等宽数字**：`font-variant-numeric: tabular-nums;`。表格、指标、坐标轴、金额一律适用。
- 代码、ID、Token、哈希等使用 `--np-font-mono`。

#### 字阶 Type Scale

| 令牌 | 字号 / 行高 | 字重 | 字距 | 用途（原型对应） |
| --- | --- | --- | --- | --- |
| `--np-text-display-xl` | 40 / 46 | 600 | -0.03em | 数据大屏主指标 |
| `--np-text-display` | 32 / 38 | 600 | -0.025em | 页面主 KPI |
| `--np-text-h1` | 26 / 32 | 600 | -0.02em | 页面标题（Overview） |
| `--np-text-h2` | 20 / 28 | 600 | -0.015em | 区域标题 |
| `--np-text-h3` | 16 / 24 | 600 | -0.01em | 卡片标题、分组标题 |
| `--np-text-metric` | 30 / 36 | 600 | -0.02em | KPI 数值（$1,248,000） |
| `--np-text-metric-sm` | 22 / 28 | 600 | -0.02em | 卡片内次级数值 |
| `--np-text-body` | 14 / 22 | 400 | 0 | 正文、表格内容 |
| `--np-text-body-strong` | 14 / 22 | 500 | 0 | 强调正文、项目名 |
| `--np-text-body-sm` | 13 / 20 | 400 | 0 | 副标题、卡片说明（Key performance metrics…） |
| `--np-text-label` | 14 / 20 | 500 | 0 | 表单标签、卡片标签（Revenue） |
| `--np-text-table-head` | 12.5 / 18 | 500 | 0.01em | 表头（Project / Owner / Status…） |
| `--np-text-caption` | 12 / 16 | 400 | 0 | 辅助说明（vs Apr 13 – May 12） |
| `--np-text-micro` | 11 / 14 | 500 | 0.02em | 徽标、图表轴刻度 |

**规则**
- 字重只用 400 / 500 / 600 三档，禁止 700+。层级靠字号 + 颜色，不靠加粗堆叠。
- 大字号（≥ 26px）必须负字距，否则显得松散；小字号（≤ 13px）不用负字距。
- 中文不做负字距（负字距仅对拉丁与数字生效，可用 `:lang(en)` 限定）。
- 数字与单位之间用 thin space：`$48,600`、`1.23%`、`8,560`。

### 2.3 间距 / 尺寸

**间距阶梯（4px 基准）**

| 令牌 | 值 | 典型用途 |
| --- | --- | --- |
| `--np-space-1` | 4px | 图标与文字间隙 |
| `--np-space-2` | 8px | 胶囊内边距、紧凑元素 |
| `--np-space-3` | 12px | 表格单元格内边距 |
| `--np-space-4` | 16px | 卡片内边距（紧凑）、按钮组间隙 |
| `--np-space-5` | 20px | 卡片内边距（默认） |
| `--np-space-6` | 24px | 卡片间距、栅格 gutter |
| `--np-space-8` | 32px | 页面左右内边距、区块间距 |
| `--np-space-10` | 40px | 大区块间距 |
| `--np-space-12` | 48px | 页面上下留白 |
| `--np-space-16` | 64px | 空状态上下留白 |

**固定尺寸**

| 令牌 | 值 | 说明 |
| --- | --- | --- |
| `--np-size-sidebar` | 240px | 侧栏展开宽度 |
| `--np-size-sidebar-collapsed` | 64px | 侧栏收起宽度 |
| `--np-size-topbar` | 64px | 顶栏高度 |
| `--np-size-control-sm` | 28px | 小控件（小按钮、Chip） |
| `--np-size-control-md` | 32px | 默认控件（按钮、输入框、下拉、图标按钮、分页） |
| `--np-size-control-lg` | 40px | 表单主操作 |
| `--np-size-row` | 44px | 表格行高（紧凑 36 / 宽松 52） |
| `--np-size-table-head` | 40px | 表头高 |
| `--np-size-spark` | 72×36px | KPI 火花线（宽×高） |
| `--np-size-chart-md` | 240px | 主图表绘图区最小高度 |
| `--np-size-chart-lg` | 320px | 图表卡最小高度（标题 + 绘图区） |
| `--np-size-icon` | 16px | 内联图标 |
| `--np-size-icon-lg` | 20px | 导航图标 |
| `--np-size-avatar-sm / md / lg` | 20 / 24 / 32px | 头像（表格用 sm，组合用 md，侧栏用户用 lg） |

> 上述令牌必须**同时**出现在 §8.1 的 `:root` 与设计同学交付的变量里。v1.1 曾出现"正文列了、CSS 块漏了"的 `--np-size-chart-*` 与 `--np-size-avatar-*`，v2.0 已补齐 —— 令牌清单不一致会在交付时直接变成硬编码。

**组件内固定尺寸**（不单独出令牌，但全站必须一致）

| 组件 | 尺寸 |
| --- | --- |
| 状态胶囊 Pill | 高 22px，水平内边距 8px，圆点 6px |
| Chip | 高 28px，水平内边距 10px，全文圆角 |
| Tab | 高 36px，水平内边距 12px，下划线 2px |
| Segmented | 总宽 176px，容器内边距 3px，按钮高 26px，圆角 sm |
| Switch | 36×20px，滑块 16px，位移 16px |
| Checkbox / Radio | 16×16px（勾 11px / 内点 8px） |
| Slider | 轨道高 4px，滑块 14px |
| Progress | 轨道高 6px，全文圆角 |
| 横向条形 `.bar-track` | 高 22px |
| 热力图单元 | 高 26px，间隙 3px |
| 列头 / 分页按钮 | 32×32px |
| KPI 卡最小高 | 116px |
| Dialog / Sheet / Command | 宽 460 / 400 / 560px |
| Toast | 宽 340px |
| Popover 菜单 | 最小宽 180px，项高 32px |

### 2.4 圆角

| 令牌 | 值 | 用途 |
| --- | --- | --- |
| `--np-radius-xs` | 4px | 标签、微型徽标 |
| `--np-radius-sm` | 6px | 小按钮、输入框内嵌元素 |
| `--np-radius-md` | 8px | **按钮、输入框、下拉、分页（默认控件）** |
| `--np-radius-lg` | 12px | **卡片、面板、图表容器** |
| `--np-radius-xl` | 16px | 弹窗、抽屉 |
| `--np-radius-full` | 999px | 状态胶囊、头像、圆形按钮 |

规则：**同一容器内圆角必须"外大内小"**（卡片 12px 内含按钮 8px）；胶囊只用于状态与标签，不用于按钮。

### 2.5 边框与高程

| 令牌 | 值 | 用途 |
| --- | --- | --- |
| `--np-border-width` | 1px | 所有描边 |
| `--np-border-default` | `1px solid var(--np-color-border-default)` | 卡片、输入框 |
| `--np-border-subtle` | `1px solid var(--np-color-border-subtle)` | 表格行线 |
| `--np-shadow-none` | `none` | **卡片默认（只有边框）** |
| `--np-shadow-e1` | `0 1px 2px rgba(11,11,10,.05)` | 卡片 hover 微抬；Switch / Segmented / Slider 的滑块 |
| `--np-shadow-e2` | `0 4px 12px rgba(11,11,10,.07)` | 看板任务卡 hover；Tooltip / Navtip |
| `--np-shadow-e3` | `0 8px 24px rgba(11,11,10,.09)` | 下拉 / 菜单 / Popover / Toast |
| `--np-shadow-e4` | `0 24px 64px rgba(11,11,10,.18)` | Dialog / Sheet（模态） |
| `--np-shadow-sidebar` | `none` | 侧栏**不用阴影**，靠色差分离 |

规则：阴影只属于「浮在内容之上的层」。页面上的卡片永远只有 1px 边框。"有边框又有重阴影"是禁止项（唯一例外是 hover 时的 `e1` 微抬）。阴影底色用 `rgba(11,11,10,*)`（暖黑），不用纯黑。

### 2.6 动效

动效的目标是**解释状态变化**，不是装饰。因此全站共用一套原语：同一类变化（弹出、滑入、展开、生长）在任何组件里都长得一样。

**令牌**

| 令牌 | 值 | 用途 |
| --- | --- | --- |
| `--np-duration-instant` | 100ms | hover 变色、图标切换 |
| `--np-duration-fast` | 140ms | 按钮/行状态、复选、气泡进入 |
| `--np-duration-base` | 200ms | 下拉展开、弹窗、Tabs、遮罩、手风琴 |
| `--np-duration-slow` | 280ms | 抽屉、Toast、侧栏收起 |
| `--np-duration-chart` | 600ms | 图表首次绘制 |
| `--np-ease-standard` | `cubic-bezier(.2,.8,.2,1)` | 颜色 / 背景 / 边框 / 位置切换 |
| `--np-ease-in-out` | `cubic-bezier(.4,0,.2,1)` | 大位移（≥ 100px，如 Sheet 滑入） |
| `--np-ease-out` | `cubic-bezier(0,0,.2,1)` | 进入与退出（小位移、缩放、淡入） |

**曲线选型**（不要凭感觉挑）

| 变化类型 | 曲线 | 理由 |
| --- | --- | --- |
| 颜色、背景、边框、阴影 | `--np-ease-standard` | 无位移，只需两端平缓 |
| 进入 / 退出，位移 ≤ 4px | `--np-ease-out` | 起点快、收尾稳，符合"元素被放下"的直觉 |
| 位移 ≥ 100px（Sheet） | `--np-ease-in-out` | 长距离需要起步和刹车 |
| 同层元素位置切换（Segmented 滑块、Tabs 下划线） | `--np-ease-standard` | 两端同速，避免"甩尾" |
| 数据生长（条形、进度、图表） | `--np-ease-out` | 前快后慢，读起来像"即将落定" |

**动效原语表**（全站只有这 7 种）

| 原语 | 初始态 | 展开态 | 时长 / 曲线 | `transform-origin` |
| --- | --- | --- | --- | --- |
| **菜单 / Popover** | `opacity:0` + `translateY(-4px) scale(.96)` | `none` | fast / ease-out | 锚在触发侧（`--pop-origin`，默认 `top left`） |
| **Dialog** | `translateY(4px) scale(.96)` | `none` | base / ease-out | 居中，**不设** origin |
| **Sheet** | `translateX(100%)` | `none` | slow / ease-in-out | 右边缘 |
| **Toast** | `opacity:0` + `translateX(100%)` | `none` | slow / ease-out | 右边缘 |
| **Tooltip / Navtip** | `opacity:0` + `translateX(-4px)` | `none` | fast / ease-out | 左边缘（朝触发元素） |
| **遮罩 Scrim / 浮层容器** | `opacity:0` | `opacity:1` | base / ease-out | — |
| **视图切换 / Tab 面板** | `opacity:0` + `translateY(4px)` | 默认态 | base / ease-out | — |

**四条实现规则**

1. **只动 `transform` 与 `opacity`。** 位移上限 4px（Sheet、Toast 的整条滑入除外）。`width / height / top / left / margin` 一律禁止。
   - **例外共四处**，其余任何宽高类动效都视为违规：
     ① 表格列宽拖拽（无 transform 等价物）；
     ② 侧栏展开/收起（`--np-duration-slow`）；
     ③ 搜索框聚焦展开 200→320px（`--np-duration-base`，见 §4.2）；
     ④ 手风琴展开（`grid-template-rows: 0fr → 1fr`，`--np-duration-base`）。它动的是布局高度，但**没有 transform 等价物能表达"内容真实占位"**，故作为唯一被允许的高度动画；实现时用 `grid-template-rows` 而非 `height`，避免 `height:auto` 无法过渡。
2. **高频重复触发用 `transition`，不用 `@keyframes`。** Toast 可能被连续触发、行高亮可能被反复点击 —— 关键帧会从头播，过渡能从当前值重定向。**判据：这个元素会不会在上一段动画没结束时被再次触发？会 → `transition`。**
3. **进入用 `--np-ease-out`，退出用同一条过渡的**反向**。** 不要为退出单独写一套参数（提前把元素设成"关闭态样式"，再切 `data-state` 即可）。浮层关闭时用 `visibility 0s linear <duration>` 把隐藏推迟到淡出结束，否则元素会瞬间消失：
   ```css
   .pop { opacity:0; visibility:hidden; transform:translateY(-4px) scale(.96);
          transition: opacity var(--np-duration-fast) var(--np-ease-out),
                      transform var(--np-duration-fast) var(--np-ease-out),
                      visibility 0s linear var(--np-duration-fast); }
   .pop[data-state="open"] { opacity:1; visibility:visible; transform:none;
          transition: opacity var(--np-duration-fast) var(--np-ease-out),
                      transform var(--np-duration-fast) var(--np-ease-out),
                      visibility 0s linear 0s; }
   ```
4. **`transform-origin` 跟着触发源走。** 菜单从其触发按钮的角长出来；Dialog 居中所以不设；Sheet / Toast 从右边缘长出。origin 写错会让"从哪来"读不出来。

**错峰**

- 图表按序列**错峰 60ms** 依次绘制，营造"数据生长"感（`animation-delay: calc(var(--i) * 60ms)`）。
- 密集网格（热力图）把错峰降到 **8ms/格**，否则整块要等两秒才画完 —— 错峰总时长控制在 400ms 内。

**降级**

- `prefers-reduced-motion: reduce`：全部 `transition-duration` / `animation-duration` 压到 `.01ms`，并**移除所有 `transform`**（`.pop / .dialog / .toast / .navtip / .sheet` 强制 `transform:none`），只保留透明度切换作为状态指示。
- 条形 / 进度的生长动画直接置 `animation:none`，一次性呈现终值。

**自检清单**（评审时逐条过）

- [ ] 位移 ≤ 4px？（Sheet / Toast 的整条滑入除外）
- [ ] 只动了 `transform` / `opacity`？如果动了宽高，是否命中四处例外之一？
- [ ] 会被连续触发的元素用了 `transition` 吗？
- [ ] 曲线的选型和上表一致吗？
- [ ] 浮层关闭时，`visibility` 是否延迟到淡出结束？
- [ ] `prefers-reduced-motion` 下是否只剩透明度过渡？

### 2.7 图标

| 项 | 规范 |
| --- | --- |
| 图标库 | Lucide / Phosphor，线性风格（stroke 1.5px，圆角端点） |
| 尺寸 | 16px（内联） / 20px（导航） / 14px（胶囊内） |
| 颜色 | 继承文字色；侧栏未选中用 `rgba(255,255,255,.55)` |
| 对齐 | 与首行文字基线对齐，`vertical-align: text-bottom` |
| 禁用 | 图标外发光、彩色图标、超过 1 个色相的图标 |

---

## 3. 布局系统

### 3.1 应用外壳 App Shell

```
┌───────────┬──────────────────────────────────────────────┐
│ Sidebar   │ Topbar 64px  标题区 ─────────── 右侧操作区     │
│ 240 / 64  ├──────────────────────────────────────────────┤
│ #0B0B0A   │ Content  max 1600 居中 / padding 32 / gap 24  │
│ sticky    │   .grid 12 列 · gutter 24                     │
│ 100vh     │   KPI Grid → Chart Grid → Table               │
│           │                                              │
│ 底部固定   │                                              │
│ 套餐卡+用户│                                              │
└───────────┴──────────────────────────────────────────────┘
```

**侧栏结构（自上而下）**

1. **Logo 区**：高 56px，左右内边距 20px，条目内 `gap` 10px。品牌标记 **24×24px、圆角 7px、`pine-600` 底 + 白色 13px/600 字**，右侧字标 15px/600（`-0.01em`）。Logo 标记是全站唯一允许在侧栏出现的品牌色元素。
2. **导航列表**：顶部内边距 16px、左右内边距 8px；条目高 36px、圆角 `--np-radius-md`、水平内边距 10px、条目间距 2px；图标 20px，与文字 `gap` 10px。
   - 默认：文字与图标 `--np-color-nav-text` `rgba(255,255,255,.55)`。
   - 悬浮（hover）：底色 `rgba(255,255,255,.05)`，文字升至 `.75`。
   - **活动项（active）**：
     - 底色 `--np-gradient-nav`（`90deg`，白 `.10 → .04`）
     - 文字与图标 `#FFFFFF`，字重 500
     - **左侧 2px 竖条标记** `rgba(255,255,255,.70)`，圆角 1px，距条目左边缘 0，上下内缩 8px
   - 按下（pressed）：底色 `rgba(255,255,255,.12)`。
   - 分组分隔线：1px `rgba(255,255,255,.08)`，外边距 `12px 10px`。
   - **禁止**：用品牌墨绿做选中底、给活动项加阴影或发光、使用纯白实心底。
3. **弹性留白**（`flex:1`）。
4. **产品 / 套餐切换器**：外边距 12px、内边距 10px、圆角 `--np-radius-md`、`rgba(255,255,255,.04)` 底 + `rgba(255,255,255,.08)` 边框；产品名 13px/500 白、套餐名 11px `rgba(255,255,255,.55)`。
5. **用户区**（`border-top: 1px solid rgba(255,255,255,.08)`，内边距 `14px 16px`，`gap` 10px）：头像 32px + 姓名 13px/500（白）+ 角色 11px `.55` + 右侧 16px chevron（`.45`）。整块是一个 `aria-haspopup="menu"` 的按钮。

**收起态（64px）**

- 触发：顶栏左端的 `sidebarToggle`（图标按钮）。宽度过渡 `--np-duration-slow` + `--np-ease-standard`（属于 §2.6 的宽高例外②）。
- 收起后**只显示 20px 图标，且在 64px 里真正居中**；悬浮或聚焦时在右侧弹出 Tooltip（见 §4.11）。
- **实现关键：只写 `opacity: 0` 不够。** 被隐藏的文字与徽标仍然占据布局宽度，flex 容器里 `justify-content: center` 也算不出正确的中心，图标会被挤向一侧（实测偏差 14–22px）。必须按类型分别处理：

| 元素类型 | 处理 | 原因 |
| --- | --- | --- |
| 纯文字（`.logo-name` / `.nav-label` / `.user-info`） | `flex: 0 0 0; width: 0; overflow: hidden; opacity: 0` | 退出布局流，但仍保留淡出过渡，不会突跳 |
| 带 `margin-left: auto` 的徽标 / chevron（`.nav-badge` / `.user-chevron`） | `position: absolute; opacity: 0; pointer-events: none` | 必须完全脱离文档流，否则 `auto` 外边距会吃掉居中空间 |
| 父级容器 | `gap` 一并归零 | 宽度为 0 的兄弟节点仍会产生 `gap`，否则还会偏 5px |

- 套餐卡在收起态下保持"透明但占位"（不脱流），避免底部区域高度跳动。

**顶栏结构**

- 左侧：侧栏开关（图标按钮 32px）→ 页面标题（`--np-text-h1`）+ 副标题（`--np-text-body-sm`，`--np-color-text-tertiary`），标题与副标题间距 4px。
- 右侧（自左向右，`gap` 12px）：作用域 / 时间范围下拉（32px 高、白底、`--np-radius-md`、含图标 + 文字 + chevron）→ 搜索框（默认 200px，聚焦 320px，内含 `⌘K` 徽标；< 900px 时整块隐藏）→ 通知图标按钮（带 6px 红点）→ **页面主操作按钮（Primary，默认隐藏）**。
- **Primary 按钮按页面出现，不是每页都有。** 只有需要新建对象的页面（如 Projects → `Add Project`）才渲染它；默认 `hidden`，由路由切换时按页面元数据控制。这条保证"一屏内 Primary ≤ 1 个"在跨页面上也成立。
- 页面标题与副标题由路由表驱动（见 §3.4），不写死在每个视图里。

### 3.2 栅格与断点

内容区**始终**为 12 列栅格（`.grid`），gutter 24px，`max-width: 1600px` 居中，卡片内边距 20px。断点只调整**列数分配与内边距**，不新增栅格体系。

| 断点 | 值 | 内容区内边距 | KPI 列数 | 其它变化 |
| --- | --- | --- | --- | --- |
| `xl` | ≥ 1440px | 32px | 4 | 完整三栏仪表盘；图表 8 + 4 列；统计块 3 列 |
| `lg` | 1024–1439px | 24px | 2 | 图表降为 12 列整宽；统计块 2 列；看板仍 3 列 |
| `md` | 900–1023px | 24px | 2 | 看板 / 设置双栏降为单列；设置二级导航由竖排转横排换行 |
| `sm` | 640–899px | 20px | 2 | **隐藏顶栏搜索框**；表单网格转单列；统计块单列 |
| `xs` | < 640px | 16px | 1 | 顶栏改纵向堆叠；表格页脚改纵向；Toast 撑满宽；Dialog 内边距收窄至 20px；Sheet 占满宽 |

- 断点用 `max-width` 逐级覆盖（1439 / 1023 / 900 / 640 四条媒体查询），**不设** `min-width` 递进，避免两套规则叠加出中间态。
- 侧栏在各断点**保持 240px 展开**（`md` 及以下由用户手动收起），不做自动抽屉 —— 这是 B2B 桌面优先产品的取舍：小屏仍要能一屏看到导航全貌。
- 常用跨列：KPI 卡 3 列 ×4（`xl`）；图表 8 + 4；表格 12；统计块 4 列 ×3。
- 垂直节奏：区块间距 24px；卡片标题到内容 16px；表格工具条到表头 0（工具条自带下边框）。

### 3.3 页面模板

原型落地了 6 个页面模板，覆盖了产品线的全部页面类型。**新页面先归类到其中之一，不要发明第 7 种。**

| 模板 | 页面 | 结构 | 视觉重心 |
| --- | --- | --- | --- |
| **Overview**（仪表盘） | Overview | KPI 行（4）→ 图表区（面积图 span 8 + 堆叠柱 span 4）→ 明细表（span 12） | 指标 → 趋势 → 明细的三段式，密度递减 |
| **Analytics**（钻取） | Analytics | 统计块行（3，无边框轻量款）→ 漏斗（横向条形）+ 设备（横向条形）→ 留存热力图 → Top 表 | 对比与分布，弱化单值 |
| **Board**（看板） | Projects | 三列看板（On Track / At Risk / Blocked）+ 任务卡 | 状态流转，卡片的横向可比 |
| **List + Alert**（列表） | Reports | 顶部 Alert（异常提示）→ 明细表 → 手风琴（投递设置） | 先给结论（告警），再给明细 |
| **Gallery**（样张） | Components | 单卡片内 11 个组件分区，每区含名称 + 等宽规格串 + 样张 | 规格与实现并置，供交付比对 |
| **Settings**（配置） | Settings | 左侧二级导航（200px，sticky）+ 右侧表单分组卡片 | 分组清晰，单列阅读 |

- **Overview / Analytics / Board / List 都属于"数据页"**：顶部必须有 KPI 或统计块作为结论层，不允许直接进表格。
- **Gallery 是内部页面**，不对最终用户暴露；它的存在是为了让文档与实现逐条对照。
- **Settings 的二级导航**：sticky 定位（`top: 88px`），条目高 32px、圆角 `--np-radius-sm`；活动项 `--np-color-bg-active` 底 + `text-primary` + 字重 500。`md` 及以下转横排。

### 3.4 路由与导航

侧栏与路由是**一对一映射**：侧栏有几个入口，就有几个路由。不允许出现"侧栏点不到、只能靠内链进"的页面。

| 路由 | 侧栏标签 | 页面标题 / 副标题 | 顶栏 Primary |
| --- | --- | --- | --- |
| `#overview` | Overview | Overview / Key performance metrics for your workspace | — |
| `#analytics` | Analytics | Analytics / Funnel, retention and channel breakdown | — |
| `#projects` | Projects（带徽标 `12`） | Projects / 12 active projects across the workspace | `Add Project` |
| `#reports` | Reports | Reports / Scheduled deliveries and export history | — |
| `#components` | Components（分组分隔线之下） | Components / Component library and interaction specs | — |
| `#settings` | Settings | Settings / Workspace configuration and defaults | — |

规则：

- **页面标题与副标题由路由表统一提供**，视图内部不重复渲染 —— 避免"顶栏写一套、页面里再写一套"。
- 切换时：更新 `document.title`（可选）、把当前视图加 `.active`、给对应侧栏项加 `.active` + `aria-current="page"`、同步 `sidebarToggle` 之外的 Primary 按钮显隐。
- 视图切换动效统一用 §2.6 的「视图切换」原语（`opacity + translateY(4px)`，base / ease-out）。
- 侧栏 `Projects` 的计数徽标是**数据驱动的**：数值来自项目总数，为空或 0 时整个徽标不渲染（不要显示 `0`）。
- 可直接深链：打开 `…#analytics` 应直接落在 Analytics 页，侧栏高亮同步。非法 hash 回落 `#overview`。

---

## 4. 组件规范

每个组件包含：**结构 → 尺寸 → 状态 → 令牌**。共 **28 节**，按职责分八族：

| 族 | 章节 |
| --- | --- |
| 动作 | §4.1 Button · §4.4 Icon Button · §4.23 Kbd |
| 表单与输入 | §4.2 Input / Textarea / Search · §4.3 Select · §4.18 Checkbox / Radio / Switch / Slider · §4.20 Form Field · §4.21 Chip |
| 展示 | §4.5 Badge / Status Pill · §4.6 Card · §4.7 KPI Metric Card · §4.13 Avatar · §4.19 Progress · §4.22 Breadcrumb |
| 导航 | §4.11 Sidebar Nav · §4.12 Page Header · §4.15 Tabs · §4.16 Segmented Control · §4.17 Accordion · §4.26 Command Palette |
| 浮层 | §4.14 浮层族（Tooltip / Popover / Menu / Dialog / Sheet / Command） |
| 数据 | §4.8 Chart Container · §4.9 Table · §4.10 Pagination |
| 反馈 | §4.24 Alert · §4.25 Toast · §4.27 空状态与加载态 |
| 业务零件 | §4.28 Stat Tile / 横向条形 / 热力图 / 看板 / Subnav / Toolbar |

**与原型组件样张页的对应**（Components 页共 11 个展示分组，无遗漏）：

| 原型分组 | 本文章节 |
| --- | --- |
| Button | §4.1 |
| Icon Button & Segmented | §4.4 · §4.16 |
| Input / Textarea / Select | §4.2 · §4.3 |
| Checkbox / Radio / Switch / Slider | §4.18 |
| Tabs & Accordion | §4.15 · §4.17 |
| Badge / Avatar / Progress / Breadcrumb | §4.5 · §4.13 · §4.19 · §4.22 |
| Dropdown Menu | §4.14 |
| Dialog / Alert Dialog / Sheet / Command / Toast | §4.14 · §4.24 · §4.25 · §4.26 |
| Tooltip | §4.14 |
| Alert | §4.24 |
| Skeleton / Empty / No result / Error | §4.27 |

### 4.1 Button

| 变体 | 底色（默认 / hover / active） | 文字 | 边框 | 用途 |
| --- | --- | --- | --- | --- |
| Primary | `#16140F` / `#24211D` / `#0B0B0A` | `#FFFFFF` | 无 | 页面唯一主操作 |
| Secondary | `#FFFFFF` / `bg-hover` / `bg-active` | `--np-color-text-primary` | `1px solid neutral-200`（hover 转 `border-strong`） | 次要操作（Columns / Export） |
| Ghost | 透明 / `bg-hover` / `bg-active` | `--np-color-text-secondary`（hover 转 primary） | 无 | 表格行操作、工具条、低权重动作 |
| Danger（描边） | `#FFFFFF` / `danger-bg` | `--np-color-danger` | `1px solid red-100`（hover 转 `danger`） | 删除入口 |
| **Danger（实心）** | `#9A2C20` / `#C0392B` | `#FFFFFF` | 无 | **仅用于 Alert Dialog 内的最终确认按钮** |

- 高度 32px（默认）/ 28px（`.btn-sm`）/ 40px（`.btn-lg`）；水平内边距 12 / 10 / 16px；圆角 `--np-radius-md`；字号 13px（`lg` 为 14px），字重 500。
- 图标 + 文字间距 6px，图标 16px。
- **状态**：
  - hover / active：见上表，颜色过渡 `--np-duration-fast` + `--np-ease-standard`。
  - focus-visible：外环 `0 0 0 3px rgba(4,100,97,.30)`，不可移除。
  - disabled：底色 `neutral-100`、边框透明、文字 `--np-color-text-disabled`、`cursor: not-allowed`。
  - **loading**：文字设为 `transparent`（保留宽度不跳动），居中叠一枚 14px 转圈（2px 环、`.6s linear infinite`）。浅底按钮（Secondary / Ghost / Danger）的环用 `rgba(11,11,10,.18)` + 主色上半环 —— 深底按钮才用白色环。loading 期间 `pointer-events: none`。
- **按钮禁用渐变底**（渐变只属于背景/图表/插画，见 §2.1.4）。
- **一屏内 Primary 按钮 ≤ 1 个**；工具条按钮统一 Secondary。跨页面时由路由元数据控制顶栏 Primary 的显隐（见 §3.1）。
- **Danger 实心是例外，不是常态**：只在"用户已经点了删除、现在要二次确认"的弹窗里出现，且该弹窗内不得再出现 Primary。

### 4.2 Input / Textarea / Search

- **单行输入**：高 32px，圆角 `--np-radius-md`，内边距 `0 10px`，白底 + `neutral-200` 边框，文字 14px。
- **多行 Textarea**：同款边框与圆角，内边距 `8px 10px`，行高 22px，最小高 88px，`resize: vertical`。
- Placeholder 用 `--np-color-text-tertiary`。
- 前后置图标 16px，左右各 10px（前置图标时输入框左内边距加到 32px）。
- **状态**：hover 边框转 `border-strong`；focus 边框 `border-strong` + 外环 `0 0 0 3px rgba(4,100,97,.22)`；error（`aria-invalid="true"`）边框 `red-600` + 外环 `rgba(192,57,43,.20)`，下方 12px 错误文案配 13px 图标（见 §4.21 Form Field）。
- **Search（顶栏）**：默认宽 200px，**聚焦展开 320px**，宽度过渡 `--np-duration-base` + `--np-ease-standard`，失焦回落同参。这是 §2.6 宽高类例外的第 ③ 条 —— 展开是为了让用户看清输入内容，属功能性必需。内含左侧 16px 搜索图标（`left: 10px`）与右侧 `⌘K` 徽标（`right: 8px`），因此左右内边距为 `0 56px 0 32px`；字号 13px（比表单输入小一档，因为它是全局入口而非字段）。
- 快捷键徽标：11px、`neutral-100` 底、`neutral-600` 字、`--np-radius-xs`、内边距 `1px 5px`。
- 表单类输入必须绑定 `<label for>`，不允许只靠 placeholder 当标签。

### 4.3 Select / Dropdown（触发器）

- 触发器同 Button Secondary 形态（高 32px、圆角 `--np-radius-md`、白底 + `neutral-200` 边框、内边距 `0 10px`、字号 13px），右侧 chevron 16px，`gap` 8px；也用于"作用域 / 时间范围"这类顶栏选择器。
- 状态：hover 底色 `bg-hover` + 边框 `border-strong`；**展开时（`aria-expanded="true"`）边框 `border-strong` + 底色 `bg-active` + chevron 旋转 180°**（`--np-duration-base` + `--np-ease-standard`）。
- 面板即 §4.14 的 Popover 菜单：白底、圆角 `--np-radius-md`、`--np-shadow-e3`、内边距 4px、最小宽 = 触发器宽（默认最小 180px）。
- 选项：高 32px、圆角 `--np-radius-sm`、水平内边距 8px、字号 13px；选中项右侧 `margin-left:auto` 的 16px 对勾 + `--np-color-accent`。
- 悬浮项底色 `--np-color-bg-hover`；分组标题 11px、`--np-color-text-tertiary`；分组分隔线 1px `border-subtle`。
- 面板内的悬浮底允许用 `bg-hover` —— 因为面板本身是**纯白表面**，`#F1EFEA` 在白底上是可见的（与暖画布上的情形不同，见 §2.1.2 红线）。

### 4.4 Icon Button

- 尺寸 32×32px（小号 28px），圆角 `--np-radius-md`，图标 16px，颜色 `--np-color-text-secondary`。
- hover 底色 `bg-hover` + 边框 `border-strong`；active 底色 `bg-active`；展开态（`aria-expanded="true"`）底色 `bg-active` + 边框 `border-strong`。
- **`plain` 变体**：边框与底都透明（用于顶栏侧栏开关、Toast 关闭、密集工具条）。它只保留 hover 的 `bg-hover`，按下 `bg-active`。凡是不希望出现"按钮轮廓"但需要命中区的地方都用它。
- 必须带 `aria-label`。
- 带未读红点：直径 6px、`--np-color-danger`、2px 白色描边，定位在按钮右上角**内缩 5px**处（`top: 5px; right: 5px`）；红点仅作辅助，未读数必须有文字入口（见 §6）。
- 表格行末尾的"更多操作"恒为 Icon Button（`MoreHorizontal`），点击出 Popover 菜单。

### 4.5 Badge / Status Pill

```
┌───────────┐
│ ● On Track│   高 22px · 内边距 8px/2px · 圆角 full · 12px/500 · 圆点 6px
└───────────┘
```

| 语义 | 底 | 字 / 圆点 | 原型 |
| --- | --- | --- | --- |
| Success | `#DFF2E6` | `#14603B` | On Track |
| Warning | `#FBEDD8` | `#8E5C10` | At Risk |
| Danger | `#FBE4E0` | `#9A2C20` | Blocked |
| Neutral | `neutral-100` | `neutral-600` | 草稿 / 归档 |
| Info | `#E4EDF4` | `#35678F` | 进行中 |
| **Accent（非状态）** | `#DEEFE5` (`accent-subtle`) | `#03514F` (`pine-700`) | `Pro` —— 套餐 / 等级 / 类别 |

规则：
- **禁用实心饱和底**；禁用 `#CCF8E7`（品牌薄荷）做状态底，避免与 Success 混淆。
- **`Accent` 胶囊只表达"等级 / 类别"，永不表达状态。** `#DEEFE5` 与 Success 的 `#DFF2E6` 在屏幕上看几乎同色（ΔE 极小），同一个"绿"既要表成功又要表等级，必然读错。因此：
  - Accent 胶囊**必须**带文字标签（`Pro` / `Enterprise`），且**不得**与 Success 胶囊出现在同一组里；
  - 需要更明确的区分时，Accent 胶囊可去掉圆点（类别不需要状态点）。
- 圆点为可选（状态类建议保留，类别类去掉）；文案 ≤ 4 个汉字 / 12 字符，超出截断。
- 状态必须"色 + 文字"双通道，色盲可辨。

### 4.6 Card

- 底色与画布同色 `#F8F7F5` + `1px solid neutral-200` + `--np-radius-lg`(12px) + 内边距 20px + **无阴影**（hover 时 `--np-shadow-e1`）。
- 卡片与背景"融为一体"，层次只靠 1px 暖灰边框表达；**禁止**用纯白 `#FFFFFF` 把卡片从暖背景里"浮"出来。
- 卡片结构：
  - Header：标题 `--np-text-h3`(16/600) 左，操作区右（下拉、图标按钮），下间距 16px。
  - Body：内容。
  - Footer：可选，`border-top: 1px solid neutral-100`，上内边距 12px。
- hover（可点击卡片）：`--np-shadow-e1` + 边框转 `neutral-300`，140ms。
- 强调卡（如"重点指标"）可用 `--np-gradient-brand-soft` 或 `--np-gradient-sage` 作底，但同屏不超过 1 张。
- 卡片间距 24px；同排卡片高度必须一致。

### 4.7 KPI Metric Card

```
┌──────────────────────────────┐
│ Revenue            ⓘ    ╱╲╱╲ │  ← 标签 14/500 + info 图标；右侧火花线 56×32
│ $1,248,000                   │  ← 30px/600 tabular-nums
│ ↑ 12.5%  vs Apr 13 – May 12  │  ← 趋势 12/500 语义色 + 说明 12/400 tertiary
└──────────────────────────────┘
```

- 内边距 20px，最小高 116px。
- 标签行：左侧标签 + `Info` 图标（14px，`neutral-400`，hover 出 Tooltip 解释口径）；右侧火花线（无轴、无网格、2px `#046461` 线 + `--np-gradient-spark` 填充，最后一点可描点）。
- 数值：`--np-text-metric`，色 `--np-color-text-primary`，**必须 tabular-nums**。
- 趋势行：箭头图标 14px + 百分比 12px/500，色按 §2.1.5 语义规则；"vs …" 对比区间用 `--np-color-text-tertiary`。
- 数量：一行 2 或 4 个，间距 24px，等宽。

**四张 KPI 的语义色彩范例**（照此逐项判断，不要按箭头方向机械上色）：

| 指标 | 数值 | 箭头 | 趋势色 | 判断理由 |
| --- | --- | --- | --- | --- |
| Revenue | `$1,248,000` | ↑ `12.5%` | **绿** | 收入上升 = 好 |
| Active Users | `48,600` | ↑ `8.2%` | **绿** | 活跃上升 = 好 |
| Conversion | `3.62%` | ↓ `0.4%` | **红** | 转化下降 = 坏 |
| Churn | `1.80%` | ↑ `0.3%` | **红** | **流失率上升 = 坏**（注意：箭头朝上，色却是红的） |

> 最后一行是这套规则的关键测试点：**箭头方向与颜色方向可以相反**。任何"看到 ↑ 就上绿色"的实现都是错的。

### 4.8 Chart Container

- 尺寸：图表卡最小高 **320px**（标题行 + 绘图区），绘图区最小高 **240px**；卡片内边距 20px，绘图区再内缩 8px。
- 标题行：图表标题 `--np-text-h3` 左；右侧时间粒度切换（`30 Days ▾` / `Daily ▾`）用 Select 小号；`gap` 16px、下间距 16px。
- 网格：**只保留水平线**，`--np-chart-grid` `#ECEAE5`，1px；y 轴 4 条刻度线；不画垂直网格。
- 轴标签：11px，`--np-chart-axis-text`；y 轴金额带 `$` 前缀并缩写（`$45K`）。
- 面积填充：使用 `--np-gradient-area`（`rgba(4,100,97,.30)` → `rgba(161,216,211,.14)` → 透明），**不要用单一纯色 20% 透明填充**——多色标才有品牌识别度。
- 折线：2px；**常驻不画描点**，只在 hover 时以 8px（白心 + 2px 主色边）出现，指向当次读数。数据密集时描点会与数据本身争抢注意力。
- Tooltip：白底 + `--np-radius-md` + `--np-shadow-e3` + 内边距 `10px 12px`；标题为日期 12px/500；每行 = 色点 8px + 序列名 + 数值（tabular，右对齐）。
- 图例：置于图表下方、左对齐，`gap` 16px、上间距 12px；色点 8px 圆 + 12px 文字；**可点击隐藏序列**（隐藏项文字转 `--np-color-text-disabled`，色点一并降为 `opacity:.35` —— 只灰文字不灰色点会造成"这条还在显示"的错位）。
- 空数据：绘图区显示 12px 居中提示"暂无数据"，不显示坐标轴；如需氛围可用 `--np-gradient-glow`。
- 同一张卡内**只放一个图表**。需要"漏斗 + 设备分布"这类并列时，拆成两张同排卡（见 §4.28 的横向条形）。

### 4.9 Table

| 项 | 规范 |
| --- | --- |
| 表头高 | 40px，底色 `--np-color-bg-surface-subtle` `#F1EFEA`，文字 `--np-text-table-head`，色 `--np-color-text-secondary` |
| 行高 | 44px（默认），`border-bottom: 1px solid neutral-100` |
| 单元格内边距 | 水平 16px，垂直 12px |
| 首列 | 宽 200–240px，`--np-text-body-strong`(14/500)，可带 20px 方型标识（圆角 6px、`neutral-100` 底、内置 12px 图标） |
| 数值列 | **右对齐 + tabular-nums**；表头同样右对齐 |
| 趋势列 | 箭头 14px + 数值，语义色 |
| 状态列 | Status Pill，列宽固定 96px |
| 人员列 | 头像 20px（圆形、`neutral-100` 底、内嵌 2 字缩写 11px）+ 姓名 13px，间距 8px |
| 排序列 | 表头右侧 12px `ArrowDown` 图标；可用列整列字色加深为 `text-primary` |
| 悬浮 | 行底色 `--np-color-bg-hover` `#F1EFEA`（**不能写 `#F8F7F5`**，那是画布/卡片底色，等于没有 hover）；按下 `--np-color-bg-active` `#E6E3DC`；操作列图标从 `opacity 0 → 1` 渐显，且 **`:focus-within` 时同样显示**（键盘用户不能因为"没有 hover"而看不到行操作） |
| 点击反馈 | 该表**没有选中模型**时（无多选、无详情页），点击行只给**瞬时高亮**：标 `data-flash` → `#DEEFE5` + 行首 2px `#046461` 条，**550ms 后自动清除**。同一时刻只有一行高亮（点新行要清掉旧行）。**不要把选中态持久挂在行上**，否则表格看起来"被选中了"却没有任何后续动作 |
| 只读表 | 没有行操作、也没有 `tabindex` 的表（如 Analytics 的 Top Pages）**不挂点击反馈** —— 给一张不可操作的表加高亮，等于暗示用户"这行能点"，是误导 |
| 选中（持久） | 仅用于有选中模型的表格：行底色 `#DEEFE5` (`pine-100`) + 行首 2px `#046461` 条 |
| 工具条 | 卡片右上角：`Columns` + `Export` 两个 Secondary 按钮；筛选激活时按钮左侧出现计数徽标 |
| 属性 | 行间不使用斑马纹；列宽可拖拽，最小 80px |
| 页脚 | 高 48px，左"Showing 1 to 4 of 24 results"（12px，tertiary），右分页 |

### 4.10 Pagination

- 按钮 32×32，圆角 `--np-radius-md`，文字 13px。
- 默认：透明底 + `neutral-600` 字；hover：`--np-color-bg-hover` `#F1EFEA` 底（**不能写 `#F8F7F5`**，与画布同色，hover 视觉上不成立）。
- 当前页：`neutral-900` `#16140F` 底 + 白字；若需品牌感可替换为 `#046461`（**同页只能选一种，不可混用**）。**当前页 hover 必须沿主按钮再深一档 `--np-color-action-primary-bg-hover` `#24211D`，不得回落到未激活那档暖白**——否则"当前页"在 hover 时会掉回普通按钮的观感。
- 上一页 / 下一页：32×32 Icon Button；禁用态 `neutral-400` + 不可点击。
- 页数 > 7 时中间用省略号，省略号为不可点击文本。
- 每页条数选择器置于分页左侧（Select 小号，如 `20 / page`）。

### 4.11 Sidebar Nav

- 结构、尺寸与收起态实现见 §3.1。
- **活动项标记**：透明白三层叠加——`--np-gradient-nav`（`90deg` 白 `.10→.04`）底 + `#FFFFFF` 文字 + 左侧 2px `rgba(255,255,255,.70)` 竖条。这是侧栏唯一的"选中语言"，收起态与展开态保持一致。
- 分组标题（可选）：11px/500，`rgba(255,255,255,.45)`，上间距 16px，左内边距 10px。
- 徽标（计数 / `Pro`）：置于条目右端（`margin-left: auto`），11px，`rgba(255,255,255,.12)` 底、白字、全圆角、内边距 `1px 6px`。
- **收起态（64px）**：仅显示 20px 图标、在 64px 宽度里真正居中；悬浮或键盘聚焦时在**右侧**弹出 Tooltip 显示该项名称；当前项左侧保留 2px 透明白指示条。
  - 图标居中的实现要点（务必照抄，否则会偏 14–22px）：文字 `flex:0 0 0; width:0; overflow:hidden; opacity:0`；徽标与 chevron `position:absolute; opacity:0`；父级 `gap` 归零。详见 §3.1 的对照表。
- 条目必须整行可点，命中区最小 36px 高、宽度贯通侧栏。
- **侧栏禁止出现品牌墨绿**（Logo 标记除外）。

### 4.12 Page Header

- 结构：H1 标题（26/600，`-0.02em`）+ 副标题（13/400，`tertiary`），间距 4px。
- 右侧操作区垂直居中，与标题基线不强制对齐，间距 12px。
- 与下方内容间距：24px（含时间范围选择器时为 16px + 16px）。
- 可选面包屑置于标题上方（12px，`tertiary`，分隔符 `/`）。

### 4.13 Avatar / Avatar Group

- 尺寸与字号**成对固定**（不要用比例公式推，小尺寸会掉到不可读）：32px → 13px/500、24px → 12px/500、20px → 11px/500。
- 圆形，`neutral-100` 底 + `neutral-700` 缩写文字（1–2 个字符），`place-items: center` 居中。
- 无图时用缩写；有图时对象覆盖 `object-fit: cover`。
- **组合头像**（成员列表 / 看板卡）：
  - 相邻头像重叠 8px（`margin-left: -8px`），首个不重叠；
  - 描边 2px，**颜色 = 所在表面色**（卡片内用 `--np-color-bg-surface`）。不要写死 `#FFFFFF`：卡片底不是白色，白描边会在暖画布上"描出"一圈冷光。
  - 最多 3 个 + `+N` 气泡；气泡高 24px、最小宽 24px、水平内边距 6px、`neutral-100` 底、`text-secondary` 字 11px/500，同一套 2px 描边与重叠。
- 表格行内用 20px 款，前缀在姓名之前，`gap` 8px。

### 4.14 浮层族：Tooltip / Popover / Menu / Dialog / Sheet / Command

六种浮层共用一个层级与关闭语义，区别只在锚定方式与视觉重量。

| 浮层 | 锚定 | 尺寸 | 阴影 | 关闭方式 |
| --- | --- | --- | --- | --- |
| Tooltip / Navtip | 元素旁 | 自适应 | `e2` | 移开即收 |
| Popover / Menu / 下拉面板 | 触发器 | 最小 180px | `e3` | 点外部 / `Esc` |
| Dialog | 视口居中 | 宽 460px | `e4` | 点阴影 / `Esc` / 关闭按钮 |
| Alert Dialog | 视口居中（可上偏） | 同 Dialog | `e4` | 同上 |
| Sheet | 右边缘 | 宽 400px | `e4` | 点阴影 / `Esc` / 关闭按钮 |
| Command Palette | 视口上方 12vh | 宽 560px | `e3` | 点阴影 / `Esc` |
| Toast | 视口右下角 | 宽 340px | `e3` | 自动（5.2s）/ 手动关闭 |

**层级（`z-index`）**：`pop 70` < `scrim 80` < `overlay-wrap / sheet 90` < `navtip 95` < `toast-region 100`。
> Navtip 必须高于浮层容器，否则"侧栏收起态气泡"会被任何打开的弹层盖住；Toast 最高，保证通知永远可见。

- **Tooltip / Navtip**：深底 `#16140F`（即 `--np-color-text-primary`）、白字 12px、内边距 `6px 10px`、圆角 `--np-radius-sm`（6px）、`--np-shadow-e2`；**延迟 300ms** 出现；`pointer-events: none`；仅承载说明文字，禁止放交互元素。导航项在**收起态**下复用同一形态（见 §4.11）。
- **Popover / Menu**：白底、圆角 `--np-radius-md`、`--np-shadow-e3`、内边距 4px、`transform-origin` 锚在触发侧。
  - 菜单项：高 32px、圆角 `--np-radius-sm`、水平内边距 8px、字号 13px、图标 16px `text-tertiary`、`gap` 8px；右侧可放快捷键提示或对勾（对勾用 `--np-color-accent`）。
  - 分组标题 11px `text-tertiary`；分组分隔线 1px `border-subtle`，外边距 `4px -4px`（负外边距让线顶到菜单边缘）。
  - **危险项**（删除等）放在菜单最下方、用 `--np-color-danger` 文字，不换底色。
- **Dialog**：白底、圆角 `--np-radius-lg`、`--np-shadow-e4`、内边距 24px；标题 16px/600 + 描述 13px `text-secondary`；底部操作区 `border-top` 分隔、`gap` 8px、右对齐。**Dialog 里同时出现的按钮不超过 3 个**，主操作在最后。
- **Alert Dialog**：结构同 Dialog，但语义是"确认 / 取消"，`role="alertdialog"`，初始焦点落在**取消**而非确认。Destructive 确认用 Danger 实心按钮（§4.1）。
- **Sheet（抽屉）**：从右边缘滑入，宽 400px，头部高 64px（含标题与关闭按钮），主体可滚动，底部操作区 `margin-top:auto` 吸底。用于"不离开当前页面的编辑"，适合字段较多、需要保留上下文承接的场景。
- **Command Palette（⌘K）**：宽 560px、置顶 12vh；顶部 52px 搜索行（图标 + 无边框输入 + 分隔线）；列表最多 320px 高、内边距 8px；每项高 40px；底部 11px 快捷键说明条。全局 `⌘K` / `Ctrl+K` 唤起，方向键选中、`Enter` 执行、`Esc` 关闭。
- **Toast**：见 §4.25。

**关闭行为的实现要求（三条，缺一不可）**

1. **点阴影 = `Esc` = 关闭按钮**，三者等价；只有点击弹层本体内部才不关闭。
2. **关闭监听必须挂在 `.overlay-wrap` 上，不能挂 `.scrim`。** `.scrim`（`z-index:80`）会被 `.overlay-wrap`（`inset:0` + `z-index:90`）整体盖住，挂在 scrim 上的 click 永远收不到 —— 这是"遮罩点不动"最典型的根因。
3. **用 `mousedown` + `mouseup` 双判**，并要求 `e.target` 就是容器本身（不是里面的 `.dialog`）。否则"在框内按下拖选文字、在框外松手"会被误判成点了阴影而误关。

**定位**：优先下方居中（Tooltip / Popover），空间不足自动翻转；与触发器间距 8px。

**动效**：严格套用 §2.6 的「动效原语表」—— 菜单 `translateY(-4px) scale(.96)`、Dialog `translateY(4px) scale(.96)`、Sheet / Toast 整条滑入；退出复用同一过渡的反向，并用延迟 `visibility` 保证淡出不被截断。

### 4.15 Tabs

用于**切换内容区**（导航语义），不是切换显示粒度（那是 §4.16 Segmented）。

- 结构：`.tablist`（`flex`，`gap` 4px，底部 1px `border-default`）→ `.tab` 按钮 → `.tabpanel`。
- Tab：高 36px、水平内边距 12px、字号 13px/500、圆角 `sm sm 0 0`。默认文字 `text-secondary`；hover 文字转 `text-primary` + 底 `bg-hover`；选中文字 `text-primary`。
- **下划线**：2px、色 `--np-color-action-primary-bg`（墨黑，**不是**品牌绿 —— 保证与主按钮同一套强调语言），定位在底部 `-1px` 以便压住容器分隔线，圆角 1px。
- 下划线动效：`opacity 0→1` + `scaleX(.6)→none`，`--np-duration-base`，`transform-origin: center`。
- Panel：上内边距 20px；非活动 `display: none`；激活时套用 §2.6 的「视图切换」原语。
- ARIA：`role="tablist"` / `role="tab"` + `aria-selected` + `aria-controls`，面板 `role="tabpanel"` + `id`；`←/→` 可切换。
- **数量 2–5 个**；超过 5 个改用 Select，标签超过 6 个汉字也改用 Select。

### 4.16 Segmented Control

用于**同一份内容的粒度 / 维度切换**（Day / Week / Month），选项之间**等权且互斥**，切换是即时的。

- 容器：内边距 3px、`neutral-100` 底、圆角 `--np-radius-md`、宽度 176px（或按等分撑满）；`--n` 表示分段数。
- 分段按钮：高 26px、水平内边距 10px、字号 13px/500、圆角 `--np-radius-sm`；未选文字 `text-secondary`，选中 `text-primary`。
- **滑块**：白底 + `--np-shadow-e1`，宽 `calc((100% - 6px) / var(--n))`，位置用 `transform: translateX(calc(100% * var(--i)))` —— 只走 transform，`--np-duration-base` + `--np-ease-standard`。
- **与 Tabs 的区别（评审最常问）**：Tabs 是**导航**（下划线 + 换内容区），Segmented 是**同一内容的显示方式**（实体滑块 + 内容原地重排）。因此 Tabs 用下划线（"位置指示"），Segmented 用白底滑块（"一块实体"）。
- 分段数 **2–4**；≥ 5 或标签较长时改用 Select。
- ARIA：容器 `role="group"` + `aria-label`，按钮 `aria-selected`（或 `role="radiogroup"` + `role="radio"`）。

### 4.17 Accordion

用于**把次要信息折叠起来**（报表的投递设置、FAQ），默认全部收起。

- 结构：`.acc-item`（底部 1px `border-subtle`）→ `.acc-trigger`（全宽按钮）→ `.acc-panel`。
- 触发器：最小高 48px、内边距 `12px 4px`、字号 14px/500、右侧 chevron 16px（`text-tertiary`）。hover 整行文字转 `--np-color-accent`；展开时 chevron 旋转 180°（`--np-duration-base` + `--np-ease-standard`）。
- **面板展开动效**：`display: grid; grid-template-rows: 0fr → 1fr`，内层 `overflow: hidden`，文字同时 `opacity 0→1`；`--np-duration-base` + `--np-ease-standard`。
  - 这是 §2.6 宽高类例外的第 ④ 条。**必须用 `grid-template-rows`，不要用 `height`** —— `height: auto` 无法参与过渡，写 `max-height` 则会有"展开到底后停顿"的假延迟。
- 面板内文字：13px / 行高 20 / `text-secondary`，下内边距 16px。
- 默认**可同时展开多项**（非互斥）。需要互斥时用 Tabs 或 Radio，不要改造 Accordion。
- ARIA：触发器 `aria-expanded` + `aria-controls`。

### 4.18 Checkbox / Radio / Switch / Slider

| 控件 | 尺寸 | 关态 | 开态 | 动效 |
| --- | --- | --- | --- | --- |
| Checkbox | 16×16，圆角 `xs`，边框 `border-strong`，白底 | — | 底色 + 边框都转 `action-primary-bg`；勾 11px、白色、3px 描边 | 勾：`opacity 0→1` + `scale(.6)→none`（instant + fast / ease-out） |
| Radio | 16×16 圆形，边框 `border-strong`，白底 | — | 边框转 `action-primary-bg`；内点 8px `action-primary-bg` | 内点：`opacity 0→1` + `scale(.4)→none` |
| Switch | 36×20，全文圆角 | 轨道 `neutral-300`，滑块 16px 白 + `e1` | 轨道 `--np-color-accent`，滑块 `translateX(16px)` | fast / ease-out |
| Slider | 轨道高 4px 全文圆角，滑块 14px | 未过部分 `neutral-100` | 已过部分 `--np-color-accent` | 滑块 hover `scale(1.1)`、active `scale(1.2)` |

- **勾选态用 `transform: scale` 入场，不要用 `opacity` 硬切** —— 缩放能读出"被按下"的物理感，纯淡入像开关灯。
- Switch 的 disabled 态：轨道 `neutral-100`、滑块 `neutral-0` 且去掉阴影。
- Slider 的已过部分用 `linear-gradient(to right, accent var(--v), neutral-100 var(--v))` 画，避免再叠一个元素。
- **行容器**：控件 + 文案用 `.check-row`（`gap` 10px，`align-items: flex-start`）；文案可两行（名称 13px/500 + 描述 12px `tertiary`，`gap` 2px）。整行可点，但——
- **实现坑**：不要用 `<label>` 直接包住 `<button>` 控件。label 的点击会转发给内部按钮，按钮自身又有监听，结果是**一次点击触发两次**（选中又取消）。正确做法是给行容器绑一次点击，并忽略 `e.target.closest('button')` 的情况后手动触发一次。
- ARIA：`role="checkbox"` / `role="radio"` / `role="switch"` + `aria-checked`；成组时外层 `role="group"` / `role="radiogroup"` + `aria-label`。
- **Switch 只用于"立即生效的设置项"**，不要用于表单提交字段（那用 Checkbox）。

### 4.19 Progress

- 轨道：高 6px、全文圆角、`neutral-100`。
- 填充：默认 `--np-color-accent`；`transform: scaleX(var(--v))`，`transform-origin: left center`，`--np-duration-base` + `--np-ease-out`。**走 `scaleX`，不走 `width`。**
- 语义色（`data-tone`）：`warning` → `--np-color-warning`；`danger` → `--np-color-danger`；`muted` → `--np-neutral-400`（用于"几乎为空"的对比场景）。
- **进度条不能是唯一信息通道**：必须同时给文字百分比或在旁标注数值，并附 `role="progressbar"` + `aria-valuenow/min/max`。
- 表格中的进度列宽固定（建议 96–120px），避免行高抖动。

### 4.20 Form Field（Label / Hint / Error）

所有表单控件的外壳，保证标签、说明、错误的结构与间距一致。

```
┌ Workspace name                    ← label  13px/500
│ ┌──────────────────────────────┐  ← 控件（32px）
│ └──────────────────────────────┘
│ 显示在侧栏与所有对外报表的页眉。      ← hint 12px tertiary ／ 或 error 12px danger + 图标
```

- 垂直结构：label → 控件 → 附加说明，每段间距 6px。
- **hint 与 error 互斥**：出错时用 error 替换 hint，不要两行都显示。
- error 必须同时：控件 `aria-invalid="true"`（触发红边框 + 红外环）、图标 13px、文案说明**怎么改**（"只能包含小写字母、数字与连字符"而不是"格式错误"）。
- 必填用 label 后缀标记（`（必填）`或 `*`），**不能只靠红色边框**。
- 表单网格：2 列、`gap` 20px；长文本字段或需要整行阅读的字段跨满列。
- 用 `aria-describedby` 把 hint / error 与控件关联。

### 4.21 Chip

可交互的筛选条件 / 标签。**与 Pill 的分工：Pill 是只读状态（§4.5），Chip 是用户可切换的。**

- 形态：高 28px、水平内边距 10px、全文圆角、1px `border-default`、白底、字号 12px、图标 13px、`gap` 6px。
- hover：底 `bg-hover` + 边框 `border-strong`。
- 选中（`aria-pressed="true"`）：底 `--np-color-accent-subtle`、边框 `--np-pine-300`、文字 `--np-pine-700`、字重 500。
- 用于筛选条（§4.28 Toolbar）与可移除条件（尾部带 `×` 图标）。
- **禁止把 Chip 当按钮用**：它的形态已经暗示"可切换状态"，纯动作请用 Button。

### 4.22 Breadcrumb

- 形态：12px / 行高 16 / `text-tertiary` / `gap` 6px / 分隔符 `/`（`opacity: .6`）。
- 链接 hover 转 `text-secondary`；末项用 `aria-current="page"` 且颜色升到 `text-secondary`（不可点）。
- **层级 ≤ 4**；超出时折叠中间层为 `…`（可点击展开）。
- 外层用 `<nav aria-label="面包屑">`。
- 只用于 **Detail 类页面**（单对象下的多级路径）。仪表盘类页面不需要面包屑 —— 侧栏已经说明了位置。

### 4.23 Kbd

- 内联快捷键提示：10.5px / 行高 14 / 内边距 `1px 5px` / 圆角 `--np-radius-xs` / `neutral-100` 底 / `text-secondary` 字。
- 用于 `⌘K`、`Esc`、`↵` 等；**一组不超过 3 个**，超过说明这个界面太依赖键盘。
- 与正文同基线，不参与换行宽度计算（`white-space: nowrap`）。

### 4.24 Alert

页面内的**持久**提示（数据源同步中、指标超阈值、Webhook 失败）。一次性的操作反馈用 Toast（§4.25）。

- 结构：16px 图标 + 内容块（标题 500 + 描述 12.5px/18 `opacity: .9`）+ 可选的行内按钮。
- 形态：内边距 `12px 14px`、圆角 `--np-radius-md`、`gap` 10px；图标与首行顶部对齐（`margin-top: 2px`）。
- 四种语义（底 / 字）同 §4.5 的语义色表；`info` / `warning` / `success` 用 `role="status"`，`danger` 用 `role="alert"`。
- 文案：**标题给结论，描述给下一步**。"Churn 已连续 3 周上升" + "当前 1.80%，超过 1.50% 的告警阈值。"
- 一屏内 Alert **不超过 2 条**；超过说明该用专门的告警中心。

### 4.25 Toast

短暂的、非阻断的操作反馈。位置固定在视口右下角。

- 容器：`position: fixed`，右下各 24px，纵向排列、`gap` 12px、右对齐、`z-index: 100`。
  - 容器 `pointer-events: none`，卡片 `pointer-events: auto` —— 否则空容器会挡住页面右下角的所有点击。
- 卡片：宽 340px、内边距 14px、圆角 `--np-radius-md`、白底 + 1px `border-default` + `--np-shadow-e3`。
- 结构：18px 语义图标（`margin-top: 2px`）+ 标题 13px/500 + 描述 12.5px/18 `text-secondary` + 22px 关闭按钮（Icon Button `plain`）。
- 语义图标色：success `green-600`、info `blue-600`、danger `red-600`。
- **动效**：从右滑入（`opacity 0→1` + `translateX(100%)→none`），`--np-duration-slow` + `--np-ease-out`。
  - **必须用 `transition`，不能用 `@keyframes`** —— Toast 可能被连续触发，关键帧会从头播，过渡能从当前值重定向（§2.6 规则 2）。
  - 进入前需要**双 `requestAnimationFrame`** 让初始态先落盘，否则过渡会被浏览器合并掉、直接闪现。
- 自动消失 **5200ms**；点击关闭按钮立即移除；移除时先切回关闭态再等过渡结束（约 320ms）后从 DOM 摘除，不要直接 `remove()`。
- **堆叠上限 3 条**，超出时移除最旧的一条。
- ARIA：容器 `aria-live="polite"`（`danger` 用 `assertive`）；卡片 `role="status"`（`danger` 用 `role="alert"`）。
- **不要用 Toast 承载需要用户操作的错误** —— 它会自己消失。这类错误用 Alert 或 Dialog。

### 4.26 Command Palette（⌘K）

全局命令入口。用于"知道要做什么、但不知道在哪个菜单"的场景。

- 尺寸：宽 560px、**置顶 12vh**（不用垂直居中 —— 居中会让列表随结果长度上下跳动）、圆角 `--np-radius-lg`、`--np-shadow-e3`。
- 顶部搜索行：高 52px、内边距 `0 16px`、16px 图标 + 无边框输入 + 底部 1px `border-subtle`。
- 列表：最大高 320px、内边距 8px、项高 40px、圆角 `--np-radius-sm`、图标 16px `text-tertiary`、`gap` 10px；键盘选中项底 `bg-active`。
- 分组标题 11px `text-tertiary`；底部快捷键说明条 11px `text-tertiary`、`gap` 16px、上边框 `border-subtle`。
- 行为：`⌘K` / `Ctrl+K` 全局唤起 → 输入即筛 → `↑/↓` 选择 → `Enter` 执行 → `Esc` / 点阴影关闭。打开后焦点进输入框（延迟约 60ms，等过渡开始再抢焦点）。
- **列表为空时必须显示"无匹配命令"**，不要留白（留白会被读成"卡住了"）。
- ARIA：`role="dialog"` + `aria-modal="true"`；输入框 `role="combobox"` + `aria-expanded` + `aria-activedescendant`；列表 `role="listbox"`、项 `role="option"`。

### 4.27 空状态与加载态

| 状态 | 规范 |
| --- | --- |
| 骨架屏 | 底色 `neutral-100`，圆角与真实元素一致（`--np-radius-sm`），1.4s 线性循环的 `opacity 1 → .4 → 1` 呼吸；**不使用扫光渐变**（暖画布上扫光会显脏） |
| 空状态 | 居中：40px 线性图标（`stroke 1.25`、`neutral-400`）+ 16px/600 标题 + 13px/400 说明 + Secondary 按钮；上下留白 64px；背景可用 `--np-gradient-glow` 做极淡聚光 |
| 无结果 | 图标 + "没有匹配的结果" + "清除筛选"文字按钮（`#046461`）。**必须与"空状态"区分**：空是"还没有数据"，无结果是"筛没了"，两者下一步动作不同 |
| 错误 | 卡片内用 Alert（`#FBE4E0` 底 + `#9A2C20` 字）+ `RotateCcw` 重试按钮 `btn-sm`；**不整页重定向**，保留用户上下文 |
| 加载 | 局部加载用骨架屏；按钮内加载用 §4.1 的 loading 态；**不要用全屏遮罩 spinner** |

- 空状态三件套缺一不可：**说清为什么空、说清下一步做什么、给一个可点的入口**。
- 加载超过 400ms 才显示骨架屏（400ms 内闪一下骨架反而是噪声）。

### 4.28 业务零件

数据页反复出现的五种零件，抽出来统一定义，避免每个页面各写一版。

**Stat Tile（轻量统计块）**

- 无边框、无底色（与卡片区分），内边距 `16px 20px`、`gap` 6px。
- 标签 12.5px/18 `text-secondary`；数值 22px/28 `tabular-nums`。
- 用在 Analytics 顶部：比 KPI 卡轻，因为这一页的主角是下面的漏斗和热力图，统计块只需给个锚点。
- 一行 3 个（`xl`）/ 2 个（`lg`）/ 1 个（`sm` 及以下）。

**横向条形（漏斗 / 设备分布）**

- 行结构：标签列 132px + 轨道 + 数值列 76px，`gap` 12px。
- 轨道：高 22px、圆角 `--np-radius-sm`、`neutral-100` 底、`overflow: hidden`。
- 填充：`--np-pine-600`，`transform: scaleX(var(--v))`、origin left，`--np-duration-chart` + `--np-ease-out`，**按行错峰 60ms**（`calc(var(--i) * 60ms)`）。
- 数值列右对齐 + `tabular-nums`；行间距 14px。
- **行序即数据顺序**（漏斗按转化步骤、设备按占比降序），不要按字母排。
- 禁用饼图 / 环形图（见 §5）。

**热力图（留存 / 密度）**

- 网格：首列 44px（行标签）+ 7 等分列，`gap` 3px。
- 单元：高 26px、圆角 `--np-radius-xs`、10px 字号；底色按数值取自 `pine-50 → pine-600` 阶梯，文字用对应的深色（`pine-700`）保证对比。
- 入场：`opacity 0→1`，`--np-duration-base`，**按格错峰 8ms**（密集网格用 8ms 而非 60ms，否则整块要等两秒）。总错峰时长控制在 400ms 内。
- 必须给图例（色阶 + 数值含义）—— 热力图的颜色是连续量，没有图例无法读数。

**看板 / 任务卡**

- 列：`xl` 下 3 列、`gap` 20px、`align-items: start`；列头 = 状态名 13px/600 + 计数徽标（11px、`neutral-100` 底、全圆角、内边距 `1px 6px`）。
- 任务卡：内边距 14px、圆角 `--np-radius-lg`、`background: bg-surface`、1px `border-default`、内部 `gap` 10px；悬停 `--np-shadow-e2` + 边框 `neutral-300` + `translateY(-1px)`（唯一允许的卡片位移，1px 足够）。
- 卡片结构：名称 13.5px/500 → 元信息行（右对齐数值）→ 底部行（头像组 / 进度）。
- 列与卡片都用 `--np-color-bg-surface`：**列是容器，不另设底色**，靠卡片边框与间距分组即可，加底色会让整页变成三块色块。
- `lg` 及以下降为单列堆叠。

**Subnav（二级导航）**

- 用于 Settings：左侧 200px、`sticky; top: 88px`、`gap` 2px。
- 条目：高 32px、水平内边距 10px、圆角 `--np-radius-sm`、字号 13px、文字 `text-secondary`；`gap` 8px。
- hover：底 `bg-hover` + 文字 `text-primary`；**活动项**：底 `bg-active` + 文字 `text-primary` + 字重 500。
- `md` 及以下转为横排换行（`flex-direction: row; flex-wrap: wrap`），取消 sticky。
- 与 Tabs 的分工：Subnav 在**页面左侧常驻**、切换的是页内区块（不改变 URL 主路径）；Tabs 在内容顶部、切换的是同一区块的视图。

**Toolbar（筛选条）**

- 卡片头顶的通栏，内边距 `12px 20px`，底部 1px `border-subtle`，`gap` 8px、可换行。
- 内容：Chip 组（已选筛选）+ 右侧 Secondary 按钮（`Columns` / `Export`）。筛选激活时按钮左侧带计数徽标。

---

## 5. 数据可视化规范

**图表选型**

| 目的 | 图表 | 组件 | 备注 |
| --- | --- | --- | --- |
| 趋势 | 面积折线（单序列）/ 折线（多序列） | Chart Container §4.8 | 单序列用 `--np-gradient-area` 填充 |
| 单值趋势 | 火花线（sparkline） | KPI §4.7 | 无轴无网格，72×36px |
| 构成对比 | 堆叠柱（离散时间） | Chart Container §4.8 | 序列 ≤ 4，超 4 归入"其他" |
| 构成占比 / 步骤转化 | 横向条形 | §4.28 横向条形 | **漏斗与占比共用同一零件**；禁用饼图 / 环形图（>3 类时不可读） |
| 分布 | 直方图 | §4.28 横向条形（旋转 90°） | 分箱数 ≤ 12 |
| 时间 × 类别密度 | 热力图 | §4.28 热力图 | 必须带色阶图例 |
| 相关性 | 散点 | — | 点透明度 0.6 |
| 单值进度 | 进度条 | §4.19 Progress | 不用圆环（本系统无圆环场景） |
| 状态流转 | 看板 | §4.28 看板 | 不是图表，但同属可视化语言 |

**通用规则**
- 折线 2px（`#046461`），**常驻不画描点**；hover 时才显示 8px 描点（白心 + 2px 主色边）。
- 面积图统一使用 `--np-gradient-area` 三段渐变：`rgba(4,100,97,.30)` → `rgba(161,216,211,.14)` → 透明，渐变终点为绘图区底部。**禁止**用单一纯色 20% 透明填充。
- y 轴从 0 起（除百分比类）；刻度数 4–5 个，标注缩写单位（`$45K`）。
- x 轴时间标签不超过 6 个，自动抽样，禁止斜排文字。
- 序列色按 `--np-chart-series-1…8` 顺序取用，**不得跨序跳用**；前 4 位优先。第 5 位起是低饱和大地色，已属扩展，超过 4 个序列优先考虑归并成"其他"。
- 堆叠柱的段间缝 0（不用白描边分隔），靠色阶明度差区分；必要时段间留 1px 透明缝。
- **图表生长动效**：条形 / 进度用 `scaleX`，序列间**错峰 60ms**，时长 `--np-duration-chart`（600ms）+ `--np-ease-out`。密集网格（热力图）降到 8ms/格，总错峰 ≤ 400ms。
- 所有图表必须支持：hover 详情、图例开关、时间范围切换、导出（PNG / CSV）。
- 数字统一 tabular-nums；金额 0 位小数或千分位、比率 2 位小数、时长用 `4m 12s` 这类紧凑写法。
- **每张图必须有标题**（说明它在回答什么），并给 `role="img"` + `aria-label` 复述结论（如"收入自 4 月起持续上升，5 月达到峰值"），不能只给"图表"。

**横向条形的排序规则**：漏斗按**转化步骤**（Sessions → Product views → Add to cart → Checkout → Purchase），设备按**占比降序**。**永远不要按字母排序** —— 条形的可读性完全依赖"长度即多少"的直觉，打乱顺序就毁了它。

---

## 6. 可访问性

| 项 | 要求 |
| --- | --- |
| 对比度 | 正文 ≥ 4.5:1；大字号 ≥ 3:1；图表轴标签 ≥ 4.5:1；非文本（图标/边框）≥ 3:1 |
| 暖画布校验 | `#837E75`（三级文字）在 `#F8F7F5` 上为 4.6:1，**是暖灰的文字下限**，不得再浅 |
| 侧栏校验 | 未选中文字 `rgba(255,255,255,.55)` 在 `#0B0B0A` 上为 5.2:1，达标；不得降到 `.45` 以下 |
| 色盲 | 状态不得只靠颜色区分，必须同时有文字或形状（胶囊文案 + 圆点/箭头） |
| 渐变上的文字 | 渐变跨度明度差 > 60% 时，文字置于浅端或加 `rgba(11,11,10,.35)` 遮罩 |
| 键盘 | 全站可 Tab 到达；焦点环 `0 0 0 3px rgba(4,100,97,.30)` 不可移除；弹层内焦点锁定，`Esc` 关闭 |
| 浮层关闭 | 遮罩浮层必须有三种等价关闭方式：**点阴影区**、`Esc`、关闭按钮；关闭后焦点回到触发元素 |
| 语义 | 表格用 `<table>/<th scope>`；图表容器加 `role="img"` + `aria-label` 描述结论；图标按钮必须 `aria-label` |
| 缩放 | 200% 缩放无横向滚动、无内容裁切 |
| 动效 | 尊重 `prefers-reduced-motion`（见 §2.6） |
| 触控 | 可点区域最小 32×32，移动端 44×44 |
| 图标可达 | 纯装饰图标 `aria-hidden="true"`；承载含义的图标（`Info`、状态圆点）要么 `aria-label`，要么旁边有等价文字 |

**组件 ARIA 对照表**（实现时逐项核对，不要靠"看起来对"）

| 组件 | 角色与属性 |
| --- | --- |
| Checkbox | `role="checkbox"` + `aria-checked`（`true` / `false` / `mixed`） |
| Radio | `role="radio"` + `aria-checked`；外层 `role="radiogroup"` + `aria-label` |
| Switch | `role="switch"` + `aria-checked` |
| 成组控件外壳 | `role="group"` + `aria-label`，让读屏能报出"通知设置，3 项" |
| Tabs | `role="tablist"` / `role="tab"` + `aria-selected` + `aria-controls`；面板 `role="tabpanel"` + `id` |
| Accordion | 触发器 `aria-expanded` + `aria-controls`；面板可加 `role="region"` + `aria-labelledby` |
| Segmented | 外层 `role="group"` + `aria-label`；按钮 `aria-selected`（或 `radiogroup` + `radio`） |
| Dropdown / Menu | 触发器 `aria-haspopup` + `aria-expanded`；菜单 `role="menu"`，项 `role="menuitem"`；分隔线 `role="separator"` |
| Dialog / Alert Dialog | `role="dialog"` / `role="alertdialog"` + `aria-modal="true"` + `aria-labelledby`；初始焦点落在取消或第一个可交互元素 |
| Sheet | 同 Dialog（`role="dialog"` + `aria-modal`） |
| Command Palette | `role="dialog"` + `aria-modal`；输入 `role="combobox"` + `aria-expanded` + `aria-activedescendant`；列表 `role="listbox"`、项 `role="option"` |
| Toast | 容器 `aria-live="polite"`（`danger` 用 `assertive`）；卡片 `role="status"` / `role="alert"` |
| Alert | `role="status"`（info / warning / success）/ `role="alert"`（danger） |
| Chip（筛选） | `aria-pressed`，或作为可移除标签时 `aria-label="移除 {条件}"` |
| Progress | `role="progressbar"` + `aria-valuenow` / `aria-valuemin` / `aria-valuemax` |
| Tooltip | 触发器 `aria-describedby` 指向气泡；气泡自身 `role="tooltip"` |
| 禁用态 | 用原生 `disabled`（可聚焦性与读屏都会正确跳过）；不要只靠 `opacity` 表示禁用 |
| 纯装饰元素 | `aria-hidden="true"`，避免读屏念出无意义的 SVG |

**三条容易被漏掉的**：

1. **行操作按钮**必须能被键盘发现：`opacity: 0` 的隐藏方式会让读屏仍能聚焦但视觉不可见，因此显示条件里要包含 `:focus-within`（见 §4.9）。
2. **Toast / Alert 的消息文本要是完整句子**，读屏会脱离视觉上下文朗读 —— "出错了"没有意义，要写"无法连接到分析集群"。
3. **`Esc` 关闭后焦点必须回到触发元素**，否则键盘用户会被丢回页面开头，需要重新 Tab 一遍。

---

## 7. 内容与文案规范

- **语言**：界面文案以英文为主（`Revenue`、`Export`、`On Track`），说明性补充可用中文；同一产品内不混用（不要一处 `Export` 一处"导出"）。
- **标题**：名词短语，首字母大写（英文），不加句号。`Overview`、`Revenue Over Time`。动词短语只出现在按钮上。
- **指标名**：业务口径一致，全站统一。`Revenue`（不混用 `Income`/`Sales`）。
- **对比说明**：固定句式 `vs {起} – {止}`，日期用 `MMM D` 缩写（跨年才带年份），中划线前后加空格。`vs Apr 13 – May 12`
- **数值格式**：千分位逗号；金额带币种符号并紧贴数字（`$1,248,000`）；百分比 2 位小数（`3.62%`）；趋势百分比 1 位小数（`↑ 12.5%`，箭头与数值之间空格）；时长用紧凑写法 `4m 12s`。
- **状态词**：`On Track` / `At Risk` / `Blocked` 为**枚举值**，禁止自由填写、禁止翻译成其他说法。新增状态必须先登记进 Term 表。
- **套餐 / 等级词**：`Pro` / `Enterprise` 等用 Accent 胶囊（§4.5），与状态胶囊分开，不共用配色语义。
- **按钮**：动宾结构，2–4 字。`Export`、`Columns`、`Add Project`。**不使用"确定 / 取消"式的空泛动词**，用具体动作（`Delete project` / `Keep it`）。
- **Alert 文案**：`标题（结论）+ 描述（下一步）`。
  - 好："Churn 已连续 3 周上升" + "当前 1.80%，超过 1.50% 的告警阈值。"
  - 坏："警告" + "指标异常。"
- **Toast 文案**：一句话说清**发生了什么**，必要时补一句**要不要管**。
  - 好："项目已归档" + "可在 Reports → Archived 中恢复。"
  - 坏："操作成功"。
- **错误文案**：说**怎么改**，不说"格式错误"。`只能包含小写字母、数字与连字符`。
- **空状态**：`标题（结论）+ 说明（下一步）` + 一个可点入口。`还没有项目` / `连接数据源后即可查看项目指标` / `Connect source`。
- **等宽字体（`--np-font-mono`）**只用于：令牌名、ID / 哈希、快捷键规格串（如 `h32 · px12 · radius 8`）、代码片段。**不用于数值** —— 数值靠 `tabular-nums` 就够了，换字体反而破坏行内节奏。
- **术语表**：产品内所有指标名、状态名、导航名维护在统一 Term 表中，UI 文案不得出现同义词变体。
- **省略号**：截断用 `…`（单个字符），不用 `...`；按钮文案不加省略号（`Delete` 而不是 `Delete…`），除非它确实会先打开一个确认框 —— 那种情况下**加上** `…` 是正确且推荐的信号。

---

## 8. 工程落地

### 8.1 令牌落地（CSS 变量）

```css
:root {
  /* ---------- Primitive: Warm Neutral ---------- */
  --np-neutral-0:#FFFFFF;   --np-neutral-25:#FCFBFA;  --np-neutral-50:#F8F7F5;
  --np-neutral-100:#F1EFEA; --np-neutral-200:#E6E3DC; --np-neutral-300:#D5D1C8;
  --np-neutral-400:#ABA69C; --np-neutral-500:#837E75; --np-neutral-600:#605B53;
  --np-neutral-700:#3D3833; --np-neutral-800:#24211D; --np-neutral-900:#16140F;
  --np-neutral-950:#0B0B0A;

  /* ---------- Primitive: Pine（品牌 · 给定色值） ---------- */
  --np-pine-50:#F1F9F5;  --np-pine-100:#DEEFE5; --np-pine-200:#CCF8E7;
  --np-pine-300:#B4CFCA; --np-pine-400:#A1D8D3; --np-pine-500:#457C6C;
  --np-pine-600:#046461; --np-pine-700:#03514F; --np-pine-800:#023C3B;
  --np-pine-900:#022A29;

  /* ---------- Primitive: Semantic Raw ---------- */
  --np-green-100:#DFF2E6; --np-green-600:#1B7A4B; --np-green-700:#14603B;
  --np-amber-100:#FBEDD8; --np-amber-600:#B87A1C; --np-amber-700:#8E5C10;
  --np-red-100:#FBE4E0;   --np-red-600:#C0392B;   --np-red-700:#9A2C20;
  --np-blue-100:#E4EDF4;  --np-blue-600:#35678F;

  /* ---------- Semantic: Color ---------- */
  --np-color-bg-canvas:#F8F7F5;
  --np-color-bg-surface:#F8F7F5;
  --np-color-bg-surface-subtle:#F1EFEA;
  --np-color-bg-inverse:#0B0B0A;
  --np-color-bg-hover:#F1EFEA;
  --np-color-bg-active:#E6E3DC;
  --np-color-bg-selected:var(--np-pine-100);
  --np-color-bg-overlay:rgba(11,11,10,.45);
  --np-color-border-default:#E6E3DC;
  --np-color-border-strong:#D5D1C8;
  --np-color-border-subtle:#F1EFEA;
  --np-color-text-primary:#0B0B0A;
  --np-color-text-secondary:#605B53;
  --np-color-text-tertiary:#837E75;
  --np-color-text-disabled:#ABA69C;
  --np-color-text-inverse:#FFFFFF;
  --np-color-text-inverse-muted:rgba(255,255,255,.55);
  --np-color-accent:#046461;
  --np-color-accent-hover:#457C6C;
  --np-color-accent-subtle:#DEEFE5;
  --np-color-action-primary-bg:#16140F;
  --np-color-action-primary-bg-hover:#24211D;
  --np-color-focus-ring:rgba(4,100,97,.30);
  --np-color-success:#14603B; --np-color-success-bg:#DFF2E6;
  --np-color-warning:#8E5C10; --np-color-warning-bg:#FBEDD8;
  --np-color-danger:#9A2C20;  --np-color-danger-bg:#FBE4E0;
  --np-color-info:#35678F;    --np-color-info-bg:#E4EDF4;
  --np-color-trend-up:#1B7A4B;
  --np-color-trend-down:#C0392B;

  /* ---------- Sidebar: 透明白体系 ---------- */
  --np-color-nav-bg:#0B0B0A;
  --np-color-nav-divider:rgba(255,255,255,.08);
  --np-color-nav-item-hover-bg:rgba(255,255,255,.05);
  --np-color-nav-item-active-bg:rgba(255,255,255,.08);
  --np-color-nav-item-pressed-bg:rgba(255,255,255,.12);
  --np-color-nav-indicator:rgba(255,255,255,.70);
  --np-color-nav-text:rgba(255,255,255,.55);
  --np-color-nav-text-active:#FFFFFF;
  --np-color-nav-badge-bg:rgba(255,255,255,.12);

  /* ---------- Chart ---------- */
  --np-chart-series-1:#046461; --np-chart-series-2:#457C6C;
  --np-chart-series-3:#A1D8D3; --np-chart-series-4:#B4CFCA;
  --np-chart-series-5:#C9C5BC; --np-chart-series-6:#8A9E96;
  --np-chart-series-7:#B58C7E; --np-chart-series-8:#D4C3A8;
  --np-chart-grid:#ECEAE5; --np-chart-axis-text:#837E75;
  --np-chart-line:#046461; --np-chart-dot:#FFFFFF;
  --np-chart-tooltip-bg:#FFFFFF;

  /* ---------- Gradient（唯一氛围手段） ---------- */
  --np-gradient-brand:linear-gradient(135deg,#CCF8E7 0%,#A1D8D3 32%,#457C6C 68%,#046461 100%);
  --np-gradient-brand-soft:linear-gradient(135deg,#DEEFE5 0%,#CCF8E7 55%,#A1D8D3 100%);
  --np-gradient-area:linear-gradient(180deg,rgba(4,100,97,.30) 0%,rgba(161,216,211,.14) 45%,rgba(4,100,97,0) 100%);
  --np-gradient-spark:linear-gradient(180deg,rgba(4,100,97,.22) 0%,rgba(204,248,231,0) 100%);
  --np-gradient-sage:linear-gradient(160deg,#DEEFE5 0%,#B4CFCA 100%);
  --np-gradient-ink:linear-gradient(180deg,#023C3B 0%,#022A29 60%,#0B0B0A 100%);
  --np-gradient-nav:linear-gradient(90deg,rgba(255,255,255,.10) 0%,rgba(255,255,255,.04) 100%);
  --np-gradient-glow:radial-gradient(120% 100% at 50% 0%,rgba(204,248,231,.28) 0%,rgba(4,100,97,0) 70%);

  /* ---------- Typography ---------- */
  --np-font-sans:"Inter","Inter Variable",-apple-system,BlinkMacSystemFont,
    "Segoe UI","PingFang SC","HarmonyOS Sans SC","Microsoft YaHei","Noto Sans SC",sans-serif;
  --np-font-mono:"JetBrains Mono","SF Mono",ui-monospace,Consolas,monospace;

  --np-text-display-xl:600 40px/46px var(--np-font-sans);
  --np-text-display:600 32px/38px var(--np-font-sans);
  --np-text-h1:600 26px/32px var(--np-font-sans);
  --np-text-h2:600 20px/28px var(--np-font-sans);
  --np-text-h3:600 16px/24px var(--np-font-sans);
  --np-text-metric:600 30px/36px var(--np-font-sans);
  --np-text-metric-sm:600 22px/28px var(--np-font-sans);
  --np-text-body:400 14px/22px var(--np-font-sans);
  --np-text-body-strong:500 14px/22px var(--np-font-sans);
  --np-text-body-sm:400 13px/20px var(--np-font-sans);
  --np-text-label:500 14px/20px var(--np-font-sans);
  --np-text-table-head:500 12.5px/18px var(--np-font-sans);
  --np-text-caption:400 12px/16px var(--np-font-sans);
  --np-text-micro:500 11px/14px var(--np-font-sans);

  /* ---------- Spacing / Size / Radius ---------- */
  --np-space-1:4px;  --np-space-2:8px;  --np-space-3:12px; --np-space-4:16px;
  --np-space-5:20px; --np-space-6:24px; --np-space-8:32px; --np-space-10:40px;
  --np-space-12:48px; --np-space-16:64px;
  --np-size-sidebar:240px; --np-size-sidebar-collapsed:64px; --np-size-topbar:64px;
  --np-size-control-sm:28px; --np-size-control-md:32px; --np-size-control-lg:40px;
  --np-size-row:44px; --np-size-table-head:40px;
  --np-size-spark-w:72px; --np-size-spark-h:36px;
  --np-size-chart-md:240px; --np-size-chart-lg:320px;
  --np-size-icon:16px; --np-size-icon-lg:20px;
  --np-size-avatar-sm:20px; --np-size-avatar-md:24px; --np-size-avatar-lg:32px;
  --np-radius-xs:4px; --np-radius-sm:6px; --np-radius-md:8px;
  --np-radius-lg:12px; --np-radius-xl:16px; --np-radius-full:999px;

  /* ---------- Elevation / Motion ---------- */
  --np-shadow-e1:0 1px 2px rgba(11,11,10,.05);
  --np-shadow-e2:0 4px 12px rgba(11,11,10,.07);
  --np-shadow-e3:0 8px 24px rgba(11,11,10,.09);
  --np-shadow-e4:0 24px 64px rgba(11,11,10,.18);
  --np-duration-instant:100ms; --np-duration-fast:140ms;
  --np-duration-base:200ms;    --np-duration-slow:280ms;
  --np-duration-chart:600ms;
  --np-ease-standard:cubic-bezier(.2,.8,.2,1);
  --np-ease-in-out:cubic-bezier(.4,0,.2,1);
  --np-ease-out:cubic-bezier(0,0,.2,1);
}

/* 数字等宽：全站强制 */
.np-num, td, th, .np-metric { font-variant-numeric: tabular-nums; font-feature-settings:"tnum" 1; }
```

### 8.2 动效原语（直接抄）

§2.6 定义的 7 种原语在这里落成可直接复制的 CSS。**不要在组件里另写一套** —— 全站只能有一份。

```css
/* ============================================================
   ① 菜单 / Popover —— origin 锚在触发侧
   ============================================================ */
.pop {
  transform-origin: var(--pop-origin, top left);
  opacity: 0; visibility: hidden;
  transform: translateY(-4px) scale(.96);
  transition: opacity var(--np-duration-fast) var(--np-ease-out),
              transform var(--np-duration-fast) var(--np-ease-out),
              visibility 0s linear var(--np-duration-fast);
}
.pop[data-state="open"] {
  opacity: 1; visibility: visible; transform: none;
  transition: opacity var(--np-duration-fast) var(--np-ease-out),
              transform var(--np-duration-fast) var(--np-ease-out),
              visibility 0s linear 0s;
}

/* ============================================================
   ② Dialog —— 居中，不设 transform-origin
   ============================================================ */
.overlay-wrap {
  opacity: 0; visibility: hidden;
  transition: opacity var(--np-duration-base) var(--np-ease-out),
              visibility 0s linear var(--np-duration-base);
}
.overlay-wrap[data-state="open"] {
  opacity: 1; visibility: visible;
  transition: opacity var(--np-duration-base) var(--np-ease-out),
              visibility 0s linear 0s;
}
.dialog { transform: translateY(4px) scale(.96);
  transition: transform var(--np-duration-base) var(--np-ease-out); }
.overlay-wrap[data-state="open"] .dialog { transform: none; }

/* ============================================================
   ③ 遮罩 Scrim
   ============================================================ */
.scrim {
  opacity: 0; visibility: hidden;
  transition: opacity var(--np-duration-base) var(--np-ease-out),
              visibility 0s linear var(--np-duration-base);
}
.scrim[data-state="open"] {
  opacity: 1; visibility: visible;
  transition: opacity var(--np-duration-base) var(--np-ease-out),
              visibility 0s linear 0s;
}

/* ============================================================
   ④ Sheet —— 大位移（≥100px）用 ease-in-out
   ============================================================ */
.sheet {
  visibility: hidden; transform: translateX(100%);
  transition: transform var(--np-duration-slow) var(--np-ease-in-out),
              visibility 0s linear var(--np-duration-slow);
}
.sheet[data-state="open"] {
  visibility: visible; transform: none;
  transition: transform var(--np-duration-slow) var(--np-ease-in-out),
              visibility 0s linear 0s;
}

/* ============================================================
   ⑤ Toast —— 必须用 transition（可被连续触发重定向）
   ============================================================ */
.toast {
  opacity: 0; transform: translateX(100%);
  transition: opacity var(--np-duration-slow) var(--np-ease-out),
              transform var(--np-duration-slow) var(--np-ease-out);
}
.toast[data-state="open"] { opacity: 1; transform: none; }
/* JS：打开前用双 rAF 让初始态先落盘，否则过渡会被合并掉、直接闪现
   requestAnimationFrame(() => requestAnimationFrame(() => el.dataset.state = 'open')); */

/* ============================================================
   ⑥ Tooltip / Navtip
   ============================================================ */
.navtip {
  opacity: 0; transform: translateX(-4px); pointer-events: none;
  transition: opacity var(--np-duration-fast) var(--np-ease-out),
              transform var(--np-duration-fast) var(--np-ease-out);
}
.navtip[data-state="open"] { opacity: 1; transform: none; }

/* ============================================================
   ⑦ 视图 / Tab 面板切换
   ============================================================ */
.view.active, .tabpanel.active {
  animation: np-view-in var(--np-duration-base) var(--np-ease-out) both;
}
@keyframes np-view-in { from { opacity: 0; transform: translateY(4px); } }

/* ============================================================
   ⑧ 位置切换类（只走 transform，用 ease-standard）
   ============================================================ */
.seg-thumb {                                   /* Segmented 滑块 */
  transform: translateX(calc(100% * var(--i, 0)));
  transition: transform var(--np-duration-base) var(--np-ease-standard);
}
.tab::after {                                  /* Tabs 下划线 */
  opacity: 0; transform: scaleX(.6); transform-origin: center;
  transition: opacity var(--np-duration-base) var(--np-ease-standard),
              transform var(--np-duration-base) var(--np-ease-out);
}
.tab[aria-selected="true"]::after { opacity: 1; transform: none; }

/* ============================================================
   ⑨ Accordion —— 唯一允许的高度动画（grid-template-rows）
   ============================================================ */
.acc-panel {
  display: grid; grid-template-rows: 0fr;
  transition: grid-template-rows var(--np-duration-base) var(--np-ease-standard);
}
.acc-panel[data-state="open"] { grid-template-rows: 1fr; }
.acc-panel > div { overflow: hidden; }

/* ============================================================
   ⑩ 数据生长（条形 / 热力图 / 进度）
   ============================================================ */
.bar-fill {
  transform: scaleX(var(--v, 0)); transform-origin: left center;
  animation: np-grow var(--np-duration-chart) var(--np-ease-out) both;
  animation-delay: calc(var(--i, 0) * 60ms);      /* 序列错峰 60ms */
}
@keyframes np-grow { from { transform: scaleX(0); } to { transform: scaleX(var(--v, 0)); } }
.heat-cell {
  animation: np-fade var(--np-duration-base) var(--np-ease-out) both;
  animation-delay: calc(var(--i, 0) * 8ms);       /* 密集网格降到 8ms/格 */
}
@keyframes np-fade { from { opacity: 0; } }
.progress > i {
  transform: scaleX(var(--v, 0)); transform-origin: left center;
  transition: transform var(--np-duration-base) var(--np-ease-out);
}

/* ============================================================
   ⑪ 骨架呼吸 / 加载转圈
   ============================================================ */
.skeleton { background: var(--np-neutral-100);
  animation: np-pulse 1.4s linear infinite; }
@keyframes np-pulse { 0%, 100% { opacity: 1; } 50% { opacity: .4; } }

.btn.is-loading::after {
  content: ""; position: absolute; inset: 0; margin: auto;
  width: 14px; height: 14px; border-radius: 50%;
  border: 2px solid rgba(255,255,255,.35); border-top-color: #FFFFFF;
  animation: np-spin .6s linear infinite;
}
@keyframes np-spin { to { transform: rotate(360deg); } }

/* ============================================================
   ⑫ 降级：保留状态指示（透明度），去掉所有位移与缩放
   ============================================================ */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: .01ms !important; animation-iteration-count: 1 !important;
    transition-duration: .01ms !important; scroll-behavior: auto !important;
  }
  .pop, .dialog, .toast, .navtip, .sheet { transform: none !important; }
  .bar-fill, .progress > i { animation: none !important; }
  .view.active, .tabpanel.active { animation: none !important; }
}
```

**两条容易写错的 JS 配套**

```js
/* Toast：先落初始态，再切 open（双 rAF） */
requestAnimationFrame(() => requestAnimationFrame(() => el.dataset.state = 'open'));

/* 移除 Toast：先切回关闭态，再等过渡结束才摘 DOM，不要直接 remove() */
el.dataset.state = 'closed';
setTimeout(() => el.remove(), 320);   // ≈ --np-duration-slow + 余量
```

### 8.3 常用组合（直接抄）

```css
/* 应用外壳 */
.np-app        { background: var(--np-color-bg-canvas); color: var(--np-color-text-primary); }
.np-sidebar    { width: var(--np-size-sidebar); background: var(--np-color-nav-bg); }

/* 侧栏活动项：透明白三层 */
.np-nav-item          { height:36px; border-radius:var(--np-radius-md);
                        color:var(--np-color-nav-text); transition:background var(--np-duration-fast) var(--np-ease-standard); }
.np-nav-item:hover    { background:var(--np-color-nav-item-hover-bg); }
.np-nav-item--active  { position:relative; background:var(--np-gradient-nav);
                        color:var(--np-color-nav-text-active); font-weight:500; }
.np-nav-item--active::before { content:""; position:absolute; left:0; top:8px; bottom:8px;
                        width:2px; border-radius:1px; background:var(--np-color-nav-indicator); }

/* 卡片：与画布同色 #F8F7F5，靠 1px 边框分离 */
.np-card       { background:var(--np-color-bg-surface); border:1px solid var(--np-color-border-default);
                 border-radius:var(--np-radius-lg); padding:var(--np-space-5); }

/* 面积图填充 */
.np-chart-area { fill:url(#npAreaGradient); }           /* SVG: linearGradient 180deg，三色标 */
.np-chart-area-css { background:var(--np-gradient-area); }

/* 品牌强调块 */
.np-hero       { background:var(--np-gradient-brand); color:#FFFFFF; }

/* 表格整行：hover / 按下 / 点击瞬时反馈 / 持久选中 */
tr:hover       { background:var(--np-color-bg-hover); }
tr:active      { background:var(--np-color-bg-active); }
tr[data-flash] { background:var(--np-color-bg-selected); box-shadow:inset 2px 0 0 var(--np-color-accent); }
tr[aria-selected="true"] { background:var(--np-color-bg-selected); box-shadow:inset 2px 0 0 var(--np-color-accent); }
/* 行操作：hover 与键盘聚焦都要显形 */
.np-row-actions { opacity:0; transition:opacity var(--np-duration-fast) var(--np-ease-standard); }
tr:hover .np-row-actions, tr:focus-within .np-row-actions { opacity:1; }
```

**侧栏收起态（居中三件套，漏一条就会偏）**

```css
.app.collapsed .logo,
.app.collapsed .nav-item,
.app.collapsed .sidebar-user { justify-content:center; padding:0; gap:0; }

/* ① 纯文字：退出布局流，但保留淡出过渡 */
.app.collapsed .logo-name,
.app.collapsed .nav-label,
.app.collapsed .user-info   { flex:0 0 0; width:0; overflow:hidden; opacity:0; }

/* ② 带 margin-left:auto 的徽标 / chevron：必须完全脱流 */
.app.collapsed .nav-badge,
.app.collapsed .user-chevron { position:absolute; opacity:0; pointer-events:none; }
```

**表单控件**

```css
.np-input { height:var(--np-size-control-md); padding:0 10px; font-size:14px;
  border:1px solid var(--np-color-border-default); border-radius:var(--np-radius-md); background:#FFFFFF;
  transition:border-color var(--np-duration-fast) var(--np-ease-standard),
             box-shadow var(--np-duration-fast) var(--np-ease-standard); }
.np-input:hover { border-color:var(--np-color-border-strong); }
.np-input:focus { border-color:var(--np-color-border-strong); box-shadow:0 0 0 3px rgba(4,100,97,.22); }
.np-input[aria-invalid="true"] { border-color:var(--np-red-600); box-shadow:0 0 0 3px rgba(192,57,43,.20); }
.np-textarea { height:auto; min-height:88px; padding:8px 10px; line-height:22px; resize:vertical; }

/* 勾选态一律用 scale 入场，不用 opacity 硬切 */
.np-checkbox { width:16px; height:16px; border-radius:var(--np-radius-xs);
  border:1px solid var(--np-color-border-strong); background:#FFFFFF; display:grid; place-items:center; }
.np-checkbox svg { width:11px; height:11px; opacity:0; transform:scale(.6);
  transition:opacity var(--np-duration-instant) var(--np-ease-standard),
             transform var(--np-duration-fast) var(--np-ease-out); }
.np-checkbox[aria-checked="true"],
.np-checkbox[aria-checked="mixed"] { background:var(--np-color-action-primary-bg);
  border-color:var(--np-color-action-primary-bg); }
.np-checkbox[aria-checked="true"] svg,
.np-checkbox[aria-checked="mixed"] svg { opacity:1; transform:none; }

.np-switch { width:36px; height:20px; border-radius:var(--np-radius-full);
  background:var(--np-neutral-300); position:relative; padding:0; border:0;
  transition:background var(--np-duration-fast) var(--np-ease-standard); }
.np-switch > i { position:absolute; top:2px; left:2px; width:16px; height:16px; border-radius:50%;
  background:#FFFFFF; box-shadow:var(--np-shadow-e1); transition:transform var(--np-duration-fast) var(--np-ease-out); }
.np-switch[aria-checked="true"] { background:var(--np-color-accent); }
.np-switch[aria-checked="true"] > i { transform:translateX(16px); }
```

**Segmented / Accordion / Progress / Chip**

```css
.np-seg { --n:2; display:grid; grid-template-columns:repeat(var(--n),1fr);
  position:relative; padding:3px; border-radius:var(--np-radius-md); background:var(--np-neutral-100); }
.np-seg-thumb { position:absolute; top:3px; bottom:3px; left:3px;
  width:calc((100% - 6px) / var(--n)); background:#FFFFFF;
  border-radius:var(--np-radius-sm); box-shadow:var(--np-shadow-e1); }
/* 位移见 §8.2 ⑧ */

.np-acc-panel { display:grid; grid-template-rows:0fr; }
.np-acc-panel[data-state="open"] { grid-template-rows:1fr; }
.np-acc-panel > div { overflow:hidden; }
/* 过渡见 §8.2 ⑨；面板内文字同时 opacity 0→1 */

.np-progress { height:6px; border-radius:var(--np-radius-full);
  background:var(--np-neutral-100); overflow:hidden; }
.np-progress > i { display:block; height:100%; border-radius:var(--np-radius-full);
  background:var(--np-color-accent); }
/* scaleX + origin 见 §8.2 ⑩ */

.np-chip { height:28px; padding:0 10px; border-radius:var(--np-radius-full);
  border:1px solid var(--np-color-border-default); background:#FFFFFF;
  display:inline-flex; align-items:center; gap:6px; font-size:12px;
  color:var(--np-color-text-secondary); }
.np-chip[aria-pressed="true"] { background:var(--np-color-accent-subtle);
  border-color:var(--np-pine-300); color:var(--np-pine-700); font-weight:500; }
```

**Toast 容器（`pointer-events` 是重点）**

```css
.np-toast-region { position:fixed; right:24px; bottom:24px; z-index:100;
  display:flex; flex-direction:column; align-items:flex-end; gap:12px;
  pointer-events:none; }                 /* 空容器不能挡住右下角的点击 */
.np-toast { width:340px; padding:14px; border-radius:var(--np-radius-md);
  background:#FFFFFF; border:1px solid var(--np-color-border-default);
  box-shadow:var(--np-shadow-e3); pointer-events:auto; }
```

**看板 / 任务卡**

```css
.np-board { display:grid; grid-template-columns:repeat(3, minmax(0,1fr)); gap:20px; align-items:start; }
.np-task { padding:14px; border-radius:var(--np-radius-lg);
  background:var(--np-color-bg-surface); border:1px solid var(--np-color-border-default);
  display:flex; flex-direction:column; gap:10px;
  transition:box-shadow var(--np-duration-fast) var(--np-ease-standard),
             border-color var(--np-duration-fast) var(--np-ease-standard),
             transform var(--np-duration-fast) var(--np-ease-out); }
@media (hover:hover) and (pointer:fine) {
  .np-task:hover { box-shadow:var(--np-shadow-e2); border-color:var(--np-neutral-300); transform:translateY(-1px); }
}
```

**横向条形 / 热力图**

```css
.np-bar-row  { display:grid; grid-template-columns:132px 1fr 76px; align-items:center; gap:12px; }
.np-bar-track{ height:22px; border-radius:var(--np-radius-sm); background:var(--np-neutral-100); overflow:hidden; }
.np-bar-fill { height:100%; border-radius:var(--np-radius-sm); background:var(--np-pine-600); }
/* 生长动效见 §8.2 ⑩，序列错峰 60ms */

.np-heat { display:grid; grid-template-columns:44px repeat(7,1fr); gap:3px; align-items:center; }
.np-heat-cell { height:26px; border-radius:var(--np-radius-xs);
  display:grid; place-items:center; font-size:10px; }   /* 底色按数值取 pine-50→pine-600 阶梯 */
```

### 8.4 浅色 / 深色主题

深色主题只允许覆盖**语义层**，不改组件层与基础层。深色底从品牌深墨绿 `#022A29` 起手，而不是纯中性黑。

```css
[data-theme="dark"] {
  --np-color-bg-canvas:#0B0F0E;
  --np-color-bg-surface:#121716;
  --np-color-bg-surface-subtle:#171D1B;
  --np-color-bg-hover:#171D1B;
  --np-color-bg-active:#1E2523;
  --np-color-bg-selected:rgba(161,216,211,.14);
  --np-color-border-default:#242B29;
  --np-color-border-strong:#333B38;
  --np-color-border-subtle:#1B2220;
  --np-color-text-primary:#F2F5F4;
  --np-color-text-secondary:#A2AAA7;
  --np-color-text-tertiary:#837E75;
  --np-color-action-primary-bg:#F2F5F4;
  --np-color-action-primary-bg-hover:#FFFFFF;
  --np-color-text-inverse:#0B0B0A;          /* 主按钮文字反相 */
  --np-color-accent:#A1D8D3;                /* 深底上提亮，保证对比 */
  --np-color-accent-hover:#B4CFCA;
  --np-color-accent-subtle:rgba(4,100,97,.22);
  --np-color-focus-ring:rgba(161,216,211,.35);
  --np-color-success-bg:rgba(27,122,75,.20);
  --np-color-warning-bg:rgba(184,122,28,.20);
  --np-color-danger-bg:rgba(192,57,43,.20);
  --np-chart-grid:#1B2220;
  --np-chart-area:linear-gradient(180deg,rgba(161,216,211,.32) 0%,rgba(4,100,97,.10) 45%,rgba(4,100,97,0) 100%);
  --np-gradient-brand-soft:linear-gradient(135deg,rgba(4,100,97,.35) 0%,rgba(161,216,211,.18) 100%);
  --np-gradient-ink:linear-gradient(180deg,#023C3B 0%,#022A29 100%);
}
```

> 深色主题下 `--np-color-accent` 必须从 `#046461` 提亮到 `#A1D8D3`，否则深底上的强调色对比度不足 3:1。

### 8.5 Tailwind 主题映射（shadcn 形状）

Tailwind 主题统一采用 shadcn 的 `hsl(var(--x))` 写法，组件内用 `bg-background text-foreground border-border` 而非 `bg-canvas`。完整 `tailwind.config.js`（含 `darkMode:["class"]`、Radix 原语与侧栏专用 `sidebar` 色组、渐变工具类）随组件库仓库交付，其色值来源即本节 §8.1 令牌与下方红线。此处只标注与旧版（直连 `--np-*`）的差异红线：

- 组件 class **禁止**出现 `bg-canvas / text-ink / bg-pine-600`，一律改用 `bg-background / text-foreground / bg-primary`。
- 圆角改用 `--radius-*` 派生变量（`sm/md/lg/xl`），不再直接用 `--np-radius-md`。
- 渐变走 `bg-np-area / bg-np-brand` 等工具类（见 §8.1 的 `--np-gradient-*` 定义）。

### 8.6 命名规范

| 对象 | 规则 | 示例 |
| --- | --- | --- |
| 设计令牌 | `--np-{层}-{类别}-{修饰}`，kebab-case | `--np-color-text-secondary` |
| 渐变令牌 | `--np-gradient-{用途}` | `--np-gradient-area` |
| 组件类 | `np-{block}__{element}--{modifier}`（BEM） | `np-card__header--compact` |
| React 组件 | PascalCase，变体用 props | `<Button variant="secondary" size="md" />` |
| Figma 组件 | `{Category} / {Name} / {Variant} / {Size} / {State}` | `Button / Primary / MD / Hover` |
| 图标 | PascalCase，语义化命名 | `IconArrowUp`, `IconMoreHorizontal` |

### 8.7 目录组织

```
tokens/        design tokens（JSON 源）→ 构建为 css / scss / ts / figma variables
components/    每个组件一目录：index.tsx · styles.ts · spec.md · __tests__
patterns/      复合模式（PageHeader、FilterBar、ChartCard、DataTable）
charts/        图表主题与封装（含渐变 defs 组件 <NpGradientDefs />）
icons/         图标组件
```

### 8.8 与 Figma 的对应

- Figma Variables 分两组：`primitive/*` 与 `semantic/*`，与本文档令牌一一对应。
- **渐变在 Figma 中必须发布为 Gradient Styles**（8 条），命名与 `--np-gradient-*` 完全一致，禁止设计同学手搓渐变。
- Figma 样式：Text Styles 命名 = 字阶段令牌名（`text/h1`、`text/metric`）；Effect Styles = `shadow/e1…e4`。
- 交付要求：每个组件有 `spec.md`（结构 · 尺寸 · 状态 · 令牌引用 · a11y），代码与 Figma 必须能逐项对照。

---

## 9. 治理与迭代

**版本规则**：语义化 `MAJOR.MINOR.PATCH`。色值/尺寸微调 → PATCH；新增令牌或组件变体 → MINOR；删除令牌、改变既有语义 → MAJOR（必须提供 6 个月弃用期与迁移脚本）。

**变更流程**
1. 提出需求（附使用场景截图，说明现有令牌为何不满足）。
2. 设计系统负责人评审：是否属于通用需求，是否能用现有令牌组合解决。
3. 通过后：更新本文档 → 更新 `tokens/` 源文件 → 构建产物 → 更新 Figma 变量。
4. 组件库发版，附 CHANGELOG 与迁移指引。

**红线（PR 审查必查）**
- 出现未登记的十六进制色值 / 硬编码字号 / 魔法间距。
- **出现冷灰色值**（`#F5F5F5`、`#EEEEEE`、`#FAFAFA` 等）——暖画布体系内一律视为错误。
- **手写渐变**，未使用 `--np-gradient-*` 令牌；或渐变方向不是 `135deg / 180deg`。
- 在按钮、文字、图标、边框、状态胶囊上使用渐变。
- 组件内直接引用基础层令牌（如 `var(--np-pine-600)`）。
- 卡片同时使用边框与 e2 以上阴影。
- 侧栏内使用品牌墨绿做选中态，而非透明白。
- 用 `#CCF8E7` 表达状态（品牌薄荷与 success 混淆）。
- **把 `--np-color-bg-hover` 回落成 `neutral-50`（`#F8F7F5`）**——它与画布/卡片同色，会让所有落在暖画布上的 hover 视觉上"消失"。
- 表格数值列未右对齐 / 未使用 tabular-nums。
- 图标按钮缺少 `aria-label`。
- 同一屏出现多个 Primary 按钮。
- **动效修改布局属性**（`width` / `height` / `top` / `left` / `margin` / `font-size`）——只许 `transform` 与 `opacity`；仅 4 处例外：表格列宽拖拽、侧栏展开收起、搜索框展开、手风琴 `grid-template-rows`（见 §2.6）。
- **会被连续触发的元素用 `@keyframes` 实现**（Toast 进出、表格行高亮必须用 `transition` + 双 `requestAnimationFrame` 触发）。
- **弹层动效位移超过 4px**（Sheet、Toast 的整条滑入是唯一例外），或未继承触发器的 `transform-origin`（右侧浮层从右上角展开，居中浮层从中心展开）。
- **`Accent` 胶囊被当作状态使用**（`#DEEFE5` / `#03514F` 只表等级与类别；状态一律走 Success / Warning / Danger / Info，见 §4.5）。
- **Toast 容器未设 `pointer-events: none`**（透明容器会吃掉右下角的所有点击；卡片自身设 `auto`）。
- **侧栏收起态只写 `opacity: 0`**（文字仍占位，图标不居中）——必须 `flex: 0 0 0; width: 0; overflow: hidden`，徽标与箭头改 `position: absolute`，父级 `gap: 0`（见 §4.11）。
- **浮层随手写 `z-index: 9999`**，未走 §4.14 的层级表（`pop 70 < scrim 80 < overlay 90 < navtip 95 < toast 100`）。

**度量**：令牌使用率（未登记色值出现次数 = 0）、冷灰色值出现次数 = 0、渐变令牌使用率、组件复用率、视觉走查缺陷数、设计交付到上线周期。

**文档 ↔ 原型一致性**

`Northpeak · Overview 原型.html` 是本文档的**参考实现**（reference implementation），不是规范本身。二者关系如下：

- 原型的 `:root` 登记 **132 个令牌**，已逐项与本文档核对，**没有一个是文档未登记的**；`§2.1–§2.6` 的表格与 `§8.1` 的 CSS 块是同一批令牌的两种表述。
- 另有 **34 个"规范声明、原型以字面量实现"的令牌**，它们不写进原型的 `:root`，改以 Figma 变量 / Tailwind 主题承载：`--np-text-*` 字阶 14 个（原型为可读性直接写 `font-size/line-height`）、组件尺寸 10 个（avatar / chart / icon / spark）、`--np-space-10/12/16` 3 个、`--np-border-*` 3 个、`--np-shadow-none/sidebar` 2 个、`--np-btn-primary-bg` 与 `--np-chart-area` 各 1 个。
- 原型新增页面或组件后，**先改本文档再改原型**；如遇原型先行（探索性实现），须在合并前把差异回填到本文档，避免规范滞后。
- 二者状态不一致时，**以本文档为准**，除非该处已在 §9 红线中标注为例外。

---

## 附录 A：令牌速查表

下表为原型 `:root` 的**实际登记量**（共 132 个），已逐项核对，无遗漏亦无未登记项。

| 类别 | 令牌前缀 | 数量 |
| --- | --- | --- |
| 暖中性 | `--np-neutral-*` | 13 |
| 品牌墨绿 | `--np-pine-*` | 10 |
| 语义原色 | `--np-{green,amber,red,blue}-*` | 11 |
| 语义色 | `--np-color-*` | 33（其中侧栏 `nav-*` 9） |
| 侧栏透明白 | `--np-color-nav-*` | 9 |
| 图表色 | `--np-chart-*` | 13 |
| **渐变** | `--np-gradient-*` | **8** |
| 字族 | `--np-font-*` | 2 |
| 间距尺寸 | `--np-space-*` / `--np-size-*` | 15 |
| 圆角 / 阴影 / 动效 | `--np-radius-*` / `--np-shadow-*` / `--np-duration-*` / `--np-ease-*` | 18 |
| **原型 `:root` 合计** | | **132** |

**另有 34 个"规范声明、原型以字面量实现"的令牌**（以 Figma 变量 / Tailwind 主题落地，不写进原型 `:root`，详见 §9）：

| 类别 | 数量 | 说明 |
| --- | --- | --- |
| 字阶 | 14 | `--np-text-*`：display-xl / display / h1 / h2 / h3 / metric / metric-sm / body / body-strong / body-sm / label / table-head / caption / micro |
| 组件尺寸 | 10 | `--np-size-avatar-{sm,md,lg}`、`--np-size-chart-{md,lg}`、`--np-size-icon{,-lg}`、`--np-size-spark{,-w,-h}` |
| 间距 | 3 | `--np-space-10/12/16` |
| 边框 | 3 | `--np-border-subtle` / `--np-border-default` / `--np-border-width` |
| 阴影 | 2 | `--np-shadow-none` / `--np-shadow-sidebar` |
| 其他 | 2 | `--np-btn-primary-bg` / `--np-chart-area` |


## 附录 B：品牌色值对照表

| 给定色值 | 令牌 | 角色 |
| --- | --- | --- |
| `#F8F7F5` | `--np-color-bg-canvas` | 内容区大背景（暖米白） |
| `#046461` | `--np-pine-600` / `--np-color-accent` | **主品牌色**（深墨绿） |
| `#457C6C` | `--np-pine-500` | 中间调（hover / 次级） |
| `#A1D8D3` | `--np-pine-400` | 亮青（图表次序列 / 描点） |
| `#B4CFCA` | `--np-pine-300` | 青灰（大面积柔和填充） |
| `#DEEFE5` | `--np-pine-100` | 浅底（选中 / 强调块） |
| `#CCF8E7` | `--np-pine-200` | 明亮薄荷（渐变起点 / 高亮） |
| `#0B0B0A` | `--np-color-bg-inverse` / `--np-color-nav-bg` | 侧栏近黑 |
| `rgba(255,255,255,.08 / .70)` | `--np-color-nav-item-active-bg` / `--np-color-nav-indicator` | 活动栏透明白标记 |

## 附录 C：Do / Don't

| ✅ Do | ❌ Don't |
| --- | --- |
| 画布与卡片同色 `#F8F7F5`，靠 1px 暖灰边框分离 | 画布混用冷灰 `#F5F5F5`；卡片用纯白"浮"出背景 |
| 侧栏活动项用透明白（.08 底 + .70 竖条） | 侧栏活动项用品牌墨绿实心底 |
| 渐变只用于背景 / 图表 / 插画 | 渐变用在按钮、文字、图标、胶囊上 |
| 渐变方向统一 135° / 180°，≥3 个色标 | 两点线性插值、方向乱来、引入紫粉色相 |
| 面积图用 `--np-gradient-area` 三段渐变 | 面积图用单一纯色 20% 透明填充 |
| 卡片用 1px 暖灰边框表达层级 | 卡片叠加多层阴影 |
| 主操作墨黑按钮，一屏一个 | 到处使用品牌墨绿实心按钮 |
| 趋势色按业务好坏判断 | 一律"上涨就绿、下跌就红" |
| 数值右对齐 + 等宽数字 | 数字左对齐、比例字体 |
| 图表只保留水平网格线 | 垂直 + 水平网格全画 |
| 状态用"浅底 + 深字 + 文字标签" | 状态用实心饱和块，或用 `#CCF8E7` 表状态 |
| 图表按序列色顺序取色 | 随机挑色 / 使用彩虹色 |
| 深色侧栏只用白 + 透明度层次 | 侧栏引入第三个色相 |
| 动效只动 `transform` / `opacity`，位移 ≤ 4px | 动效改宽高 / `top` / `left`，或位移超过 4px |
| 连续触发的 Toast、行高亮用 `transition`（双 rAF） | 连续触发元素用 `@keyframes`，重放丢帧 |
| 弹层 `transform-origin` 跟随触发器 | 所有弹层一律从中心缩放展开 |
| 收起侧栏：文字 `flex: 0 0 0`，徽标 / 箭头改 `position: absolute` | 收起侧栏只写 `opacity: 0`，文字仍占位导致图标不居中 |
| `Accent` 胶囊只表等级 / 类别 | 用 `Accent` 胶囊表达状态，或与 Success 混用 |
| Toast 容器 `pointer-events: none`，卡片 `auto` | Toast 透明容器吃掉右下角点击 |
| 浮层 z-index 走 §4.14 层级表 | 随手写 `z-index: 9999` |
| 新增令牌走治理流程 | 就地硬编码颜色与尺寸 |
