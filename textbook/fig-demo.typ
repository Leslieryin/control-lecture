// 绘图库使用示例(也是 figlib 的活文档,子代理写图前先读这个)
#import "style.typ": setup, show-rules, accent, gray
#import "figlib.typ": *

#set page(paper: "a4", margin: (x: 2.2cm, y: 2.4cm))
#setup
#show-rules

== 阶跃响应族

#let step2(z, wn) = {
  let wd = wn * calc.sqrt(1 - z * z)
  let phi = calc.acos(z) / 1rad // acos 返回角度,统一转成弧度浮点
  t => 1 - calc.exp(-z * wn * t) / calc.sqrt(1 - z * z) * calc.sin(wd * t + phi)
}

#plot(
  xmin: 0, xmax: 12, ymin: 0, ymax: 1.8,
  curves: (
    (stroke: accent, pts: fn-pts(step2(0.2, 2), 0, 12)),
    (stroke: rgb("#c94f7c"), pts: fn-pts(step2(0.5, 2), 0, 12)),
    (stroke: okc, pts: fn-pts(step2(0.707, 2), 0, 12)),
    (stroke: warn, dash: "dashed", pts: fn-pts(t => 1 - calc.exp(-2 * t) * (1 + 2 * t), 0, 12)), // ζ=1, ωn=2 临界阻尼
  ),
  hlines: ((1.0, (paint: axis-c, thickness: 0.6pt, dash: "dotted")),),
  marks: (
    (x: 9.5, y: 1.62, body: text(size: 8.5pt, fill: accent)[ζ = 0.2]),
    (x: 9.5, y: 1.30, body: text(size: 8.5pt, fill: rgb("#c94f7c"))[ζ = 0.5]),
    (x: 9.5, y: 1.10, body: text(size: 8.5pt, fill: okc)[ζ = 0.707]),
    (x: 9.5, y: 0.88, body: text(size: 8.5pt, fill: warn)[ζ = 1(临界)]),
  ),
  xlabel: [*t* / s], ylabel: [*y*(*t*)],
)

== Bode 幅频渐近线(xlog 演示)

#let bodmag(w) = 20 * calc.log(4, base: 10) - 10 * calc.log(1 + w * w, base: 10) - 10 * calc.log(1 + (w / 2) * (w / 2), base: 10)

#plot(
  xmin: 0.1, xmax: 100, ymin: -60, ymax: 15, xlog: true,
  curves: (
    (stroke: accent, pts: fn-pts-log(bodmag, 0.1, 100)),
    // 渐近线:0.1—1 平坦 +12 dB,1—2 斜率 -20,2—100 斜率 -40
    (stroke: gray, dash: "dashed", pts: ((0.1, 12.04), (1, 12.04), (2, 6.02), (100, 6.02 - 40 * 1.699))),
  ),
  hlines: ((0, (paint: axis-c, thickness: 0.6pt, dash: "dotted")),),
  vlines: ((1, (paint: axis-c, thickness: 0.6pt, dash: "dotted")), (2, (paint: axis-c, thickness: 0.6pt, dash: "dotted"))),
  marks: (
    (x: 0.13, y: 8, body: text(size: 8.5pt, fill: gray)[+12 dB]),
    (x: 1.35, y: 1, body: text(size: 8.5pt, fill: accent)[-20 dB/dec]),
    (x: 8, y: -25, body: text(size: 8.5pt, fill: accent)[-40 dB/dec]),
  ),
  xlabel: [$omega$ / rad·s⁻¹(对数刻度)], ylabel: [$|L|$ / dB],
)

== Nyquist 曲线

#let L3(w) = {
  let den = (2 - w * w) * (2 - w * w) + 9 * w * w
  ((2 - w * w) / den, -3 * w / den)
}
#let nyq-pts = {
  let pts = ()
  for i in range(241) {
    let w = calc.pow(10, -1 + 3 * i / 240)
    let (re, im) = L3(w)
    pts.push((re, im))
  }
  pts
}

#plot(
  xmin: -0.45, xmax: 1.15, ymin: -0.5, ymax: 0.25, height: 8.2cm,
  curves: ((stroke: accent, pts: nyq-pts),),
  hlines: ((0, (paint: axis-c, thickness: 0.6pt, dash: "dotted")),),
  vlines: ((0, (paint: axis-c, thickness: 0.6pt, dash: "dotted")),),
  marks: (
    (x: 0.56, y: 0.05, body: text(size: 8.5pt, fill: gray)[起点 $L(j 0) = 0.5$]),
    (x: 0.02, y: -0.44, body: text(size: 8.5pt, fill: accent)[ω → ∞ 沿原点切向进入]),
  ),
  xlabel: [$Re L(j omega)$], ylabel: [$Im L(j omega)$],
)

== 框图

#block(width: 15cm, height: 3.6cm, {
  let y0 = 1.55cm
  dlabel(0cm, y0 - 0.55em, text[*r*])
  harrow(0.8cm, y0, 1.6cm)
  dsum(2.4cm + 0pt, y0, signs: ((-1.35em, -0.7em, "+"), (-1.1em, 1.05em, "−")))
  harrow(3.4cm, y0, 1.6cm, label: [*e*])
  dblk(5.0cm, y0 - 0.75cm, 3.4cm, 1.5cm, text[被控对象 $G(s)$])
  harrow(8.4cm, y0, 2.6cm)
  dlabel(11.2cm, y0 - 0.55em, text[*y*])
  // 反馈支路:H(s)
  varrow(10.6cm, y0, 1.4cm)
  dblk(9.2cm, y0 + 1.4cm, 2.8cm, 1.0cm, text[$H(s)$])
  harrow(9.2cm, y0 + 1.9cm, -6.8cm) // 负长度 = 向左
  varrow(2.4cm, y0 + 1.9cm, -1.1cm) // 向上,接到汇总圆下缘(圆半径 11pt ≈ 0.39cm)
})
