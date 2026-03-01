# Flutter UI/UX Design Skill - Accounting Page Standard (Enhanced Version)
# Flutter UI/UX 设计规范 - 记账页面标准（增强版）

--------------------------------------------------

## 1. Design Tokens（设计语言）

- **Background**: `#FAFAFA` (Grey 50)
  - 背景色：浅灰

- **Surface**: `#FFFFFF`
  - 卡片背景：白色

- **Semantic Colors**:
  - **Expense**: Green (支出)
  - **Income**: Red (收入)
  - **Transfer**: Blue (转账)
  - 语义颜色：用于强调当前单据类型

- **Typography**:
  - **Primary**: 16 / Bold / Black87
  - **Secondary**: 14 / Grey600
  - **Hint**: 13 / Grey400

- **Radius**:
  - **Card**: 16 (统一卡片圆角)
  - **Pill**: 18 (胶囊按钮圆角)

- **Spacing Scale**:
  - `4 / 8 / 12 / 16 / 24`（统一间距体系）

--------------------------------------------------

## 2. Layout Pattern（布局范式）

- **Split Layout**:
  - Scroll Area (Content)
  - Fixed Bottom (Keyboard / CTA)

- **Visual Priority**:
  1. Amount (Primary focus, center or top)
  2. Category (Second)
  3. Meta info (Date, Account)
  4. Optional (Remark, Tags)

👉 **金额必须是视觉中心**

--------------------------------------------------

## 3. Core Components（核心组件）

### 3.1 Amount Input（金额输入）
- Large font (≥28)
- **No system keyboard** (禁止唤起系统键盘)
- Cursor via state, not `TextField` (光标由状态控制)

---

### 3.2 Category Grid（分类网格）
- Grid layout (4~5 columns)
- Icon + Label
- Selected state:
  - Background highlight OR border + theme color
- Must support quick tap

👉 **禁止使用长列表（影响效率）**

---

### 3.3 Tag Selector（标签选择）
- Multi-select chips
- Selected:
  - Filled background + primary color
- Unselected:
  - Outline or light grey

👉 **必须即时反馈（不能点击无反应）**

---

### 3.4 Date Picker（时间选择）
- Default: **Today**
- Interaction:
  - Bottom Sheet OR inline selector
- Display:
  - Human readable (e.g. "Today", "Yesterday")

---

### 3.5 Account Selector（账户选择）
- Card row with icon + name
- Tap → Bottom Sheet list
- Selected state visible in main page

---

### 3.6 Primary Button（主按钮）
- Full width or keyboard integrated
- Strong color (semantic color)
- Height ≥ 48

---

### 3.7 Secondary Info Card（次级信息）
- Collapsible OR lower priority
- Contains:
  - Remark
  - Tags
  - Attachments

---

### 3.8 Empty & Loading States（状态组件）
- Empty:
  - Icon + hint text
- Loading:
  - Skeleton OR spinner

👉 **禁止空白页面**

--------------------------------------------------

## 4. Interaction Rules（交互规则）

- **One-hand first**
  - 优先单手操作设计

- **Fast path**:
  - Type → Amount → Category → Done (最短路径)

- **Default everything**:
  - Today (默认今天)
  - Default account (默认账户)
  - Last category (optional) (可选：记忆上次分类)

- **Immediate feedback**:
  - Tap must show state change instantly (点击必须立即响应)

- **Keyboard strategy**:
  - **NEVER** mix system + custom keyboard (绝不混合使用系统键盘和自定义键盘)

--------------------------------------------------

## 5. Flutter Implementation Guidelines（实现规范）

- **Structure**:
  ```dart
  Scaffold
    Column
      Expanded(SingleChildScrollView)
      Keyboard / CTA Area
  ```

- **Avoid**:
  - Deep nesting (>4 levels)
  - Rebuilding entire page (setState on root)

- **Use**:
  - `const` widgets wherever possible
  - `ValueNotifier` for local UI state (keyboard visibility, focus)
  - `Bloc` for business logic

- **Componentization**:
  - Each logical section = Independent Widget

--------------------------------------------------

## 6. Style Constraints（风格约束）

- **MUST**:
  - Card-based layout (卡片式布局)
  - Strong whitespace (充足留白)
  - Clear hierarchy (清晰层级)

- **FORBID**:
  - Gradients (复杂渐变)
  - Heavy shadows (深重阴影)
  - Visual clutter (视觉杂乱)
  - Overuse of borders (过度使用边框)

--------------------------------------------------

## 7. Consistency Rules（一致性规则）

- **All pages must share**:
  - Same spacing scale
  - Same radius
  - Same color logic

- **Interaction must be predictable**:
  - 类似操作必须拥有一致的反馈和行为