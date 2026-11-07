// 控制理论教材 —— 纯 Typst 原生绘图库(零外部依赖)
// 约定:数据坐标 y 轴向上,本库负责翻转;
// 每条折线作为独立 place 元素,由库自己计算包围盒定位,
// 不依赖 Typst 对 curve 元素的 bbox 归一化行为,结果确定可复现。
#import "style.typ": accent, warn, okc, gray

#let ink = rgb("#3a4a5a")
#let axis-c = rgb("#8a97a5")

// ---------- 采样与刻度 ----------
// 以函数 f 在 [a, b] 上均匀采 n+1 个点
#let fn-pts(f, a, b, n: 200) = {
  let pts = ()
  for i in range(n + 1) {
    let x = a + (b - a) * i / n
    pts.push((x, f(x)))
  }
  pts
}

// 在 [a, b] 内对数均匀采 n+1 个点(Bode、Nyquist 用)
#let fn-pts-log(f, a, b, n: 240) = {
  let la = calc.log(a, base: 10)
  let lb = calc.log(b, base: 10)
  let pts = ()
  for i in range(n + 1) {
    let x = calc.pow(10, la + (lb - la) * i / n)
    pts.push((x, f(x)))
  }
  pts
}

// 优雅刻度步长(1/2/5 × 10^k)
#let nice-step(raw) = {
  let mag = calc.pow(10, calc.floor(calc.log(raw, base: 10)))
  let r = raw / mag
  let m = if r <= 1 { 1 } else if r <= 2 { 2 } else if r <= 5 { 5 } else { 10 }
  m * mag
}

// 刻度标签格式化:整数不带小数点,其余留 2 位
#let fmt-num(v) = {
  let r = calc.round(v, digits: 4)
  if calc.abs(r - calc.round(r)) < 1e-9 { str(calc.round(r)) } else { str(calc.round(r, digits: 2)) }
}

// [a, b] 内的刻度值(约 want 个)
#let ticks-in(a, b, want: 5) = {
  let step = nice-step((b - a) / want)
  let out = ()
  let i0 = calc.ceil(a / step - 1e-9)
  let i1 = calc.floor(b / step + 1e-9)
  for i in range(i0, i1 + 1) { out.push(i * step) }
  out
}

