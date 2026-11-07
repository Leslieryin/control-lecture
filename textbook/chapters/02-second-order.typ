// 第 2 章 —— 二阶系统的阶跃响应(由原讲义实验 1 扩写)
#import "../style.typ": *
#import "../figlib.typ": *

= 二阶系统的阶跃响应:ζ 与 ωₙ 决定一切

质量-弹簧-阻尼、RLC 电路、电枢控制电机、几乎任何"有惯性又有储能"的系统,经规范化后都是同一个传函。本章把这一个系统的阶跃响应算到底,得到三个工程上天天在用的公式;更重要的,是建立一种"翻译"意识——把振荡性格压缩成两个数 $zeta$ 与 $omega_n$。

== 标准二阶模型:两个参数的来历

考察常见二阶传函,把分母最高次项系数除掉、再把常数项配成 $omega_n^2$:

$ G(s) = (b)/(a_2 s^2 + a_1 s + a_0) = (omega_n^2)/(s^2 + 2 zeta omega_n s + omega_n^2) quad (a_2 > 0, a_0 > 0) $

其中

$ omega_n = sqrt(a_0/a_2), quad zeta = (a_1)/(2 sqrt(a_0 a_2)) $

$omega_n$ 叫*无阻尼自然频率*(分母仅剩 $s^2 + omega_n^2$ 时系统等幅振荡的角频率),$zeta$ 叫*阻尼比*。对质量-弹簧-阻尼系统 $m dot.double(y) + c dot(y) + k y = f$:代入得 $zeta = c/(2 sqrt(m k))$——阻尼系数恰好"卡"在临界值 $c_c = 2 sqrt(m k)$ 上的比例,$zeta$ 的名字由此而来。

#keybox[物理直觉:$zeta$ 是"刹车强度"。$zeta -> 0$ 刹不住车(等幅振荡),$zeta = 1$ 恰好贴线停车(最快不超调),$zeta > 1$ 一路点刹(又慢又稳又无趣)。$omega_n$ 则是整车的时间尺度——把 $omega_n$ 加倍,整条响应曲线在时间轴上压缩一半。]

== 阶跃响应的完整推导

单位阶跃输入下 $Y(s) = G(s)\/s$。按 $zeta$ 分三种情形,全部由部分分式 + 配方得到。

*欠阻尼(0 < ζ < 1)*——工程上最重要的一档。记 $omega_d = omega_n sqrt(1 - zeta^2)$(阻尼振荡频率),把分母配方:

$ s^2 + 2 zeta omega_n s + omega_n^2 = (s + zeta omega_n)^2 + omega_d^2 $

部分分式展开并反变换(用变换对 $e^(-a t) sin omega t$、$e^(-a t) cos omega t$):

$ Y(s) = (1)/s - (s + zeta omega_n)/((s + zeta omega_n)^2 + omega_d^2) - (zeta omega_n)/((s + zeta omega_n)^2 + omega_d^2) $

#deriv[
  $ y(t) = 1 - e^(-zeta omega_n t) [cos omega_d t + (zeta)/(sqrt(1 - zeta^2)) sin omega_d t] = 1 - (e^(-zeta omega_n t))/(sqrt(1 - zeta^2)) sin(omega_d t + phi), quad phi = "arccos" zeta $
]

*临界阻尼(ζ = 1)*:$Y(s) = omega_n^2/(s (s + omega_n)^2)$,重根部分分式给

#deriv[$ y(t) = 1 - e^(-omega_n t) (1 + omega_n t) $]

*过阻尼(ζ > 1)*:两个不相等的负实极点 $s_(1,2) = -omega_n (zeta ∓ sqrt(zeta^2 - 1))$,响应是两个衰减指数的叠加,单调无超调,不再展开。

三条曲线的性格差异完全由 $zeta$ 掌管;下图是同一条公式在不同 $zeta$ 下的画像:

