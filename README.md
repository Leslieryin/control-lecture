# control-lecture · 控制理论实验讲义

> **EN** — A lab manual for the interactive control-theory labs: for each of the 9 experiments, minimal theory → exact things to try on the playground → what you should observe → check-yourself questions. Chinese only, PDF + Typst source.

与交互实验台配套的实验指导书。教科书负责推导，实验台负责让你*看见*，这本讲义负责把两者接起来：每个实验四段式——**理论要点 → 实验台操作 → 预期现象 → 思考题**。

## 配套实验台

| 讲义章节 | 实验台 | 在线打开 |
| --- | --- | --- |
| 实验 1—5（经典控制） | [control-lab](https://github.com/Leslieryin/control-lab) | [leslieryin.github.io/control-lab](https://leslieryin.github.io/control-lab/) |
| 实验 6—9（现代控制） | [modern-control-lab](https://github.com/Leslieryin/modern-control-lab) | [leslieryin.github.io/modern-control-lab](https://leslieryin.github.io/modern-control-lab/) |

两个实验台都是单文件 HTML：零依赖、离线可用、所有计算在浏览器本地完成，固定随机种子保证复现。讲义里的操作步骤（滑块默认值、示例传函）与实验台当前版本一一对应。

## 内容目录

- **实验 1** 二阶系统的阶跃响应：ζ 与 ωₙ 决定一切
- **实验 2** PID 控制器：三个参数各自做什么
- **实验 3** Bode 图与稳定裕度
- **实验 4** Nyquist 图与稳定性判据
- **实验 5** 根轨迹：增益 K 从 0 → ∞ 的闭环极点运动
- **实验 6** 状态空间与能控性、能观性
- **实验 7** 极点配置：Ackermann 公式
- **实验 8** 状态观测器：从输出反推全状态
- **实验 9** 卡尔曼滤波：带噪声的观测器（Joseph 形式协方差更新）
- **附录** 实验报告模板（五问式，一页以内）

数值锚点与实验台测试套件同源：二阶超调公式、Ackermann 教科书结果 K=[6,11,6]、KF 估计 RMSE 对比测量 RMSE 等，均可在各实验台仓库的 `tests/` 中找到自动化断言。

## 构建 PDF

```sh
typst compile lecture.typ 控制理论实验讲义.pdf
```

需要 Typst ≥ 0.12（在 0.15.1 上开发）。源码为单文件 `lecture.typ`，中文字体回退到 Microsoft YaHei，改参数即改讲义，无需其他构建步骤。

## License

MIT