// ---------- 主绘图 ----------
// curves: ((stroke:, pts: ((x, y), ...), dash: none), ...)
// hlines / vlines: (值, stroke) 参考线(建议 stroke 带 dash)
// marks: (x:, y:, body:, dx: 0pt, dy: 0pt) 数据坐标标注,锚点为左上
#let plot(
  width: 15cm, height: 7.8cm,
  xmin: 0, xmax: 10, ymin: -1, ymax: 1,
  xlog: false,
  curves: (),
  xticks: auto, yticks: auto,
  xticklabels: auto, yticklabels: auto,
  xlabel: none, ylabel: none,
  hlines: (), vlines: (),
  marks: (),
) = context {
  let pl = (if ylabel == none { 1.0cm } else { 1.7cm })
  let pr = 0.7cm
  let ptop = 0.55cm
  let pbot = (if xlabel == none { 0.85cm } else { 1.25cm })
  let dw = width - pl - pr
  let dh = height - ptop - pbot
  // 数据坐标 → 绘图区局部坐标(长度);xlog 时按 log10 映射
  let lx(x) = if xlog { calc.log(x, base: 10) } else { x }
  let lxmin = lx(xmin)
  let lxmax = lx(xmax)
  let mx(x) = (lx(x) - lxmin) / (lxmax - lxmin) * dw
  let my(y) = (ymax - y) / (ymax - ymin) * dh

  // 轴的位置:0 在范围内则过 0,否则贴边(xlog 时 0 不在定义域,恒贴左)
  let ax-y = if not xlog and ymin <= 0 and ymax >= 0 { my(0) } else { dh }
  let ax-x = if not xlog and xmin <= 0 and xmax >= 0 { mx(0) } else { 0pt }
  let zero-cross-y = not xlog and ymin <= 0 and ymax >= 0
  let zero-cross-x = not xlog and xmin <= 0 and xmax >= 0
  let tick = 3.5pt
  let axis-stroke = 0.7pt + axis-c

  // 一条折线(局部坐标)→ 按自身包围盒定位的 place 元素
  let raw-elem(lpts, stroke) = {
    if lpts.len() >= 2 {
      let mnx = calc.min(..lpts.map(p => p.first()))
      let mny = calc.min(..lpts.map(p => p.last()))
      let comps = lpts.enumerate().map(((i, p)) => if i == 0 {
        curve.move((p.first() - mnx, p.last() - mny), relative: false)
      } else {
        curve.line((p.first() - mnx, p.last() - mny), relative: false)
      })
      place(top + left, dx: pl + mnx, dy: ptop + mny, curve(stroke: stroke, ..comps))
    } else { [] }
  }
  let stroke-elem(pts, stroke) = raw-elem(pts.map(p => (mx(p.first()), my(p.last()))), stroke)

  // 防御:参考线单个条目写成 (v, stroke) 而非 ((v, stroke),) 时自动包一层,免踩尾逗号坑
  // (curves/marks 的条目本身是字典,与漏包无法区分,不做防御,调用时记得尾逗号)
  let wrap1(seq) = if seq.len() > 0 and type(seq.first()) != array { (seq,) } else { seq }
  let hlines = wrap1(hlines)
  let vlines = wrap1(vlines)

  let els = ()
  // 参考线
  for (y, st) in hlines { els.push(stroke-elem(((xmin, y), (xmax, y)), st)) }
  for (x, st) in vlines { els.push(stroke-elem(((x, ymin), (x, ymax)), st)) }
  // 坐标轴
  els.push(raw-elem(((0pt, ax-y), (dw, ax-y)), axis-stroke))
  els.push(raw-elem(((ax-x, 0pt), (ax-x, dh)), axis-stroke))
  // 刻度;xlog 时默认取整十倍频
  let xt = if xticks == auto {
    if xlog {
      let out = ()
      for k in range(calc.ceil(lxmin - 1e-9), calc.floor(lxmax + 1e-9) + 1) { out.push(calc.pow(10, k)) }
      out
    } else { ticks-in(xmin, xmax) }
  } else { xticks }
  let yt = if yticks == auto { ticks-in(ymin, ymax) } else { yticks }
  // 单个刻度的默认标签;xlog 横轴用 10^k
  let tick-label(t, log-decade) = if log-decade {
    let k = calc.round(calc.log(t, base: 10))
    if k == 0 { text(size: 8pt, fill: gray, [1]) } else {
      text(size: 8pt, fill: gray, [10#super(str(calc.round(k)))])
    }
  } else { text(size: 8pt, fill: gray, fmt-num(t)) }
  for t in xt {
    let x = mx(t)
    els.push(raw-elem(((x, ax-y - tick), (x, ax-y + tick)), axis-stroke))
    if xticklabels != none {
      let lab = if xticklabels == auto { tick-label(t, xlog) } else if type(xticklabels) == function { xticklabels(t) } else { xticklabels }
      let m = measure(lab); let w = m.width; let h = m.height
      els.push(place(top + left, dx: pl + x - w / 2, dy: ptop + ax-y + tick + 2pt, lab))
    }
  }
  for t in yt {
    let y = my(t)
    els.push(raw-elem(((ax-x - tick, y), (ax-x + tick, y)), axis-stroke))
    if yticklabels != none {
      // 两轴交于 0 时,原点的"0"只标横轴,避免重叠
      if not (t == 0 and zero-cross-x) {
        let lab = if yticklabels == auto { tick-label(t, false) } else if type(yticklabels) == function { yticklabels(t) } else { yticklabels }
        let m = measure(lab); let w = m.width; let h = m.height
        els.push(place(top + left, dx: pl + ax-x - tick - 3pt - w, dy: ptop + y - h / 2, lab))
      }
    }
  }
  // 数据曲线
  for c in curves {
    let st = if "dash" in c { (paint: c.stroke, thickness: 1.1pt, dash: c.dash) } else { c.stroke }
    els.push(stroke-elem(c.pts, st))
  }
  // 数据坐标标注
  for mk in marks {
    let dx = if "dx" in mk { mk.dx } else { 0pt }
    let dy = if "dy" in mk { mk.dy } else { 0pt }
    if "center" in mk and mk.center {
      let m = measure(mk.body); let w = m.width; let h = m.height
      dx = dx - w / 2
      dy = dy - h / 2
    }
    els.push(place(top + left, dx: pl + mx(mk.x) + dx, dy: ptop + my(mk.y) + dy, mk.body))
  }
  // 轴标签
  if xlabel != none {
    let m = measure(xlabel); let w = m.width; let h = m.height
    els.push(place(top + left, dx: pl + (dw - w) / 2, dy: height - pbot + (pbot - h) / 2, xlabel))
  }
  if ylabel != none {
    let m = measure(ylabel); let w = m.width; let h = m.height
    // 逆时针转 90°后,视觉中心 = 未旋转内容盒中心;放到左边距正中
    els.push(place(top + left, dx: 0.28cm - w / 2, dy: ptop + dh / 2 - h / 2, rotate(-90deg, ylabel)))
  }
  // 注意:block 不是可变参数函数,不能 ..展开,要用 join 合成单一内容
  block(width: width, height: height, breakable: false, els.filter(e => e != none).join())
}

// ---------- 框图原语 ----------
// 所有原语以 (x, y) 为锚点(左上),供 place 使用;坐标单位为长度。
// 箭头三角形库:尖端朝右/左/下/上,尖端在 bbox 内的坐标见注释
#let tri-right = curve(fill: ink,
  curve.move((0pt, 0pt), relative: false),
  curve.line((4.5pt, 2.2pt), relative: false),
  curve.line((0pt, 4.4pt), relative: false),
  curve.close())
#let tri-left = curve(fill: ink,
  curve.move((0pt, 2.2pt), relative: false),
  curve.line((4.5pt, 0pt), relative: false),
  curve.line((4.5pt, 4.4pt), relative: false),
  curve.close())