#figure(
  plot(
    xmin: 0, xmax: 12, ymin: 0, ymax: 1.8,
    curves: (
      (stroke: accent, pts: fn-pts(t => 1 - calc.exp(-0.4 * t) / 0.9798 * calc.sin(1.9596 * t + 1.3694), 0, 12)),
      (stroke: rgb("#c94f7c"), pts: fn-pts(t => 1 - calc.exp(-1 * t) / 0.866 * calc.sin(1.7321 * t + 1.0472), 0, 12)),
      (stroke: okc, pts: fn-pts(t => 1 - calc.exp(-1.4142 * t) / 0.7071 * calc.sin(1.4142 * t + 0.7854), 0, 12)),
      (stroke: warn, dash: "dashed", pts: fn-pts(t => 1 - calc.exp(-2 * t) * (1 + 2 * t), 0, 12)),
    ),
    hlines: ((1.0, (paint: axis-c, thickness: 0.6pt, dash: "dotted")),),
    marks: (
      (x: 9.6, y: 1.62, body: text(size: 8.5pt, fill: accent)[$zeta = 0.2$]),
      (x: 9.6, y: 1.30, body: text(size: 8.5pt, fill: rgb("#c94f7c"))[$zeta = 0.5$]),
      (x: 9.6, y: 1.10, body: text(size: 8.5pt, fill: okc)[$zeta = 0.707$]),
      (x: 9.6, y: 0.88, body: text(size: 8.5pt, fill: warn)[$zeta = 1$(临界)]),
    ),
    xlabel: [$t$ / s], ylabel: [$y(t)$],
  ),
  caption: [标准二阶系统(ωₙ = 2 rad/s)的单位阶跃响应。全部振荡性格由 ζ 决定。],
)

== 性能指标的代数:三个天天在用的公式

阶跃响应的性能由三个量刻画:*峰值时间* $t_p$、*超调量* $M_p$、*调节时间* $t_s$。它们全都可以从上一节的解析式硬算出来。

*峰值时间*:对欠阻尼解 $dif y \/ dif t = 0$,利用 $e^(-zeta omega_n t) != 0$ 与 $tan theta$ 的周期性,得

$ (dif y)/(dif t) = 0 quad ==> quad tan(omega_d t + phi) = tan phi quad ==> quad t_p = (pi)/(omega_d) $

即正弦因子第一次到达峰值。(提醒:$dif y \/ dif t = 0$ 的解是一族等间隔时刻 $t = k pi \/ omega_d$,第一次的 $k = 1$。)

*超调量*:把 $t_p$ 代回,利用 $sin(omega_d t_p + phi) = sin(pi + phi) = -sin phi = -sqrt(1 - zeta^2)$:

$ M_p = y(t_p) - 1 = e^(-pi zeta \/ sqrt(1 - zeta^2)) times 100% $

*调节时间*(2% 误差带):响应被包络线 $1 ± e^(-zeta omega_n t) \/ sqrt(1 - zeta^2)$ 夹住,令包络进入 ±2%:

$ e^(-zeta omega_n t_s) approx 0.02 quad ==> quad t_s approx (4)/(zeta omega_n) $

(严格算应解 $e^(-zeta omega_n t_s) = 0.02 sqrt(1 - zeta^2)$,系数在 3.5—4.5 之间随 $zeta$ 变化;工程上取 4 已足够,但见本章习题——它在 $zeta = 1$ 附近会*低估*。)

#keybox[三个公式的分工:$zeta$ 独占 $M_p$;$zeta omega_n$(极点实部的大小)独占 $t_s$;$omega_d$ 给出振荡节拍。另外有个漂亮的小巧合:$zeta = 1 \/ sqrt(2) = 0.707$ 时 $M_p = e^(-pi) = 4.32%$,你以后每次听到"0.707 最优阻尼",背后就是这一行。]

== 例题

#example[正向:由参数算指标][
  已知 $zeta = 0.5$、$omega_n = 4$ rad/s,求 $M_p$、$t_p$、$t_s$(2%)。

  *解*:套用三公式——

  #deriv[
    $ M_p = e^(-pi times 0.5 / 0.866) = e^(-1.814) = 16.3%, quad t_p = (pi)/(4 times 0.866) = 0.91 "s", quad t_s = (4)/(0.5 times 4) = 2 "s" $
  ]

  再看实验台:把「二阶系统阶跃响应」页调到同参数,三个数字应与读图一致(超调读图约 16%,误差带离开时刻约 2 s)。
]

#example[反向:由指标定参数][
  设计要求超调量不超过 5%。$zeta$ 至少取多少?

  *解*:反解不等式 $e^(-pi zeta \/ sqrt(1 - zeta^2)) <= 0.05$。两边取对数:

  #deriv[
    $ (pi zeta)/(sqrt(1 - zeta^2)) >= ln 20 = 3.0 quad ==> quad (zeta^2)/(1 - zeta^2) >= 0.912 quad ==> quad zeta >= 0.690 $
  ]

  所以"超调 5% 以内"翻译成参数语言就是 $zeta >= 0.69$,工程上常直接说"取 $zeta approx 0.7$"。这种"指标 ↔ 参数"的双向翻译是设计的第一步。
]

== 实验 1:在实验台上看见 ζ 与 ωₙ

#labref[二阶系统阶跃响应][leslieryin.github.io/control-lab]

