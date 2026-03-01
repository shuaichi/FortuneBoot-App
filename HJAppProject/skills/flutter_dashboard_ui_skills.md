Flutter UI/UX Design Skill - Dashboard & Data Visualization Standard
Flutter UI/UX 设计规范 - 大屏与数据可视化标准

--------------------------------------------------

1. Design Tokens（设计语言 - 大屏扩展）

- Background:
    - Dark Mode First: #0F172A (Primary dashboard background)
    - Surface: #111827 / #1F2937 (Card layers)
      大屏优先深色主题（提升对比度与沉浸感）

- Color Palette (Data Colors):
    - Primary: Blue
    - Success: Green
    - Warning: Orange
    - Danger: Red
    - Neutral: Grey

- Chart Colors (Categorical):
  Provide 6~10 distinguishable colors:
  蓝 / 绿 / 橙 / 紫 / 青 / 粉（必须可区分）

- Typography:
    - Title: 20~24 / Bold
    - Section Title: 16~18 / Medium
    - Data Number: 24~32 / Bold（核心指标）
    - Label: 12~14

- Spacing:
  8 / 12 / 16 / 24 / 32（比移动端更大间距）

--------------------------------------------------

2. Layout Pattern（布局范式）

### Grid-Based Dashboard（网格布局）

- Use 12-column grid system（12栅格）
- Card-based modular layout（卡片模块化）
- Consistent spacing between panels

### Information Hierarchy（信息优先级）

1. KPI Overview（关键指标）
2. Trend Charts（趋势）
3. Distribution（分布）
4. Detail Tables（明细）

👉 永远先展示“最重要的数据”

---

### Screen Structure（页面结构）

- Header（顶部）
    - Title + Time Range + Filters

- Body（主体）
    - KPI Row（指标卡片）
    - Charts Area（图表区）
    - Table Area（表格区）

--------------------------------------------------

3. Core Visualization Components（核心图表组件）

### 3.1 KPI Card（指标卡片）
- Large number + label
- Optional trend (↑↓)
- Highlight color for key metric

👉 用于展示：总支出 / 总收入 / 余额

---

### 3.2 Line Chart（折线图）
- Use for trends over time
- Smooth curve
- Optional area fill (low opacity)

规则：
- X轴：时间
- Y轴：数值
- 不要超过3条线

---

### 3.3 Bar Chart（柱状图）
- Use for category comparison
- Vertical or horizontal

规则：
- 分类 ≤ 10
- 排序（高→低）

---

### 3.4 Pie Chart（饼图）
- Use for simple distribution
- Max 5~6 slices

规则：
- 必须显示百分比
- 必须有图例

---

### 3.5 Rose Chart（玫瑰图）
- Use for emphasizing proportion + magnitude
- Radius represents value

👉 适合消费类别占比（增强视觉冲击）

---

### 3.6 Table（表格）
- Column alignment:
    - Text → left
    - Numbers → right

- Must support:
    - Sorting
    - Scroll

👉 用于明细数据

---

### 3.7 Filter Panel（筛选区）
- Date range selector
- Category filter
- Account filter

👉 通常在顶部或侧边

--------------------------------------------------

4. Interaction Rules（交互规则）

- Hover (Web/Desktop):
    - Tooltip for charts
    - Highlight active data point

- Tap (Mobile):
    - Drill-down (点击查看详情)

- Cross-filtering（联动）:
    - 点击图表 → 影响其他组件

👉 图表不是静态的

---

- Animation:
    - Smooth (300ms)
    - 不要炫技动画

--------------------------------------------------

5. Flutter Implementation Guidelines（实现规范）

推荐库：
- fl_chart（轻量）
- syncfusion_flutter_charts（企业级）

---

结构建议：
- DashboardPage
    - KPISection
    - ChartSection
    - TableSection

---

性能优化：
- 使用 RepaintBoundary（图表）
- 避免整页 rebuild
- 大数据表格使用分页 / 虚拟列表

--------------------------------------------------

6. Style Constraints（风格约束）

MUST:
- High contrast（高对比）
- Clear hierarchy（清晰层级）
- Consistent color mapping（颜色一致）

FORBID:
- 超过3种主色混用
- 图表过度装饰
- 信息过载

--------------------------------------------------

7. Data Rules（数据规范）

- Always show units（必须有单位）
- Use abbreviations:
    - 1,200 → 1.2K
    - 1,000,000 → 1M

- Highlight important data
  强调关键数据

--------------------------------------------------

8. Consistency with Mobile Skill（与移动端统一）

- Same color semantics（颜色语义一致）
- Same spacing logic（间距体系一致）
- Same component philosophy（卡片化）

👉 大屏 ≠ 另一套系统，而是扩展