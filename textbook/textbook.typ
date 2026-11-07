// 《控制理论:从推导到实验》—— 教材版主文件
// 原理:经典控制(第 1—8 章,配套 control-lab)+ 现代控制(第 9—12 章,配套 modern-control-lab)+ 数字实现(第 13 章,实验 10 回到 control-lab)
// 每章统一骨架:理论与推导 → 例题 → 实验(衔接实验台) → 思考题与习题 → 习题详解
// 构建产生 PDF。样式在 style.typ,绘图在 figlib.typ(纯 Typst 原生,零外部依赖)。
#import "style.typ": *
#import "figlib.typ": *

#show: setup
#show: show-rules

// ---------- 封面 ----------
#align(center)[
  #v(3.2cm)
  #text(size: 26pt, weight: "bold", fill: accent)[控制理论:从推导到实验]
  #v(0.5em)
  #text(size: 13pt, fill: gray)[—— 教材版 · 配套交互实验台 control-lab 与 modern-control-lab ——]
  #v(2.2cm)
  #text(size: 10.5pt, fill: gray)[
    每章五段式:理论与推导 → 例题 → 实验 → 思考题与习题 → 习题详解 \
    实验台:github.com/Leslieryin/control-lab · modern-control-lab \
    #v(0.3em) 2026 年 11 月
  ]
]
#pagebreak()

// ---------- 目录 ----------
#outline(depth: 2, title: [目录])
#pagebreak()

// ---------- 正文 ----------
#include "chapters/01-modeling.typ"

#part[第一部分　经典控制]

#include "chapters/02-second-order.typ"
#include "chapters/03-feedback-pid.typ"
#include "chapters/04-stability-routh.typ"
#include "chapters/05-bode.typ"
#include "chapters/06-nyquist.typ"
#include "chapters/07-root-locus.typ"
#include "chapters/08-compensation.typ"

#part[第二部分　现代控制]

#include "chapters/09-state-space.typ"
#include "chapters/10-pole-placement.typ"
#include "chapters/11-observer.typ"
#include "chapters/12-kalman.typ"

#part[第三部分　数字实现]

#include "chapters/13-discrete.typ"

#include "chapters/99-appendix.typ"
