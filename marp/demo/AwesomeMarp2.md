---
marp: true

math: katex
theme: am_dark
paginate: true
---

<!-- _class: cover_a -->

# Marp 介绍

**演讲人**
YYYY/MM/DD

---

<!-- _class: cols1_ol_ci fglass toc_a  -->
<!-- _footer: "" -->
<!-- _header: "CONTENTS" -->
<!-- _paginate: "" -->

## 目录

- [Marpit Markdown](#marpit-markdown)
- [Directives](#directives)
- [Image syntax](#image-syntax)
- [Fragmented list](#fragmented-list)
- [Theme CSS](#theme-css)
- [Inline SVG slide (experimental)](#inline-svg-slide-experimental)


---


## Marpit Markdown

Marpit Markdown syntax focuses on compatibility with commonly Markdown documents. It means the result of rendering keeps looking nice even if you open the Marpit Markdown in a general Markdown editor.

---

### How to write slides?

Marpit splits pages of the slide deck by horizontal ruler (e.g. `---`). It’s very simple.

```markdown
# Slide 1

foo

---

# Slide 2

bar
```

> An empty line may be required before the dash ruler by the spec of [CommonMark](https://spec.commonmark.org/0.29/#example-28). You can use the underline ruler `___`, asterisk ruler `***`, and space-included ruler `- - -` when you do not want to add empty lines.

---

### Extended features

- [Directives](https://marpit.marp.app/directives)

    Marpit Markdown has extended syntax called “**Directives**” to support writing awesome slides. It can control your slide-deck theme, page number, header, footer, style, and so on.

- [Image syntax](https://marpit.marp.app/image-syntax)

    Marpit has extended Markdown image syntax `![](image.jpg)` to be helpful creating beautiful slides.

- [Fragmented list](https://marpit.marp.app/fragmented-list)

    Since v0.9.0, Marpit will parse lists with specific markers as the **fragmented list** for appearing contents one by one.

---

## Directives

Marpit Markdown uses extended syntax called “**Directives**” to support writing awesome slides. It can control your slide-deck theme, page number, header, footer, style, and so on.

### Usage

The written directives would parse as [YAML](http://yaml.org/).

When the value includes YAML special chars, you should wrap with quotes to be recognized correctly. You may enable a loose parsing by [`looseYAML` Marpit constructor](https://marpit-api.marp.app/marpit) option if you want.

---

#### HTML comment

```markdown
<!--
theme: default
paginate: true
-->
```

> The HTML comment is also used for [presenter notes](https://marpit.marp.app/usage?id=presenter-notes). When it is parsed as a directive, it would not be collected in the `comments` result of `Marpit.render()`.

---

#### Front-matter

Marpit also supports [YAML front-matter](https://jekyllrb.com/docs/frontmatter/), that is a syntax often used for keeping metadata of Markdown. It must be the first thing of Markdown, and between the dash rulers.

```markdown
<!--
theme: default
paginate: true
-->
```

Please not confuse to the ruler for paging slides. The actual slide contents would start after the ending ruler of front-matter.

---

<!-- _class:  bq-red -->

### Type of directives

#### Global directives

Global directives are the setting value of the whole slide deck such as theme. Marpit recognizes only the last value if you wrote a same global directives many times.

> $ prefix for global directives has removed in v1.4.0. Developer may re-define dollar-prefixed [custom directives](https://marpit.marp.app/directives?id=custom-directives) as an alias to built-in directive if necessary.

---

#### Local directives

Local directives are *the setting value per slide pages*. These would apply to **defined page and following pages**.

```markdown
<!-- backgroundColor: aqua -->

This page has aqua background.

---

The second page also has same color.
```

---

<!-- _backgroundColor: aqua -->

Apply to a single page (Spot directives)

If you want to apply local directives only to the current page, you have to add the prefix `_` to the name of directives.

```markdown
<!-- _backgroundColor: aqua -->

Add underscore prefix `_` to the name of local directives.

---

The second page would not apply setting of directives.
```

---

Diagram

![h:600](https://marpit.marp.app/assets/directives.png)

---

### Global directives

| Name           | Description                                    |
| -------------- | ---------------------------------------------- |
| headingDivider | Specify heading divider option.                |
| lang           | Set the value of lang attribute for each slide |
| style          | Specify CSS for tweaking theme.                |
| theme          | Specify theme of the slide deck.               |

---

#### Theme

Choose a theme with `theme` global directive.

```markdown
<!-- theme: registered-theme-name -->
```

It recognizes the name of theme added to [`themeSet` of `Marpit` instance](https://marpit-api.marp.app/marpit#themeSet).

<br>

Tweak theme style

Normally [you may tweak theme by `<style>` element](https://marpit.marp.app/theme-css?id=tweak-style-through-markdown), but it might break a style for documentation when opening in another Markdown editor. Thus you can use `style` global directive instead of `<style>`.

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

#### Heading divider

You may instruct to divide slide pages automatically at before of headings by using `headingDivider` global directive. This feature is similar to [Pandoc](https://pandoc.org/)‘s [--slide-level option](https://pandoc.org/MANUAL.html#structuring-the-slide-show) and [Deckset 2](https://www.deckset.com/2/)‘s “Slide Dividers” option.

It have to specify heading level from 1 to 6, or array of them. This feature is enabled at headings whose the level *larger than or equal to the specified value* if in a number, and it is enabled at *only specified levels* if in array.

For example, the below two Markdowns have the same output.

---

Regular syntax

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

Heading divider

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

---

It is useful when you want to create a slide deck from a plain Markdown. Even if you opened Markdown that is using `headingDivider` in general editor, it keeps a beautiful rendering with no unsightly rulers.

> [`Marpit` constructor](https://marpit-api.marp.app/marpit) can set a default level of heading divider.

---

### Local directives

| Name               | Description                                      |
| ------------------ | ------------------------------------------------ |
| paginate           | Show page number on the slide if you set true.   |
| header             | Specify the content of slide header.             |
| footer             | Specify the content of slide footer.             |
| class              | Specify HTML class of slide’s <section> element. |
| backgroundColor    | Setting background-color style of slide.         |
| backgroundImage    | Setting background-image style of slide.         |
| backgroundPosition | Setting background-position style of slide.      |
| backgroundRepeat   | Setting background-repeat style of slide.        |
| backgroundSize     | Setting background-size style of slide.          |
| color              | Setting color style of slide.                    |

---

#### Pagination

We support pagination by the `paginate` local directive.

```markdown
<!-- paginate: true -->

You would be able to see a page number of slide in the lower right.
```

---

Configuring pagination

There are 2 things happening on each slide:
- the page number is rendered and
- the page number is being incremented.

You can control both of these with the `paginate` directive:

| paginate | Page number | Increment |
| -------- | ----------- | --------- |
| true     | Show        | Yes       |
| false    | Hide        | Yes       |
| hold     | Show        | No        |
| skip     | Hide        | No        |

---

Skip pagination on title slide

A common use case is excluding the title slide from pagination. For this you simply have to define the `paginate` directive on the second page instead of the first.

```markdown
# Title slide

This page will not have pagination by lack of the `paginate` directive.

---

<!-- paginate: true -->

Pagination will render from this slide onwards (starting at 2).
```

---

Or you can use the spot directive.

```markdown
---
paginate: true
_paginate: false # or use `_paginate: skip`
---
```

---

<!-- _paginate: skip -->

`paginate: skip` and `paginate: hold`

To both exclude a page from pagination and hide the pagination at the same time use `skip`:

```markdown
<!-- _paginate: skip -->

# Slide to exclude

This page will not update the page number and also not show the pagination
```

---

<!-- _paginate: hold -->

You can exclude a page from pagination but keep the pagination visible using `hold`:

```markdown
---
paginate: true
---

# Slide 1

[](./assets/image_01.png)

> Page 1 of 1

---

<!-- _paginate: hold -->

# Slide 2

[](./assets/image_02.png)

> Page 1 of 1
```

---

<!--
_header: 'Header content'
_footer: 'Footer content'
-->

#### Header and footer

When you have to be shown the same content across multiple slides like a title of the slide deck, you may use `header` or `footer` local directives.

```markdown
---
header: 'Header content'
footer: 'Footer content'
---

# Page 1

---

## Page 2
```

---

It will render to HTML like this:

```markdown
<section>
  <header>Header content</header>
  <h1>Page 1</h1>
  <footer>Footer content</footer>
</section>
<section>
  <header>Header content</header>
  <h2>Page 2</h2>
  <footer>Footer content</footer>
</section>
```

The content will be wrapped by a corresponding element, and insert to a right place of each slide. These could see as the part of slide contents.

If you want to place these contents to the marginal of the slide as like as PowerPoint, *you have to use supported theme*.

---

<!--
_header: '**bold** _italic_'
_footer: '![image](https://example.com/image.jpg)'
-->

Formatting

In addition, you can format the content of header/footer through markdown syntax and insert inline images.

```markdown
---
header: '**bold** _italic_'
footer: '![image](https://example.com/image.jpg)'
---

NOTE: Wrap by (double-)quotes to avoid parsed as invalid YAML.
```

> You cannot use `![bg]()` syntax in `header` and `footer` directives due to the parsing order of Markdown.

---

#### Styling slide

Class

At the some page, you might think want to change the layout, theme color, and so on. `class` local directive can change a class attribute of `<section>` element of slide page.

Let’s say you’re using a theme includes a rule like this:

```markdown
section.lead h1 {
  text-align: center;
}
```

You could use the centered leading header by setting `class` spot directive to `lead`.

```markdown
<!-- _class: lead -->

# THE LEADING HEADER
```

---

<!-- _backgroundImage: "linear-gradient(to bottom, #67b8e3, #0288d1)" -->

Backgrounds

If you want to use any color or the gradient as background, you can set style through `backgroundColor` or `backgroundImage` local directives.

```markdown
<!-- backgroundImage: "linear-gradient(to bottom, #67b8e3, #0288d1)" -->

Gradient background

---

<!--
_backgroundColor: black
_color: white
-->

Black background + White text
```

---

In addition, we have supported customize for these declarations:
- `backgroundColor`
- `backgroundImage`
- `backgroundPosition` (`center` by default)
- `backgroundRepeat` (`no-repeat` by default)
- `backgroundSize` (`cover` by default)
- `color`

> It also can use [extended image syntax](https://marpit.marp.app/image-syntax?id=slide-backgrounds) if you want to set image or color as background to single page.

---

### Advanced

#### Custom directives

Developer can extend recognizable directives. For example, [Marp Core](https://github.com/marp-team/marp-core) has extended `size` global directive to change slide size in Markdown. [Marp CLI](https://github.com/marp-team/marp-cli) will add directives for setting [meta properties of converted HTML](https://github.com/marp-team/marp-cli#metadata).

Marpit instance has [`customDirectives.global` and `customDirectives.local` object](https://marpit-api.marp.app/marpit#customDirectives) to allow adding directives as you like.

---

Custom global directive

The following example is defining dollar-prefixed alias of built-in [`theme` global directive](https://marpit.marp.app/directives?id=theme).

```markdown
marpit.customDirectives.global.$theme = (value, marpit) => {
  return { theme: value }
}
```

Please define a function to handle passed value from Markdown. The first argument is the passed value(s), and the second is the current Marpit instance. It should return an object includes pairs of key-value for passing to same kind directives.

---

Custom local directive

Custom directives also can provide a way of assigning multiple same kind directives at once. Let’s define `colorPreset` local directive for assigning preset of slide colors.

```markdown
marpit.customDirectives.local.colorPreset = (value, marpit) => {
  switch (value) {
    case 'sunset':
      return { backgroundColor: '#e62e00', color: '#fffff2' }
    case 'dark':
      return { backgroundColor: '#303033', color: '#f8f8ff' }
    default:
      // Return an empty object if not have to assign new values
      return {}
  }
}
```

---

Now you can use the defined `colorPreset` local directive with same way of built-in local directives. The underscore prefix (`_colorPreset`) for applying preset to single slide also works well.

```markdown
<!-- colorPreset: sunset -->

# Sunset color preset

---

<!-- _colorPreset: dark -->

# Dark color preset

---

# Sunset color preset
```

> The returned key-value will assign to `marpitDirectives` property in [`meta` object](https://markdown-it.github.io/markdown-it/#Token.prototype.meta) of predetermined markdown-it token(s) by the kind of directive. It would be useful for using assigned value in [markdown-it plugin](https://marpit.marp.app/usage?id=extend-marpit-by-plugins).

---

## Image syntax

Marpit has extended Markdown image syntax `![](image.jpg)` to be helpful creating beautiful slides.

| Features               | Inline image | Slide BG | Advanced BG |
| ---------------------- | ------------ | -------- | ----------- |
| Resizing by keywords   | `auto` only  | ✔        | ✔           |
| Resizing by percentage | ❌            | ✔        | ✔           |
| Resizing by length     | ✔            | ✔        | ✔           |
| Image filters          | ✔            | ❌        | ✔           |
| Multiple backgrounds   | -            | ❌        | ✔           |
| Split backgrounds      | -            | ❌        | ✔           |

<br>

Basically the extended features can turn enable by including corresponded keywords to the image’s alternative text.

---

### Resizing image

You can resize image by using `width` and `height` keyword options.

```markdown
![width:200px](image.jpg) <!-- Setting width to 200px -->
![height:30cm](image.jpg) <!-- Setting height to 300px -->
![width:200px height:30cm](image.jpg) <!-- Setting both lengths -->
```

We also support the shorthand options `w` and `h`. Normally it’s useful to use these.

```markdown
![w:32 h:32](image.jpg) <!-- Setting size to 32x32 px -->
```

Inline images only allow `auto` *keyword and the length units defined in CSS*.

> Several units related to the size of the viewport (e.g. `vw`, `vh`, `vmin`, `vmax`) cannot use to ensure immutable render result.

---

### Image filters

You can apply [CSS filters](https://developer.mozilla.org/en-US/docs/Web/CSS/filter) to image through markdown image syntax. Include `<filter-name>(:<param>(,<param>...))` to the alternate text of image.

Filters can use in the inline image and [the advanced backgrounds](https://marpit.marp.app/image-syntax?id=advanced-backgrounds).

| Markdown           | w/ arguments                                 |
| ------------------ | -------------------------------------------- |
| `![blur]()`        | `![blur:10px]()`                             |
| `![brightness]()`  | `![brightness:1.5]()`                        |
| `![contrast]()`    | `![contrast:200%]()`                         |
| `![drop-shadow]()` | `![drop-shadow:0,5px,10px,rgba(0,0,0,.4)]()` |
| `![grayscale]()`   | `![grayscale:1]()`                           |
| `![hue-rotate]()`  | `![hue-rotate:180deg]()`                     |
| `![invert]()`      | `![invert:100%]()`                           |
| `![opacity]()`     | `![opacity:.5]()`                            |
| `![saturate]()`    | `![saturate:2.0]()`                          |
| `![sepia]()`       | `![sepia:1.0]()`                             |

---

Marpit will use the default arguments shown in above when you omit arguments.

Naturally multiple filters can apply to a image.

```markdown
![brightness:.8 sepia:50%](https://example.com/image.jpg)
```

![brightness:.8 sepia:50%](https://example.com/image.jpg)

---

![bg](https://example.com/background.jpg)

### Slide backgrounds

We provide a background image syntax to specify slide’s background through Markdown. It only have to include `bg` keyword to the alternate text.

```markdown
![bg](https://example.com/background.jpg)
```

When you defined two or more background images in a slide, Marpit will show the last defined image only. If you want to show multiple images, try [the advanced backgrounds](https://marpit.marp.app/image-syntax?id=advanced-backgrounds) by enabling [inline SVG slide](https://marpit.marp.app/inline-svg).

---

![bg contain](https://example.com/background.jpg)

#### Background size

You can resize the background image by keywords. The keyword value basically follows [`background-size`](https://developer.mozilla.org/en-US/docs/Web/CSS/background-size) style.

```markdown
![bg contain](https://example.com/background.jpg)
```

| Keyword   | Description                                     | Example                    |
| --------- | ----------------------------------------------- | -------------------------- |
| `cover`   | Scale image to fill the slide. (Default)        | `![bg cover](image.jpg)`   |
| `contain` | Scale image to fit the slide.                   | `![bg contain](image.jpg)` |
| `fit`     | Alias to contain, compatible with Deckset.      | `![bg fit](image.jpg)`     |
| `auto`    | Not scale image, and use the original size.     | `![bg auto](image.jpg)`    |
| `x%`      | Specify the scaling factor by percentage value. | `![bg 150%](image.jpg)`    |

You also can continue to use [`width` (`w`) and `height` (`h`) option keywords](https://marpit.marp.app/image-syntax?id=resizing-image) to specify size by length.

---

<!-- _class:  bq-red -->

### Advanced backgrounds

> 📐 It will work only in experimental inline SVG slide.

The advanced backgrounds support [multiple backgrounds](https://marpit.marp.app/image-syntax?id=multiple-backgrounds), [split backgrounds](https://marpit.marp.app/image-syntax?id=split-backgrounds), and [image filters for background](https://marpit.marp.app/image-syntax?id=image-filters).

---

![bg](https://fakeimg.pl/800x600/0288d1/fff/?text=A)
![bg](https://fakeimg.pl/800x600/02669d/fff/?text=B)
![bg](https://fakeimg.pl/800x600/67b8e3/fff/?text=C)

#### Multiple backgrounds

```markdown
![bg](https://fakeimg.pl/800x600/0288d1/fff/?text=A)
![bg](https://fakeimg.pl/800x600/02669d/fff/?text=B)
![bg](https://fakeimg.pl/800x600/67b8e3/fff/?text=C)
```

These images will arrange in a horizontal row.

---

![bg vertical](https://fakeimg.pl/800x600/0288d1/fff/?text=A)
![bg](https://fakeimg.pl/800x600/02669d/fff/?text=B)
![bg](https://fakeimg.pl/800x600/67b8e3/fff/?text=C)

Direction keyword

You may change alignment direction from horizontal to vertical, by using `vertical` direction keyword.

```markdown
![bg vertical](https://fakeimg.pl/800x600/0288d1/fff/?text=A)
![bg](https://fakeimg.pl/800x600/02669d/fff/?text=B)
![bg](https://fakeimg.pl/800x600/67b8e3/fff/?text=C)
```

---

![bg left](https://picsum.photos/720?image=29)

#### Split backgrounds

The `left` or `right` keyword with `bg` keyword make a space for the background to the specified side. It has a half of slide size, and the space of a slide content will shrink too.

```markdown
![bg left](https://picsum.photos/720?image=29)

# Split backgrounds

The space of a slide content will shrink to the right side.
```

---

![bg right](https://picsum.photos/720?image=3)
![bg](https://picsum.photos/720?image=20)

Multiple backgrounds will work well in the specified background side.

```markdown
![bg right](https://picsum.photos/720?image=3)
![bg](https://picsum.photos/720?image=20)

# Split + Multiple BGs

The space of a slide content will shrink to the left side.
```

This feature is similar to [Deckset’s Split Slides](https://docs.decksetapp.com/English.lproj/Media/01-background-images.html#split-slides).

> Marpit uses a last defined keyword in a slide when `left` and `right` keyword is mixed in the same slide by using multiple backgrounds.

---

![bg left:33%](https://picsum.photos/720?image=27)

Split size

Marpit can specify split size for background by percentage like `left:33%`.

```markdown
![bg left:33%](https://picsum.photos/720?image=27)

# Split backgrounds with specified size
```

---

## Fragmented list

Since v0.9.0, Marpit will parse lists with specific markers as the *fragmented list* for appearing contents one by one.

### For bullet list

CommonMark allows `-`, `+`, and `*` as the character of [bullet list marker](https://spec.commonmark.org/0.29/#bullet-list-marker). Marpit would parse as fragmented list if you are using `*` as the marker.

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

### For ordered list

CommonMark’s [ordered list marker](https://spec.commonmark.org/0.29/#ordered-list-marker) must have `.` or `)` after digits. Marpit would parse as fragmented list if you are using `)` as the following character.

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

### Rendering

A structure of rendered HTML from the fragmented list is same as the regular list. It just adds `data-marpit-fragment` data attribute to list items. They would be numbered from 1 in order of recognized items.

In addition, `<section>` element of the slide that has fragmented list would be added data-marpit-fragments data attribute. It shows the number of fragmented list items of its slide.

---

The below HTML is a rendered result of [bullet list example](https://marpit.marp.app/fragmented-list?id=for-bullet-list).

```markdown
<section id="1">
  <h1>Bullet list</h1>
  <ul>
    <li>One</li>
    <li>Two</li>
    <li>Three</li>
  </ul>
</section>
<section id="2" data-marpit-fragments="3">
  <h1>Fragmented list</h1>
  <ul>
    <li data-marpit-fragment="1">One</li>
    <li data-marpit-fragment="2">Two</li>
    <li data-marpit-fragment="3">Three</li>
  </ul>
</section>
```

> Fragmented list does not change DOM structure and appearances. It relies on a behavior of the integrated app whether actually treats the rendered list as fragments.

---

## Theme CSS

### HTML structure

The basic idea of HTML structure is that `<section>` elements are corresponding to each slide pages. It is same as [reveal.js](https://github.com/hakimel/reveal.js/#markup).

```markdown
<section><h1>First page</h1></section>
<section><h1>Second page</h1></section>
```

> When conversion, Marpit would scope CSS selectors by wrapping them with the selector for [container element(s)](https://marpit.marp.app/usage?id=package-customize-container-elements) automatically. However, the theme author doesn’t have to be aware of this process.

---

### Create theme CSS

As indicated preceding, all that you have to know to create theme is just that `<section>` elements are used like a viewport for each slide pages.

```css
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

h2 {
  font-size: 50px;
}
```

We have no any extra classes or mixins, and do almost not need require to know extra rules for creating theme. This is a key factor of Marpit different from other slide framework.

---

#### `:root` pseudo-class selector

In the context of Marpit, [`:root` pseudo-class](https://developer.mozilla.org/en-US/docs/Web/CSS/:root) indicates each `<section>` elements for the slide page instead of `<html>`.

The following is similar theme definition to the example shown earlier, but it’s using `:root` selector.

```css
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

h2 {
  font-size: 1.25rem;
}
```

---

[`rem` units](https://developer.mozilla.org/en-US/docs/Web/CSS/font-size#Rems) in Marpit theme will automatically transform into the calculated relative value from the parent `<section>` element, so anyone don’t have to worry the effect from `font-size` in the root `<html>` that placed Marpit slide. Everything would work as the theme author expected.

> `:root` selector can use just like as `section` selector, but there is a difference that `:root` has higher [CSS specificity](https://developer.mozilla.org/docs/Web/CSS/Specificity) than `section`. If both selectors have mixed in a theme CSS, declarations in `:root` selector will be prefered than `section` selector.

---

<!-- _class:  bq-red -->

#### Metadata

The `@theme` **metadata is always required by Marpit**. You must define metadata through CSS comment.

```css
/* @theme name */
```

> You should use the `/*! comment */` syntax to prevent removing comments if you’re using the compressed output of [Sass](https://sass-lang.com/).

---

### Styling

#### Slide size

`width` and `height` declarations in the root `section` selector or `:root` pseudo-class selector mean a predefined slide size per theme. The specified size is not only used as the size of section element but also as the size of PDF for printing.

The default size is `1280` x `720` pixels. Try this if you want a classic 4:3 slide:

```css
/* Change to the classic 4:3 slide */
section {
  width: 960px;
  height: 720px;
}
```

> Please notice it must define **the static length in an absolute unit**. We support `cm`, `in`, `mm`, `pc`, `pt`, `px`, and `Q`.

> It is determined **one size per theme** in Marpit. The slide size cannot change through using [inline style](https://marpit.marp.app/theme-css?id=tweak-style-through-markdown), [custom class](https://marpit.marp.app/directives?id=class), and [CSS custom property](https://developer.mozilla.org/en-US/docs/Web/CSS/--*). But the width of contents may shrink if user was using [split backgrounds](https://marpit.marp.app/image-syntax?id=split-backgrounds).

---

#### Pagination

[`paginate` local directive](https://marpit.marp.app/directives?id=pagination) may control whether show the page number of slide. The theme creator can style it through `section::after` (`:root::after`) pseudo-element.

```css
/* Styling page number */
section::after {
  font-weight: bold;
  text-shadow: 1px 1px 0 #fff;
}
```

Please refer to [the default style of `section::after` in a scaffold theme](https://github.com/marp-team/marpit/blob/main/src/theme/scaffold.js) as well.

---

Customize content

Marpit has a default content: `attr(data-marpit-pagination)`, indicates the current page number. Theme CSS can add other strings and attributes to the shown page number.

```css
/* Add "Page" prefix and total page number */
section::after {
  content: 'Page ' attr(data-marpit-pagination) ' / ' attr(data-marpit-pagination-total);
}
```

`attr(data-marpit-pagination-total)` means the total page number of rendered slides. Thus, the above example would show as like as `Page 1 / 3`.

> Theme CSS must contain `attr(data-marpit-pagination)` in `content` declaration because user expects to show the page number by `paginate: true` directive. Marpit will ignore the whole of `content` declaration if the reference to that attribute is not contained.

---

#### Header and footer

`header` and `footer` element have a possible to be rendered by [`header` / `footer` local directives](https://marpit.marp.app/directives?id=header-and-footer). Marpit has no default style for these elements.

If you want to place to the marginal of slide, using `position: absolute` would be a good solution.

```css
section {
  padding: 50px;
}

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

### Customized theme

We allow creating a customized theme based on another theme.

#### `@import` rule

We support importing another theme with CSS [@import](https://developer.mozilla.org/en-US/docs/Web/CSS/@import) rule. For example, you can dye a boring monochrome theme to a brilliant orange as follows:

```css
/* @theme base */

section {
  background-color: #fff;
  color: #333;
}
```

```css
/* @theme customized */
@import 'base';

section {
  background-color: #f80;
  color: #fff;
}
```

An importing theme must add to theme set by using [`Marpit.themeSet.add(css)`](https://marpit.marp.app/usage?id=add-to-theme-set) in advance.

---

#### `@import-theme` rule

When you are using CSS preprocessors like [Sass](https://sass-lang.com/), *`@import` might resolve path in compiling* and be lost its definitions. So you can use `@import-theme` rule alternatively.

```css
$bg-color: #f80;
$text-color: #fff;

@import-theme 'base';

section {
  background: $bg-color;
  color: $text-color;
}
```

`@import` for theme and `@import-theme` can place on anywhere of the root of CSS. The imported contents is inserted to the beginning of CSS in order per rules. (`@import` is processed before `@import-theme`)

---

### Tweak style through Markdown

Sometimes you might think that want to tweak current theme instead of customizing theme fully.

Marpit gives the `<style>` HTML element written in Markdown a special treatment. The specified inline style would parse in the context of as same as a theme, and bundle to the converted CSS together with it.

```css
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

`<style>` elements would not find in rendered HTML, and would merge into emitted CSS.

[`style` global directive](https://marpit.marp.app/directives?id=tweak-theme-style) also can use as same purpose.

---

#### Scoped style

We also support the scoped inline style through `<style scoped>`. When a `style` element has the scoped attribute, its style will apply only to the current slide page only.

```css
<!-- Global style -->
<style>
h1 {
  color: red;
}
</style>

# Red text

---

<!-- Scoped style -->
<style scoped>
h1 {
  color: blue;
}
</style>

# Blue text (only in the current slide page)

---

# Red text
```

It is useful when you want to fine-tune styles per slide page.

---

<!-- _class:  bq-red -->

## Inline SVG slide (experimental)

> 📐 This feature is experimental because of a strange rendering in WebKit browsers.

When you set [`inlineSVG: true` in Marpit constructor option](https://marpit.marp.app/usage?id=triangular_ruler-inline-svg-slide), each `<section>` elements are wrapped with inline SVG.

```html
<svg data-marpit-svg viewBox="0 0 1280 960">
  <foreignObject width="1280" height="960">
    <section><h1>Page 1</h1></section>
  </foreignObject>
</svg>
<svg data-marpit-svg viewBox="0 0 1280 960">
  <foreignObject width="1280" height="960">
    <section><h1>Page 2</h1></section>
  </foreignObject>
</svg>
```

Options

`inlineSVG` constructor option also allows setting the option object. Refer to [Marpit API documentation](https://marpit-api.marp.app/marpit#~InlineSVGOptions) for details.

---

### Motivation

You may feel it a bit strange. Why we have taken this approach?

#### Pixel-perfect scaling

You may delegate a logic of pixel-perfect scaling for slide page to SVG. You have to do is only defining a size for viewing.

```css
/* Fit slide page to viewport */
svg[data-marpit-svg] {
  display: block;
  width: 100vw;
  height: 100vh;
}
```

Developer can handle the slide much easier in Marpit integrated apps.

> [@marp-team/marp-core](https://github.com/marp-team/marp-core), has extended from Marpit, has [useful auto-scaling features](https://github.com/marp-team/marp-core#auto-scaling-features) that are taken this advantage.

> WebKit cannot scale HTML elements in `<foreignObject>` ([Bug 23113](https://bugs.webkit.org/show_bug.cgi?id=23113)). You can mitigate by [polyfill](https://marpit.marp.app/inline-svg?id=polyfill).

---

#### JavaScript not required

Marpit’s scaffold style has defined `scroll-snap-align` declaration to `section` elements. They can align and fit to viewport by defining `scroll-snap-type` to the scroll container. ([CSS Scroll Snap](https://developers.google.com/web/updates/2018/07/css-scroll-snap))

Thus, a minimal web-based presentation no longer requires JavaScript. We strongly believe that keeping logic-less is important for performance and maintaining framework.

By using Marpit, [@marp-team/marp-cli](https://github.com/marp-team/marp-cli) can output HTML file for presentation that is consisted of only HTML and CSS.

```bash
npm i -g @marp-team/marp-cli
npm i @marp-team/marpit

marp --template bare --engine @marp-team/marpit marpit-deck.md
```

---

#### Isolated layer

Marpit’s [advanced backgrounds](https://marpit.marp.app/image-syntax?id=advanced-backgrounds) will work within the isolated `<foreignObject>` from the content. It means that the original Markdown DOM structure per page are keeping.

If advanced backgrounds were injected into the same layer as the Markdown content, inserted elements may break CSS selectors like [`:first-child` pseudo-class](https://developer.mozilla.org/docs/Web/CSS/:first-child) and [adjacent combinator (`+`)](https://developer.mozilla.org/docs/Web/CSS/Adjacent_sibling_combinator).

---

### Webkit polyfill

We provide a polyfill for WebKit based browsers in [@marp-team/marpit-svg-polyfill](https://github.com/marp-team/marpit-svg-polyfill).

```html
<svg data-marpit-svg viewBox="0 0 1280 960">
  <foreignObject width="1280" height="960">
    <section><h1>Page 1</h1></section>
  </foreignObject>
</svg>

<!-- Apply polyfill -->
<script src="https://cdn.jsdelivr.net/npm/@marp-team/marpit-svg-polyfill/lib/polyfill.browser.js"></script>
```

---

### `::backdrop` CSS selector

If enabled inline SVG mode, Marpit theme CSS and inline styles will redirect [::backdrop CSS selector](https://developer.mozilla.org/docs/Web/CSS/::backdrop) to the SVG container.

A following rule matches to `<svg data-marpit-svg>` element.

```css
::backdrop {
  background-color: #448;
}
```

Some of Marpit integrated apps treats the background of SVG container as like as the backdrop of slide. By setting `background` style to the SVG container, you can change the color/image of slide [letterbox](https://en.wikipedia.org/wiki/Letterboxing_(filming))/[pillarbox](https://en.wikipedia.org/wiki/Pillarbox).

---

<!-- _class:  bq-red -->

Try resizing SVG container in below:

![w:600](https://images.unsplash.com/photo-1637224671997-6dd7f74092a7?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=720&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTYzNzMzMDc0Ng&ixlib=rb-1.2.1&q=80&w=1280)

> `::backdrop` pseudo-element does not limit applicable styles. To avoid unexpected effects into slides and apps, we strongly recommend to use this selector *only for changing the backdrop color*.

---

#### Disable

If concerned conflict with styles for SVG container provided by app you are creating, you can disable `::backdrop` selector redirection separately by setting `backdropSelector` option as `false`.

```javascript
const marpit = new Marpit({
  inlineSVG: { backdropSelector: false },
})
```