#let tri-down = curve(fill: ink,
  curve.move((0pt, 0pt), relative: false),
  curve.line((4.4pt, 0pt), relative: false),
  curve.line((2.2pt, 4.5pt), relative: false),
  curve.close())
#let tri-up = curve(fill: ink,
  curve.move((0pt, 4.5pt), relative: false),
  curve.line((4.4pt, 4.5pt), relative: false),
  curve.line((2.2pt, 0pt), relative: false),
  curve.close())

// 水平箭头:从 (x, y) 指向 (x + len, y);len 可为负(向左);label 放在箭头上方居中
#let harrow(x, y, len, label: none, stroke: 0.8pt + ink) = {
  let els = (place(top + left, dx: calc.min(x, x + len), dy: y, line(length: calc.abs(len), stroke: stroke)),)
  if len >= 0pt {
    els.push(place(top + left, dx: x + len - 4.5pt, dy: y - 2.2pt, tri-right))
  } else {
    els.push(place(top + left, dx: x + len, dy: y - 2.2pt, tri-left))
  }
  if label != none {
    els.push(place(top + left, dx: calc.min(x, x + len), dy: y - 1.15em, block(width: calc.abs(len), align(center, text(size: 0.85em, label)))))
  }
  els.join()
}

// 垂直箭头:从 (x, y) 指向 (x, y + len);len 可为负(向上)
#let varrow(x, y, len, label: none, stroke: 0.8pt + ink) = {
  let els = (place(top + left, dx: x, dy: calc.min(y, y + len), line(angle: 90deg, length: calc.abs(len), stroke: stroke)),)
  if len >= 0pt {
    els.push(place(top + left, dx: x - 2.2pt, dy: y + len - 4.5pt, tri-down))
  } else {
    els.push(place(top + left, dx: x - 2.2pt, dy: y + len, tri-up))
  }
  if label != none {
    els.push(place(top + left, dx: x + 5pt, dy: calc.min(y, y + len) + 0.2em, text(size: 0.85em, label)))
  }
  els.join()
}

// 功能块:(x, y) 左上角,w × h,内容居中
#let dblk(x, y, w, h, body, fill: white, stroke: 0.8pt + ink) = place(
  top + left, dx: x, dy: y,
  block(width: w, height: h, fill: fill, stroke: stroke, radius: 2pt,
    align(center + horizon, body)),
)

// 汇总点:圆心 (x, y);signs: ((dx, dy, 符号), ...) 相对圆心
#let dsum(x, y, signs: ((1.2em, 0em, "+"),)) = {
  let r = 11pt
  let els = (place(top + left, dx: x - r, dy: y - r,
    circle(radius: r, stroke: 0.8pt + ink, fill: white)),)
  for (dx, dy, s) in signs {
    els.push(place(top + left, dx: x + dx - 0.5em, dy: y + dy - 0.65em, text(fill: ink, s)))
  }
  els.join()
}

// 自由文字标注:锚点 (x, y) 左上
#let dlabel(x, y, body) = place(top + left, dx: x, dy: y, body)
