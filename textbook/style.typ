// 控制理论教材 —— 共享样式库
// 配色与实验台/原讲义一致:#0f6cbd 主题蓝
#let accent = rgb("#0f6cbd")
#let warn = rgb("#b45309")
#let okc = rgb("#1a7f37")
#let gray = rgb("#5a6b7a")

// 例题计数器(章.序;章首由 show-rules 重置)
#let ex-counter = counter("example")

// 页面与正文(模板函数:必须 #show: setup 应用到全文,裸调用不生效!)
#let setup(body) = {
  set page(paper: "a4", margin: (x: 2.2cm, y: 2.4cm), numbering: "1 / 1", footer: context align(center)[#text(size: 0.8em, fill: gray)[控制理论教材　·　第 #counter(page).display() 页]])
  set text(font: ("Libertinus Serif", "Microsoft YaHei"), size: 10.5pt, lang: "zh")
  set heading(numbering: (..nums) => {
    let ns = nums.pos()
    if ns.len() == 1 { numbering("1", ..ns) }
    else if ns.len() == 2 { numbering("1.1", ..ns) }
    else { numbering("1.1.1", ..ns) }
  })
  set par(justify: true, leading: 0.72em)
  set list(indent: 0.8em)
  set enum(indent: 0.8em)
  // 公式按章编号 (章.序)
  set math.equation(numbering: n => numbering("(1.1)", counter(heading).get().first(), n))
  // 插图按章编号:Typst 会自动加 supplement"图",numbering 只给 章序.序
  set figure(numbering: n => numbering("1.1", counter(heading).get().first(), n), gap: 0.9em)
  show figure.caption: set text(size: 0.85em)
  show figure.where(kind: table): set figure.caption(position: top)
  show raw.where(block: true): block.with(fill: rgb("#f6f8fa"), inset: 10pt, radius: 4pt, width: 100%)
  body
}

// 章与节的外观;章首分页并重置公式/图表计数(模板函数:#show: show-rules)
#let show-rules(body) = {
  show heading.where(level: 1): it => {
    // 注意:figure 元素实际步进的是按 kind 过滤的计数器,裸 counter(figure) 是另一个,两个都要重置
    if it.numbering != none {
      counter(math.equation).update(0)
      counter(figure).update(0)
      counter(figure.where(kind: image)).update(0)
      ex-counter.update(0)
    }
    set text(fill: accent)
    pagebreak(weak: true)
    v(0.8em)
    if it.numbering != none {
      block(text(size: 11pt, fill: gray)[第 #context counter(heading).display("一") 章])
      v(-0.6em)
    }
    it
    v(0.6em)
  }
  show heading.where(level: 2): it => {
    set text(fill: accent.darken(10%), size: 13pt)
    v(0.5em); it; v(0.3em)
  }
  show heading.where(level: 3): it => {
    set text(size: 11pt)
    v(0.4em); it; v(0.2em)
  }
  body
}

// ---------- 信息框 ----------
// 实验台操作框(蓝)
#let labbox(body) = block(
  fill: rgb("#eef4fb"), stroke: (left: 3pt + accent),
  inset: (x: 12pt, y: 10pt), radius: (right: 4pt), width: 100%, body,
)
// 思考题框(橙)
#let thinkbox(body) = block(
  fill: rgb("#fdf6ec"), stroke: (left: 3pt + warn),
  inset: (x: 12pt, y: 10pt), radius: (right: 4pt), width: 100%, body,
)
// 结论要点(绿)
#let keybox(body) = block(
  fill: rgb("#eef7f0"), stroke: (left: 3pt + okc),
  inset: (x: 12pt, y: 10pt), radius: (right: 4pt), width: 100%, body,
)
// 定义(灰蓝)
#let defbox(body) = block(
  fill: rgb("#f3f6fa"), stroke: (left: 3pt + gray),
  inset: (x: 12pt, y: 10pt), radius: (right: 4pt), width: 100%, body,
)
// 定理/判据(紫)
#let thmbox(body) = block(
  fill: rgb("#f5f1fa"), stroke: (left: 3pt + rgb("#6f42c1")),
  inset: (x: 12pt, y: 10pt), radius: (right: 4pt), width: 100%, body,
)
// 例题外壳
#let exbox(body) = block(
  fill: rgb("#fafafa"), stroke: 0.5pt + rgb("#d0d7de"),
  inset: (x: 12pt, y: 10pt), radius: 4pt, width: 100%, body,
)

// 无编号公式块:块内显示公式一律不编号(多步推导链用,免得每行一个号)
#let deriv(body) = block(width: 100%)[#set math.equation(numbering: none); #body]

// 例题自动编号:章.序
#let example(name, body) = {
  ex-counter.step()
  exbox[
    #context {
      let n = numbering("1.1", counter(heading).get().first(), ex-counter.get().first())
      text(fill: accent, weight: "bold")[例 #n　#name]
    }
    #h(0.5em)
    #body
  ]
  v(0.4em)
}

// 实验台链接条:url 传内容块,如 #labref[实验名][leslieryin.github.io/xxx]
#let labref(name, url) = labbox[
  #text(fill: accent, weight: "bold")[配套实验]　#name　——　#text(font: "Consolas", size: 0.85em, fill: gray)[#url]
]

// 部标题(独页大字,不进章计数)
#let part(title) = {
  pagebreak(weak: true)
  v(3.5cm)
  align(center, block[
    #text(size: 22pt, weight: "bold", fill: accent)[#title]
    #v(0.4em)
    #line(length: 30%, stroke: 1pt + accent.lighten(40%))
  ])
  v(1.5cm)
}
