# control-lecture · 控制理论实验讲义 & 教材

> **EN** — A lab manual *and* a full textbook for the interactive control-theory labs. The lab manual (`lecture.typ`) keeps the lean 4-part format per experiment; the textbook (`textbook/`) expands every experiment into a complete chapter with derivations, worked examples, problem sets and full solutions. Chinese only, PDF + Typst source, zero external packages.

与交互实验台配套的控制理论文档,现在有两层:

- **`lecture.typ` — 实验讲义**(轻量版):教科书负责推导,实验台负责让你*看见*,讲义把两者接起来。每个实验四段式——**理论要点 → 实验台操作 → 预期现象 → 思考题**。
- **`textbook/` — 教材版《控制理论:从推导到实验》**(完整版):每个实验扩写成完整一章,统一五段式——**理论与推导(不跳步)→ 例题(数值全部机器验证)→ 实验(衔接实验台)→ 思考题与习题 → 习题详解**;另含劳斯判据、频域补偿设计、离散系统与数字控制、最优控制与 LQR 等全新推导章与全书数值锚点速查附录。所有插图由纯 Typst 原生绘图库生成(`textbook/figlib.typ`),**零外部依赖**,与实验台"单文件、离线可用"的哲学一致。

## 配套实验台

| 章节 | 实验台 | 在线打开 |
| --- | --- | --- |
| 第 2—8、13、14 章(经典控制、数字实现与最优控制) | [control-lab](https://github.com/Leslieryin/control-lab) | [leslieryin.github.io/control-lab](https://leslieryin.github.io/control-lab/) |
| 第 9—12 章(现代控制) | [modern-control-lab](https://github.com/Leslieryin/modern-control-lab) | [leslieryin.github.io/modern-control-lab](https://leslieryin.github.io/modern-control-lab/) |

两个实验台都是单文件 HTML:零依赖、离线可用、所有计算在浏览器本地完成,固定随机种子保证复现。讲义与教材里的操作步骤(滑块默认值、示例传函)与实验台当前版本一一对应。

## 教材目录

**第一部分 经典控制**

- **第 1 章** 微分方程、传递函数与框图(拉普拉斯速成 · 反馈公式的三行推导)
- **第 2 章** 二阶系统的阶跃响应:ζ 与 ωₙ 决定一切(Mp/tp/ts 完整推导)
- **第 3 章** 反馈的原理与 PID 控制(扰动抑制 · 系统型别 · Ziegler–Nichols 全数值例题)
- **第 4 章** 稳定性与劳斯判据(BIBO ⇔ 极点位置 · ε 法与辅助多项式 · 含参稳定区间)
- **第 5 章** 频域视角:Bode 图与稳定裕度(渐近线作图法 · 因子分解规则)
- **第 6 章** Nyquist 图与奈奎斯特判据(幅角原理 · D 形围线 · 开环不稳定系统)
- **第 7 章** 根轨迹:增益旋钮下的极点运动(相角条件 · 五条规则 · 数值轨迹图)
- **第 8 章** 频域补偿设计:超前、滞后与 PID 再会(φm = arcsin((a−1)/(a+1)) · 完整设计例题)

**第二部分 现代控制**

- **第 9 章** 状态空间:能控性与能观性(秩判据来历 · "零传函"隐身状态)
- **第 10 章** 极点配置:Ackermann 公式(三重积分器锚点 K=[6,11,6] · 带宽的代价)
- **第 11 章** 状态观测器与对偶设计(误差动态 · 分离原理的块三角证明)
- **第 12 章** 卡尔曼滤波:让噪声统计替你设计(预测—校正推导 · Joseph 形式证明 · K∞ 随 R/Q 曲线)

**第三部分 数字实现**

- **第 13 章** 离散系统与数字控制(采样与零阶保持 · z 变换与单位圆判据 · Jury 速查与 w-劳斯 · 数字 PID 与隔拍振铃)

**第四部分 最优控制**

- **第 14 章** 最优控制与 LQR(二次型性能指标 · 极小值原理与 bang-bang · Riccati 配方推导 · 回差定理与 ≥60° 裕度 · LQG 对偶收线)
- **附录** 实验报告模板 + 全书数值锚点速查表

数值锚点与实验台测试套件同源:二阶超调公式、Ackermann 教科书结果 K=[6,11,6]、根轨迹临界增益 K=16(交点 ±j√7)、KF 估计 RMSE 对比测量 RMSE、LQR 双积分器 K=[1,√3](ζ=0.866、PM≥60°)等,均可在各实验台仓库的 `tests/` 中找到自动化断言;教材附录的速查表把全书可复算数字集中一页。

## 构建 PDF

```sh
# 实验讲义(轻量版)
typst compile lecture.typ 控制理论实验讲义.pdf

# 教材版
typst compile textbook/textbook.typ 控制理论教材.pdf
```

需要 Typst ≥ 0.14(教材用了 0.14 引入的 `curve` 绘图;在 0.15.1 上开发)。零第三方包——`typst` 会自动内嵌所需字体回退(中文回退 Microsoft YaHei),克隆即编译,离线可用。

## License

MIT