推导再多,不如亲手把 $zeta$ 拧一遍。打开实验台该页,默认 $zeta = 0.3$、$omega_n = 3$ rad/s、$K = 1$:

+ 固定 $omega_n = 3$,把 $zeta$ 从 0.3 逐步拖到 2.0,观察曲线从"衰减振荡"变为"无超调爬升";留意超调恰好消失的位置——应在 $zeta approx 0.707$ 附近。
+ 固定 $zeta = 0.3$,把 $omega_n$ 从 3 拖到 6,比较两条曲线的时间轴。
+ 调节增益 $K$,观察它改变了什么、*没*改变什么。

预期现象与结论:

- $zeta < 1$ 时曲线振荡衰减,超调量*只跟 $zeta$ 有关*:$zeta = 0.3 → M_p = 37%$;$zeta = 0.5 → 16%$;$zeta = 0.707 → 4.3%$。对照例题 2.1 与上节公式逐点核验。
- $omega_n$ 加倍后曲线形状不变,只是时间轴整体压缩——$t_s$ 减半。这正是"$omega_n$ 是时间尺度"的视觉版本。
- 增益 $K$ 改变的只是终值,*不改变*振荡快慢与超调比例:归一化后的形状完全相同。

#keybox[结论:二阶系统的"个性"由 $zeta$ 与 $omega_n$ 两人包场。这就是为什么后面所有设计方法(PID 整定、极点配置)最终都翻译成"你要 $zeta$ 是多少、$omega_n$ 是多少"。]

== 思考题与习题

#thinkbox[
  *思考题*

  + 超调量公式里看不到 $omega_n$。用时间尺度论证:为什么任何只依赖"归一化时间 $omega_n t$"的峰值比例都必然与 $omega_n$ 无关?
  + $zeta -> 0$ 时响应趋于什么?写出该极限的解析形式,并指出此时系统在物理上是什么。
]

*习题*(笔算,答案见下节)

+ 手算 $zeta = 0.6$、$omega_n = 5$ rad/s 的 $M_p$、$t_p$、$t_s$(2%),再上实验台对读。
+ 第 1 章例题 1.2 的闭环传函为 $phi(s) = 2/(s^2 + 3 s + 4)$。求其 $M_p$ 与 $t_s$,验证当时预告的"超调约 2.8%、调节时间约 2.7 s"。
+ 设计要求:*无超调*且 $t_s <= 1$ s。取临界阻尼($zeta = 1$),$omega_n$ 至少多大?把结果与 $t_s = 4/(zeta omega_n)$ 给出的值比较,你发现了公式的什么局限?
+ $zeta = 0.3$ 时超调约 37%。想把它压到 10% 以内,$zeta$ 至少要多少?(先心算数量级,再精确求解。)

== 习题详解

+ $sqrt(1 - 0.36) = 0.8$。$M_p = e^(-0.6 pi \/ 0.8) = e^(-2.356) = 9.5%$;$t_p = pi \/ (5 times 0.8) = 0.785$ s;$t_s = 4 \/ (0.6 times 5) = 1.33$ s。
+ $omega_n = 2$、$zeta = 0.75$:$M_p = e^(-0.75 pi \/ sqrt(1 - 0.5625)) = e^(-3.562) = 2.8%$;$t_s = 4 \/ (0.75 times 2) = 2.67$ s。解析计算与第 1 章的预告吻合——那一章留下的"翻译承诺"至此兑现。
+ 临界阻尼 $y(t) = 1 - e^(-omega_n t)(1 + omega_n t) = 0.98$。令 $x = omega_n t$,数值解 $e^(-x)(1 + x) = 0.02$ 得 $x approx 5.8$(可代入 $x = 5.8$ 验证:$e^(-5.8) times 6.8 = 0.0207$)。故 $omega_n >= 5.8$ rad/s。而公式 $t_s = 4/(zeta omega_n)$ 在 $zeta = 1$ 处给 $omega_n >= 4$——*低估*。原因:该公式由欠阻尼包络线推出,$zeta -> 1$ 时真实响应"尾部"比包络更肥(重根的 $t e^(-omega_n t)$ 项衰减更慢)。公式是模型,不是真理;知道它的适用范围才算学会。
+ $e^(-pi zeta \/ sqrt(1 - zeta^2)) = 0.1$ 给 $pi zeta \/ sqrt(1 - zeta^2) = ln 10 = 2.303$,解得 $(zeta^2)/(1 - zeta^2) = 0.537$,$zeta^2 = 0.349$,$zeta >= 0.591$。与例题 2.2 的 5% 要求($zeta >= 0.69$)对照:指标每收紧一档,$zeta$ 的代价非线性上涨——这就是为什么工程上"够用就好"。
