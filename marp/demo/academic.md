---
marp: true

math: katex
paginate: true
theme: academic
---

<!--
_class: lead
_paginate: false
-->

# Marp 介绍

**演讲人**
YYYY/MM/DD

---

<!-- _header: 目录 -->

- [Marp 介绍](#marp-介绍)
- [Directives](#directives)
                - [Global directives](#global-directives)
                    - [class](#class)
- [Image syntax](#image-syntax)
                    - [Multiple backgrounds](#multiple-backgrounds)
                    - [Split size](#split-size)
- [Fragmented list](#fragmented-list)
- [Theme CSS](#theme-css)
                    - [Slide size](#slide-size)
                    - [`@import` 规则](#import-规则)

---

<!-- _header: 简介 -->

Marp 是用于从 Markdown 创建幻灯片的框架。

它可以将 Markdown 和 CSS 主题转换为由静态 HTML 和 CSS 组成的幻灯片，并通过打印创建可转换为幻灯片 PDF 的网页。

特征：
- Marpit Markdown
- Theme CSS by clean markup
- Inline SVG slide (Experimental)

Marpit Markdown 语法侧重于与常见的 Markdown 文档的兼容性。

这意味着即使在一个常规的 Markdown 编辑器中打开 Marpit Markdown，渲染的结果仍然看起来很好。

---

<!-- _header: 如何编写幻灯片？ -->

Marpit 通过水平标尺（例如 `---`）拆分幻灯片页面，非常简单。

```markdown
# Slide 1

foo

---

# Slide 2

bar
```

根据 [CommonMark]([https:/](https:/spec.commonmark.org/0.29#example-28)) 规范，`---` 前可能需要空行。如果不想添加空行，可以使用:
- 下划线标尺 `___`
- 星号标尺 `***`
- 包含空格的标尺 `- - -`

---

<!--
_class: lead
_paginate: false
-->

# Directives

---

<!-- _header: Directives 用法 -->

Directives 将解析为 YAML。

当值包含 YAML 特殊字符时，您应该用引号引起来才能被正确识别。
如果需要，您可以通过 looseYAML Marpit 构造函数选项启用松散解析。

---

<!-- _header: HTML 注释 -->

```HTML
<!-- theme: default paginate: true -->
```

HTML 注释也用于 [presenter notes](<[https:/](https:/marpit.marp.app/usage>)。
当它被解析为一个指令时，它不会被收集到 `Marpit.render()` 的注释结果中。

---

<!-- _header: Front-matter -->

Marpit 还支持 YAML front-matter，这是一种常用于保存 Markdown 元数据的语法。
它必须是 Markdown 的第一件事，并且位于破折号标尺之间。

```markdown
---
theme: default
paginate: true
---
```

请不要和分页幻灯片的水平分割线混淆。
实际的幻灯片内容将在 YAML Front-matter 的—之后开始。

---

<!-- _header: Directives 类型 -->

##### Global directives

Global directives 是整个幻灯片的设置值，比如 theme。
如果多次编写相同的全局指令，Marpit只识别最后一次设置的值。

| 名称             | 描述                 |
| ---------------- | -------------------- |
| `theme`          | 指定幻灯片的主题。   |
| `style`          | 为调整主题指定CSS。  |
| `headingDivider` | 指定标题分隔符选项。 |

---

<!-- _header: Theme -->

用 `theme` Global directives 选择一个 MarPitInstance 的 ThemeSet 中的主题。

```markdown
<!-- theme: registered-theme-name -->
```

通常可以通过 `<style>` 元素调整主题，但在另一个 Markdown 编辑器中打开时，它可能会破坏文档样式。
因此，您可以使用 `style` Global directives，而不是 `<style>`。

```markdown
---
theme: base-theme
style: |
    section {
        background-color: #ccc;
    }
---
```

---

<!-- _header: Heading divider -->

可以使用 `headingDivider` Global directives 指示在标题前自动划分幻灯片页面。
它必须指定标题级别从 1 到 6 ，或它们的数组。如果在数字中，则在级别大于或等于指定值的标题上启用此功能，如果在数组中，则仅在指定的级别上启用此功能。

例如，以下两个 Markdown 具有相同的输出。

---

<!-- _header: 常规语法 -->

```markdown
# 1st page

The content of 1st page

---

## 2nd page

### The content of 2nd page

Hello, world!

---

# 3rd page

😃
```

---

<!-- _header: Heading divider -->

```markdown
<!-- headingDivider: 2 -->

# 1st page

The content of 1st page

## 2nd page

### The content of 2nd page

Hello, world!

# 3rd page

😃
```

当您要从普通的 Markdown 创建幻灯片时，它非常有用。
即使你在普通的编辑器中打开了使用headingDivider的Markdown，它也会保持一个漂亮的渲染效果，没有难看的水平分割线。

---

<!-- _header: Local directives -->

Local directives 是每个幻灯片页面的设置值。

以下设置将适用于 **定义了指令的页面和后续页面**。

```markdown
<!-- backgroundColor: aqua -->

这个页面有水绿色的背景。

---

第二页也是同样的颜色。
```

---

<!-- _header: Local directives -->

如果只想将 Local directives 应用于当前页面，则必须给指令名称添加前缀 `_`。

```markdown
<!-- _backgroundColor: aqua -->

向 Local directives 的名称中添加下划线前缀 `_`。

---

第二页将不应用指令的设置。
```

---

<!-- _header: Local directives -->

示例：

![height:540px center](https://marpit.marp.app/assets/directives.png)

---

<!-- _header: Local directives -->

| 名称                 | 描述                                      |
| -------------------- | ----------------------------------------- |
| `paginate`           | 如果设置为 `True`，则在幻灯片上显示页码。 |
| `header`             | 指定幻灯片标题的内容。                    |
| `footer`             | 指定幻灯片页脚的内容。                    |
| `class`              | 指定幻灯片的 `<section>` 元素的HTML类。   |
| `backgroundColor`    | 设置幻灯片的 `background-color` 样式。    |
| `backgroundImage`    | 设置幻灯片的 `background-image` 样式。    |
| `backgroundPosition` | 设置幻灯片的 `background-position` 样式。 |
| `backgroundRepeat`   | 设置幻灯片的 `background-repeat` 样式。   |
| `backgroundSize`     | 设置幻灯片的 `background-size` 样式。     |
| `color`              | 设置幻灯片的 `color` 样式。               |

---

<!-- _header: Pagination -->

支持通过 `paginate` 局部指令显示或隐藏页码。

```markdown
<!-- paginate: true -->

此时你可以在右下角看到幻灯片的页码。
```

---

<!-- _header: Pagination -->

若要跳过某个幻灯片的页码，只需将 `paginate` 指令的定义移到第二个页面。

```markdown
# Title slide

此页面将由于缺乏 `paginate` Local directives 而不显示页码。

---

<!-- paginate: true -->

将从该页面作为幻灯片页码的起始。
```

或者也可以使用 `_` 前缀的指令。

```markdown
---
paginate: true
_paginate: false
---
```

---

<!-- _header: Header and footer -->

当您必须在多个幻灯片上显示相同的内容（如幻灯片的标题）时，您可以使用 `header` 或 `footer` 指令。

```markdown
---
header: 'Header content'
footer: 'Footer content'
---

# Page 1

---

## Page 2
```

内容将被一个相应的元素包裹起来，并插入到每个幻灯片的正确位置。
这些可以看作是幻灯片内容的一部分。

若希望将这些内容像 PowerPoint 一样在幻灯片边缘，则必须使用受支持的主题。

---

<!-- _header: Header and footer -->

此外，还可以通过 Markdown 语法格式化页眉/页脚的内容，并插入行内图像。

```markdown
---
header: '**bold** _italic_'
footer: '![image](https://example.com/image.jpg)'
---

注意：用单/双引号包裹起来，以避免被解析为无效的YAML。
```

由于Markdown的解析顺序，您不能在页眉和页脚指令中使用 `![bg]()` 语法。

---

<!-- _header: Styling slide -->

###### class

在某些页面上，您可能认为需要更改布局、主题颜色等等。
Class指令可以更改幻灯片页面的 `<section>` 元素的class属性。

假设您使用的主题包含如下规则：

```CSS
section.lead h1 {
    text-align: center;
}
```

您可以通过设带 `_` 前缀的 `class` 指令来使用居中的 lead 标题。

```markdown
<!-- _class: lead -->

# THE LEADING HEADER
```

---

<!-- _header: Backgrounds -->

如果要使用任何颜色或渐变作为背景，可以通过 `backoundColor` 或 `backoundImage` Local directives 设置样式。

```markdown
<!-- backgroundImage: "linear-gradient(to bottom, #67b8e3, #0288d1)" -->

渐变背景

---

<!--
_backgroundColor: black
_color: white
-->

黑色背景 + 白色文字
```

---

<!-- _header: Backgrounds -->

此外，我们还支持对以下声明进行自定义：
- `backgroundColor`
- `backgroundImage`
- `backgroundPosition`（默认为 `center`）
- `backgroundRepeat`（默认为 `no-repeat`）
- `backgroundSize`（默认为 `cover`）
- `color`

如果您想将图像或颜色作为背景设置为单页，它还可以使用扩展的图像语法。

---

<!--
_class: lead
_paginate: false
-->

# Image syntax

---

<!-- _header: Image syntax -->

Marpit 扩展了 Markdown 图像语法 `![](image.jpg)`，以帮助创建精美的幻灯片。

| 功能             |  内联图像   | 幻灯片BG | 高级BG |
| ---------------- | :---------: | :------: | :----: |
| 按关键字调整大小 | 仅支持 auto |    √     |   √    |
| 按百分比调整大小 |      √      |    √     |   √    |
| 按长度调整大小   |      √      |    √     |   √    |
| 图像滤镜         |      √      |    x     |   √    |
| 多个背景         |      -      |    x     |   √    |
| 分割背景         |      -      |    x     |   √    |

基本上，可以通过将对应的关键字包括到图像的替代文本来启用扩展功能。

---

<!-- _header: Resizing image -->

可以通过使用 `width` 和 `height` 关键字参数来调整图像的大小。

```markdown
![width:200px](image.jpg) <!-- 设置宽度为200px -->
![height:30cm](image.jpg) <!-- 设置高度为300px -->
![width:200px height:30cm](image.jpg) <!-- 同时设置宽度和高度 -->
```

我们还支持简单的 `w` 和 `h` 参数。通常情况下，使用这些参数很有用。

```markdown
![w:32 h:32](image.jpg) <!--设置尺寸为32x32px -->
```

内联图像只允许 `auto` 关键字和 CSS 中定义的长度单位。

与视口大小相关的几个单位（例如 `vw`、`vh`、`vmin`、`vmax`）不能用于确保不变的渲染结果。

---

<!-- _header: Image filters -->

您可以通过 MarkDown 图像语法将 CSS 滤镜应用于图像。
包括 `<filter-name>(:<param>(,<param>...))` 到图像的替代文本。

滤镜可以在内联图像和高级背景中使用。

当您省略参数时，Marpit 将使用下页显示的默认参数。

当然，多个滤镜可以应用于一个图像。

```markdown
![brightness:.8 sepia:50%](https://example.com/image.jpg)
```

---

<!-- _header: Image filters -->

| 滤镜     | 不带参数写法       | 带参数写法                                   |
| -------- | ------------------ | -------------------------------------------- |
| 高斯模糊 | `![blur]()`        | `![blur:10px]()`                             |
| 亮度     | `![brightness]()`  | `![brightness:1.5]()`                        |
| 对比度   | `![contrast]()`    | `![contrast:200%]()`                         |
| 阴影     | `![drop-shadow]()` | `![drop-shadow:0,5px,10px,rgba(0,0,0,.4)]()` |
| 灰度     | `![grayscale]()`   | `![grayscale:1]()`                           |
| 色相旋转 | `![hue-rotate]()`  | `![hue-rotate:180deg]()`                     |
| 反相     | `![invert]()`      | `![invert:100%]()`                           |
| 透明度   | `![opacity]()`     | `![opacity:.5]()`                            |
| 饱和度   | `![saturate]()`    | `![saturate:2.0]()`                          |
| 褐色化   | `![sepia]()`       | `![sepia:1.0]()`                             |

---

<!-- _header: Slide backgrounds -->

我们提供了一种背景图像语法来通过 Markdown 指定幻灯片的背景。
它只需在替换文本中包含 `bg` 关键字。

```markdown
![bg](https://example.com/background.jpg)
```

当您在幻灯片中定义了两个或更多的背景图像时，Marpit 将只显示最后定义的图像。
如果要显示多个图像，可以通过启用 [inline SVG slide](https://marpit.marp.app/inline-svg) 幻灯片来尝试 [高级背景](https://marpit.marp.app/image-syntax?id=advanced-backgrounds)。

---

<!-- _header: Background size -->

您可以根据关键字调整背景图像的大小。关键字值基本上遵循 `background-size` 样式。

```markdown
![bg contain](https://example.com/background.jpg)
```

| 关键字    | 描述                              | 示例                       |
| --------- | --------------------------------- | -------------------------- |
| `cover`   | 缩放图像以填充幻灯片（默认）      | `![bg cover](image.jpg)`   |
| `contain` | 缩放图像以适合幻灯片              | `![bg contain](image.jpg)` |
| `fit`     | `contain` 的别名，与 Deckset 兼容 | `![bg fit](image.jpg)`     |
| `auto`    | 不缩放图像，而使用原始尺寸        | `![bg auto](image.jpg)`    |
| `x%`      | 按百分比值指定缩放因子            | `![bg 150%](image.jpg)`    |

您还可以继续使用 `width` (`w`)和 `height` (`h`) 选项关键字来按长度指定大小。

---

<!-- _header: Advanced backgrounds -->

注意：它将只在实验性的 [inline SVG slide](https://marpit.marp.app/inline-svg) 幻灯片中工作。

###### Multiple backgrounds

```markdown
![bg](https://fakeimg.pl/800x600/0288d1/fff/?text=A)
![bg](https://fakeimg.pl/800x600/02669d/fff/?text=B)
![bg](https://fakeimg.pl/800x600/67b8e3/fff/?text=C)
```

这些图像将排列成水平行。

![bg](https://fakeimg.pl/800x600/0288d1/fff/?text=A)
![bg](https://fakeimg.pl/800x600/02669d/fff/?text=B)
![bg](https://fakeimg.pl/800x600/67b8e3/fff/?text=C)

---

<!-- _header: Multiple backgrounds -->

您可以通过使用 `vertical` 方向关键字将对齐方向从水平更改为垂直。

```markdown
![bg vertical](https://fakeimg.pl/800x600/0288d1/fff/?text=A)
![bg](https://fakeimg.pl/800x600/02669d/fff/?text=B)
![bg](https://fakeimg.pl/800x600/67b8e3/fff/?text=C)
```

![bg vertical](https://fakeimg.pl/800x600/0288d1/fff/?text=A)
![bg](https://fakeimg.pl/800x600/02669d/fff/?text=B)
![bg](https://fakeimg.pl/800x600/67b8e3/fff/?text=C)

---

<!-- _header: Split backgrounds -->

`left` 或 `right` 关键字与 `bg` 关键字一起为指定侧的背景留出空间。
它有一半的幻灯片大小，幻灯片内容的空间也会缩小。

```markdown
![bg left](https://picsum.photos/720?image=29)

# 左右切分布局

幻灯片内容的空间将缩小到右侧。
```

![bg left](https://picsum.photos/720?image=29)

---

<!-- _header: Split backgrounds -->

多个背景将在指定的背景端很好地工作。

```markdown
![bg right](https://picsum.photos/720?image=3)
![bg](https://picsum.photos/720?image=20)

# 左右切分布局 + 多个背景

幻灯片内容的空间将缩小到左侧。
```

这一功能类似于 Deckset 的拆分幻灯片。

当 `left` 关键字和 `right` 关键字通过使用多个背景混合在同一张幻灯片中时，Marp 将在幻灯片中使用最后定义的关键字。

![bg right](https://picsum.photos/720?image=3)
![bg](https://picsum.photos/720?image=20)

---

<!-- _header: Split backgrounds -->

###### Split size

Marpit可以按百分比指定背景的左右分割布局的尺寸，如 `left:33%`。

```markdown
![bg left:33%](https://picsum.photos/720?image=27)

# 按指定的百分比分割背景
```

![bg left:33%](https://picsum.photos/720?image=27)

---

<!--
_class: lead
_paginate: false
-->

# Fragmented list

---

<!-- _header: For bullet list -->

CommonMark 允许 `-`、`+` 和 `*` 作为项目符号标记的字符。
如果您使用 `*` 作为标记，Marp 将解析为 Fragmented list。

```markdown
# Bullet list

- One
- Two
- Three

---

# Fragmented list

* One
* Two
* Three
```

---

<!-- _header: For ordered list -->

CommonMark 的有序列表标记在数字之后必须具有 `.` 或 `)`。
如果您使用 `)` 作为跟随字符，Marp 将解析为 Fragmented list。

```markdown
# Ordered list

1. One
2. Two
3. Three

---

# Fragmented list

1) One
2) Two
3) Three
```

---

<!-- _header: Rendering -->

从 Fragmented list 中呈现的 HTML 结构与常规列表相同。
它只是将数据属性添加到列表项中并按识别项目的顺序从 1 开始编号。

此外，有碎片列表的幻灯片的 `<section>` 元素将添加data-marpit-fragments数据属性。它显示了其幻灯片中的片段化列表项的数量。

片段化的列表不会更改DOM结构和外观。
它取决于集成的应用程序的行为是否真的将呈现的列表视为片段。

---

<!--
_class: lead
_paginate: false
-->

# Theme CSS

---

<!-- _header: HTML structure -->

marp 的 HTML 结构的基本思路是 `<section>` 元素对应于每个幻灯片页面，这和 `reveal.js` 是一样。

```HTML
<section><h1>First page</h1></section>
<section><h1>Second page</h1></section>
```

在转换时，Marp 会将通过使用容器元素的选择器自动包装它们来确定 CSS 选择器的范围。
然而，主题作者不必知道这个过程。

---

<!-- _header: Create theme CSS -->

如前所述，要创建主题，您只需知道 `<section>` 元素就像每个幻灯片页面的视口一样使用。

```CSS
/* @theme marpit-theme */

section {
  width: 1280px;
  height: 960px;
  font-size: 40px;
  padding: 40px;
}

h1 {
  font-size: 60px;
  color: #09c;
}
```

我们没有任何额外的类或混合语句，并且几乎不需要知道创建主题的额外规则。
这是 Marp 不同于其他幻灯片框架的一个关键因素。

---

<!-- _header: '`:root` pseudo-class selector' -->

在 Marp 的上下文中，`:root` pseudo-class 表示幻灯片页面的每个 `<section>` 元素，而不是 `<html>` 。

下面的主题定义与前面的示例类似，但它使用的是 `:root` 选择器。

```CSS
/* @theme marpit-theme */

:root {
  width: 1280px;
  height: 960px;
  font-size: 40px;
  padding: 1rem;
}

h1 {
  font-size: 1.5rem;
  color: #09c;
}
```

---

<!-- _header: '`:root` pseudo-class selector' -->

Marp 主题中的rem单位会自动转换为来自父 `<section>` 元素的计算相对值，所以任何人都不必担心放置 Marp 幻灯片的根 `<html>` 中的字体大小的影响。

`:root` 选择器可以像 section 选择器一样使用，但是有一个区别:root比 section 具有更高的 CSS 专用性。
如果两个选择器在一个 CSS 主题中混合使用，则 `:root` 选择器中的声明将优先于 `selection` 选择器。

---

<!-- _header: Metadata -->

**`@Theme` 元数据始终是 Marp 所必需的**。
您必须通过CSS注释定义元数据。

```CSS
/* @theme name */
```

如果您使用的是 Sass 的压缩输出，那么应该使用 `/* ! comments */` 语法来防止删除注释。

---

<!-- _header: Styling -->

###### Slide size

根部分选择器中的 `width` 和 `height` 声明，或者 `:root` pseudo-class 选择器表示每个主题预定义的幻灯片大小。
指定的大小不仅用作区段元素的大小，而且用作打印PDF的大小。

默认大小为 `1280` x `720` 像素
而如果你想要一张经典的 4：3 的幻灯片，可以试试这样：

```CSS
/* Change to the classic 4:3 slide */
section {
  width: 960px;
  height: 720px;
}
```

请注意，它必须以绝对单位定义静态长度。
我们支持`cm`，`in`，`mm`，`pc`，`pt` 和 `px` 作为单位。

---

<!-- _header: Pagination -->

`paginate` 指令可以控制是否显示幻灯片的页码。
主题创建者可以通过 `section::after(:root::after)` 伪元素对其进行样式化。

```CSS
/* Styling page number */
section::after {
  font-weight: bold;
  text-shadow: 1px 1px 0 #fff;
}
```

也请参考 [scaffold](https://github.com/marp-team/marpit/blob/main/src/theme/scaffold.js) 主题中的 `section::after` 的默认样式。

---

<!-- _header: Pagination -->

Marp 有一个默认内容 `:attr(data-marpit-pagination)`，表示当前页码。
主题 CSS 可以向显示的页码添加其他字符串和属性。

```CSS
/* Add "Page" prefix and total page number */
section::after {
  content: 'Page' attr(data-marpit-pagination) '/' attr(data-marpit-pagination-total);
}
```

`attr(data-marpot-pagination-total)` 指的是所渲染的幻灯片的总页数。
因此，上面的示例会显示为 `Page 1 / 3`。

主题 CSS 必须在内容声明中包含 `attr(data-marpit-pagination)`，因为用户希望通过 `paginate: true` 指令显示页码。
如果不包含对该属性的引用，则 Marp 将忽略整个内容声明。

---

<!-- _header: Header and footer -->

`Header` 和 `footer` 元素可以通过 `header` 或 `footer` 指令呈现。
Marp 没有这些元素的默认样式。

若你想放置到幻灯片的边缘，使用 `position: absolute` 将是一个很好的解决方案。

```CSS
header,
footer {
  position: absolute;
  left: 50px;
  right: 50px;
  height: 20px;
}
header {
  top: 30px;
}
footer {
  bottom: 30px;
}
```

---

<!-- _header: Customized theme -->

我们允许基于另一个主题创建自定义主题。

###### `@import` 规则

我们支持使用 CSS `@import` 规则导入另一个主题。
例如，你可以把一个无聊的单色主题染成一个明亮的橙色，如下页所示：

---

<!-- _header: '`@import` 规则' -->

```CSS
/* @theme base */

section {
    background-color: #fff;
    color: #333;
}
```

```CSS
/* @theme customized */

@import 'base';

section {
    background-color: #f80;
    color: #fff;
}
```

导入主题必须提前使用 `Marpit.themeSet.add(css)` 添加到主题集中。

---

<!-- _header: '`@import-theme` 规则' -->

当您使用像 Sass 这样的 CSS 预处理器时，`@import` 可能会解析编译中的路径并丢失其定义。
因此，您也可以交替地使用 `@import-theme` 规则。

```CSS
$bg-color: #f80;
$text-color: #fff;

@import-theme 'base';

section {
  background: $bg-color;
  color: $text-color;
}
```

`@import` 和 `@import-theme` 对于主题可以放置在 CSS 的根目录上的任何地方。
导入的内容将按照规则的顺序插入到 CSS 的开头。(`@import` 在 `@import-theme` 之前处理）

---

<!-- _header: Tweak style through Markdown -->

Marpit对写在Markdown中的 `<style>` HTML 元素给予了特殊处理。
内联样式将在与主题相同的上下文中进行解析，并与其一起绑定到转换后的 CSS。

```CSS
---
theme: base
---

<style>
section {
  background: yellow;
}
</style>

# Tweak style through Markdown

You would see a yellow slide.
```

`<style>` 元素将不会在渲染后的 HTML 中，并将合并到发出的 CSS 中。
`style` Global directives 也可以用作相同的目的。

---

<!-- _header: Scoped style -->

我们还通过 `<style scoped>` 支持作用域内联样式。
当 `style` 元素具有 `scoped` 属性时，其样式将仅适用于当前幻灯片页。

```CSS
<!-- Scoped style -->
<style scoped>
h1 {
  color: blue;
}
</style>

# Blue text (only in the current slide page)
```

当您想调整每个幻灯片页面的样式时，它很有用。
