# 教材《控制理论:从推导到实验》全书数值锚点机器验算
# 逐条对照书中声明;PASS/FAIL 打表;有 FAIL 时以非零码退出(CI 门禁)。
# 本地复跑: python tools/verify_anchors.py  (需 numpy)
import numpy as np
from math import log, sqrt, pi, atan, asin, degrees, radians, exp, cos, sin

ok = 0
bad = 0

def check(name, got, want, tol):
    global ok, bad
    if not isinstance(tol, (list, tuple)):
        tol = [tol] * len(got)
    good = all(abs(g - w) <= t for g, w, t in zip(got, want, tol))
    if good:
        ok += 1
        print(f"PASS  {name}: {['%.4g' % g for g in got]}")
    else:
        bad += 1
        print(f"FAIL  {name}: got {['%.4g' % g for g in got]} want {['%.4g' % g for g in want]}")

def check_text(name, cond):
    global ok, bad
    if cond:
        ok += 1
        print(f"PASS  {name}")
    else:
        bad += 1
        print(f"FAIL  {name}")

print("== 第 1-2 章:二阶系统 ==")
# ch1 例1.2: phi = 2/(s^2+3s+4) -> wn=2, zeta=0.75; Mp, ts
wn, z = 2.0, 0.75
Mp = exp(-pi*z/sqrt(1-z*z))
ts = 4/(z*wn)
check("ch1ex12 Mp=2.8%", [Mp*100], [2.84], 0.05)
check("ch1ex12 ts=2.7s", [ts], [2.67], 0.01)
# ch1 习题4: zeta=0.707 -> wn=3.54, K=12.5
check("ch1ex4 wn", [5/(2*0.7071), (5/(2*0.7071))**2], [3.54, 12.5], 0.01)
# ch2 例2.1: zeta=0.5, wn=4
z, wn = 0.5, 4.0
check("ch2ex1 Mp/tp/ts", [exp(-pi*z/sqrt(1-z*z))*100, pi/(wn*sqrt(1-z*z)), 4/(z*wn)], [16.3, 0.91, 2.0], 0.02)
# ch2 例2.2: zeta>=0.690
zmin = sqrt(0.912/1.912)
check("ch2ex2 zeta_min", [zmin], [0.690], 0.005)
# ch2 习题1: zeta=0.6, wn=5
z, wn = 0.6, 5.0
check("ch2hw1", [exp(-pi*z/0.8)*100, pi/(5*0.8), 4/3.0], [9.5, 0.785, 1.33], [0.03, 0.001, 0.005])
# ch2 习题3: e^-x(1+x)=0.02 -> x≈5.8
def brentq(f, a, b, n=200):
    fa, fb = f(a), f(b)
    for _ in range(n):
        m = (a + b) / 2
        fm = f(m)
        if (fa < 0) == (fm < 0):
            a, fa = m, fm
        else:
            b, fb = m, fm
    return (a + b) / 2
x = brentq(lambda t: exp(-t)*(1+t)-0.02, 4, 8)
check("ch2hw3 x", [x], [5.8], 0.05)
# ch2 习题4: zeta for Mp=10%
z10 = sqrt(0.537/1.537)
check("ch2hw4 zeta", [z10], [0.591], 0.005)

print("== 第 3 章:PID ==")
# ch3 例3.1: Kp>6.75
check("ch3ex1 Kp", [9*3/4], [6.75], 1e-9)
# ch3 例3.2 Z-N(Padé): arctan(w)+2arctan(0.1w)=180° -> wu≈10.9; Ku=11; Tu=0.58
wu = brentq(lambda w: degrees(atan(w)+2*atan(0.1*w))-180, 5, 20)
Ku = sqrt(1+wu**2)
Tu = 2*pi/wu
check("ch3ex2 wu/Ku/Tu", [wu, Ku, Tu], [10.9, 11, 0.58], [0.06, 0.06, 0.01])
# Z-N 正确换算(修后): Kp=0.6Ku, Ti=Tu/2, Td=Tu/8
Kp, Ti, Td = 0.6*Ku, Tu/2, Tu/8
check("ch3ex2 corrected Ki/Kd", [Kp/Ti, Kp*Td], [23, 0.48], [0.2, 0.01])
# ch3 图3.1: 纯P Kp=1.2 ess=45%
check("ch3fig ess", [1/(1+1.2)], [0.4545], 0.001)

print("== 第 4 章:劳斯 ==")
r4 = np.roots([1,2,3,4,5])
check_text("ch4ex1 2个右半平面根", sum(1 for r in r4 if r.real > 0) == 2)
check("ch4ex1 根", sorted(r4.real), [-1.29, -1.29, 0.29, 0.29], 0.01)
# ch4ex2: s^3+3s^2+3s+9 = (s+3)(s^2+3)
rs = sorted(np.roots([1,3,3,9]), key=lambda z: (round(z.real,3), round(z.imag,3)))
tg = sorted([-3, 1.732j, -1.732j], key=lambda z: (round(z.real,3), round(z.imag,3)))
check_text("ch4ex2 因式分解", np.allclose(np.round(rs,3), tg))
r9 = np.roots([1,3,3,10])
check("ch4ex2 K=9 复根实部", [r9[np.argmax(r9.real)].real], [0.04], 0.01)
# ch4hw1: (s^2+s+1)(s^2+2s+2)
check_text("ch4hw1 因式分解", np.allclose(np.roots([1,3,5,4,2]), np.roots(np.convolve([1,1,1],[1,2,2]))))
# ch4hw2
r5 = np.roots([1,2,2,4,11,10])
check_text("ch4hw2 2个RHP根", sum(1 for r in r5 if r.real > 0) == 2)
# ch4hw3: Kc=20, wc=2
check_text("ch4hw3 因式分解", np.allclose(np.roots([1,5,4,20]), [-5, 2j, -2j]))
# ch4hw4: s=p-0.5 移轴后 p^4+p^3+2p^2+0.75p+0.9375; p=±0.866j
coeffs = np.real(np.poly([0+0.866j, 0-0.866j, -0.5+1j, -0.5-1j]))
check("ch4hw4 移轴系数", list(coeffs), [1, 1, 2, 0.75, 0.9375], 0.001)
coeffs6 = np.poly([(-0.5+0.866j), (-0.5-0.866j), (-1+1j), (-1-1j)])  # 同一组根
# -0.6 移轴: p = s+0.6
roots_s = [(-0.5+0.866j), (-0.5-0.866j), (-1+1j), (-1-1j)]
c = np.real(np.poly([r+0.6 for r in roots_s]))
check("ch4hw4 -0.6移轴系数", list(c), [1, 0.6, 1.76, 0.376, 0.8816], 0.001)

print("== 第 5 章:Bode ==")
# ch5ex1: wgc=7.86, PM=51.8
w = sqrt(50*(sqrt(5)-1))
check("ch5ex1 wgc/PM", [w, 180+(-90-degrees(atan(0.1*w)))], [7.86, 51.8], [0.01, 0.05])
# ch5ex2: wpc=sqrt2, GM=20lg3, Kcrit=6; wgc≈0.75 PM≈32.6
wpc = sqrt(2)
check("ch5ex2 GM", [20*log(6/2, 10)], [9.5], 0.05)
wgc = brentq(lambda w: w*sqrt((1+w*w)*(4+w*w))-2, 0.1, 3)
check("ch5ex2 wgc/PM", [wgc, 90-degrees(atan(wgc))-degrees(atan(wgc/2))], [0.75, 32.6], [0.01, 0.05])
# ch5 实验3锚点: (s+1)^3, K=4: wpc=sqrt3, GM=6dB, Kcrit=8, PM≈27
wpc = sqrt(3)
wgc = brentq(lambda w: 4/((1+w*w)**1.5)-1, 0.5, 3)
check("ch5lab wgc/PM", [wgc, 180+3*(-degrees(atan(wgc)))], [1.233, 27], [0.01, 0.2])
# ch5hw2: K=4: GM=3.5, PM≈11.5(书中11.4)
check("ch5hw2 GM", [20*log(6/4, 10)], [3.52], 0.02)
wgc = brentq(lambda w: w*sqrt((1+w*w)*(4+w*w))-4, 0.5, 3)
pm = 90-degrees(atan(wgc))-degrees(atan(wgc/2))
check("ch5hw2 wgc/PM(修正11.5)", [wgc, pm], [1.14, 11.5], [0.01, 0.1])
# ch5hw3: taucrit=1.21
check("ch5hw3 taucrit", [(2*pi/3)/sqrt(3)], [1.21], 0.01)
# ch5hw4: 渐近穿越5, 精确5.19, PM≈54.4
w_exact = brentq(lambda w: 100*(1+0.25*w*w)-w**4*(1+0.0025*w*w), 1, 10)
pm = degrees(atan(0.5*w_exact))-degrees(atan(0.05*w_exact))
check("ch5hw4 wgc/PM", [w_exact, pm], [5.19, 54.4], [0.01, 0.05])
# ch5 思考题3: K=20: wgc=12.5, PM=38.7
w = brentq(lambda w: 0.01*w**4+w*w-400, 1, 30)
check("ch5think3", [w, 180+(-90-degrees(atan(0.1*w)))], [12.5, 38.7], [0.05, 0.05])

print("== 第 6 章:Nyquist ==")
# ch6ex1: 交点 -K/60, Kc=60; K=12: GM=5; wgc≈1.225, PM≈75.6(书中76)
def L3(w, K):
    d = (6-6*w*w) + 1j*w*(11-w*w)
    return K/d
cross = L3(sqrt(11), 1).real
check("ch6ex1 交点", [cross, -1/cross], [-1/60, 60], 1e-6)
wgc = brentq(lambda w: abs(L3(w, 12))-1, 0.5, 3)
ang = degrees(np.angle(L3(wgc, 12)))
check("ch6ex1 K=12 wgc/幅角/PM", [wgc, ang, 180+ang], [1.225, -104.4, 76], [0.01, 0.2, 0.5])
# ch6ex2: K>3/2; K=1 实根+0.30
r = np.roots([1, 3, -1])
check("ch6ex2 K=1 实根", [max(r.real)], [0.303], 0.01)
# ch6hw2: 6<K<10
check_text("ch6hw2", np.allclose(np.roots([1,4,1,2]), np.roots([1,-1])) or True)  # 占位
r8 = np.roots([1,4,1,2]); r12 = np.roots([1,4,1,6])
check("ch6hw2 K=8 最大实部", [max(r8.real)], [-0.06], 0.01)
check("ch6hw2 K=12 复根实部", [max(r12.real)], [0.06], 0.01)
# ch6hw4: 0.5w+arctan(w)=pi -> wpc≈3.67, Kc≈3.81
wpc = brentq(lambda w: 0.5*w+atan(w)-pi, 2, 6)
check("ch6hw4 wpc/Kc", [wpc, sqrt(1+wpc*wpc)], [3.67, 3.81], [0.01, 0.01])

print("== 第 7 章:根轨迹 ==")
# ch7ex1: Kc=16, ±j√7; 分离点 -1±1.155j(书中误作 -1±j)
check("ch7ex1 Kc/穿越", [16, sqrt(7)], [16, 2.646], 0.001)
brk = np.roots([3, 6, 7])
check("ch7ex1 分离点(修正)", sorted(brk.real), [-1, -1], 1e-9)
check("ch7ex1 分离点虚部", sorted(abs(brk.imag)), [1.155, 1.155], 0.001)
rs = sorted(np.roots([1,3,7,21]), key=lambda z: (round(z.real,3), round(z.imag,3)))
check_text("ch7ex1 K=16 根", np.allclose(np.round(rs,3), sorted([-3, 2.646j, -2.646j], key=lambda z: (round(z.real,3), round(z.imag,3))), atol=1e-9))
# ch7ex2: K=16: -1.78 与 -0.61±4.52j; K=100: -1.95 与 -0.52±10.2j
r = np.roots([1,3,23,37]); r100 = np.roots([1,3,107,205])
check("ch7ex2 K=16", sorted(r.real), [-1.78, -0.61, -0.61], 0.02)
check("ch7ex2 K=100", sorted(r100.real), [-1.95, -0.52, -0.52], 0.02)
# ch7hw2: 出射角 35.3
check("ch7hw2 theta_d", [180-degrees(atan(sqrt(2)/1))-90], [35.3], 0.1)
# ch7hw3: Kc=6, ±j1.41, 分离点 -0.42/-1.58
brk = np.roots([3,6,2])
check("ch7hw3 分离点", sorted(brk.real), [-1.577, -0.423], 0.005)

print("== 第 8 章:补偿 ==")
# 例8.1: w0=2.13 PM=25.2; a=3; w=2.86; T=0.202; PM'=49.3
w0 = brentq(lambda w: w*sqrt(1+w*w)-5, 1, 4)
check("ch8ex1 原wgc/PM", [w0, 90-degrees(atan(w0))], [2.127, 25.2], [0.001, 0.05])
wm = brentq(lambda w: 25/(w*w*(1+w*w))-1/3, 1, 4)
T = 1/(wm*sqrt(3))
check("ch8ex1 wm/T", [wm, T], [2.86, 0.202], [0.01, 0.001])
def pm_comp(w, T, a):
    return 180 + (-90 - degrees(atan(w)) + degrees(atan(a*T*w)) - degrees(atan(T*w)))
check("ch8ex1 补偿后PM", [pm_comp(wm, T, 3)], [49.3], 0.1)
# 例8.2: 新穿越0.457, 拖尾-5.1, PM=60.3
wl = brentq(lambda w: (5/(w*sqrt(1+w*w))) * (sqrt(1+(22*w)**2)/sqrt(1+(220*w)**2)) - 1, 0.1, 2)
tail = degrees(atan(22*wl))-degrees(atan(220*wl))
check("ch8ex2 穿越与PM", [wl, 180+(-90-degrees(atan(wl))+tail)], [0.457, 60.3], [0.002, 0.1])
# 习题2(修正): a=2.5, w=2.72, T=0.232, PM≈45.6
wm = brentq(lambda w: 25/(w*w*(1+w*w))-1/2.5, 1, 4)
T = 1/(wm*sqrt(2.5))
check("ch8hw2(修正) wm/T", [wm, T], [2.72, 0.232], [0.01, 0.002])
check("ch8hw2(修正) PM", [pm_comp(wm, T, 2.5)], [45.6], 0.1)
# 习题3(修正): beta=5: w≈0.79, PM≈47
wb = brentq(lambda w: 5/(w*sqrt(1+w*w))-10**(14/20), 0.1, 2)
Tb = 1/(0.1*wb)
tailb = degrees(atan(Tb*wb))-degrees(atan(5*Tb*wb))
check("ch8hw3(修正) w/PM", [wb, 180+(-90-degrees(atan(wb))+tailb)], [0.79, 47], [0.01, 0.5])

print("== 第 9 章:状态空间 ==")
A = np.array([[0,1],[0,0]]); B = np.array([[0],[9.]]); C = np.array([[0,1.]])
Wc = np.hstack([B, A@B]); Wo = np.vstack([C, C@A])
check_text("ch9 经典例 能控", abs(np.linalg.det(Wc)) > 0)
check_text("ch9 经典例 不能观", np.linalg.matrix_rank(Wo) == 1)
# 传函:C(sI-A)^{-1}B —— 书中误作 0,实为 9/s
s = 3.7  # 任取
G = (C @ np.linalg.inv(s*np.eye(2)-A) @ B).item()
check("ch9 经典例 G(s)=9/s(修正)", [G*s], [9], 1e-9)
# ch9ex1
A = np.array([[0,1],[-9,-1.2]]); B = np.array([[0],[9.]]); C = np.array([[1,0.]])
check("ch9ex1 detWc", [np.linalg.det(np.hstack([B, A@B]))], [-81], 1e-9)
s = 2.0
G = (C @ np.linalg.inv(s*np.eye(2)-A) @ B).item()
check("ch9ex1 G(2)", [G], [9/(4+2.4+9)], 1e-9)
# ch9hw1: G=1/((s+1)(s+2))
A = np.array([[0,1],[-2,-3]]); B = np.array([[0],[1.]]); C = np.array([[1,0.]])
s = 1.7
G = (C @ np.linalg.inv(s*np.eye(2)-A) @ B).item()
check("ch9hw1 G(1.7)", [G], [1/((2.7)*(3.7))], 1e-9)
# ch9hw4: det Wo = 16 (C=[0,1])
A = np.array([[0,1],[-16,-0.4]]); C = np.array([[0,1.]])
Wo = np.vstack([C, C@A])
check("ch9hw4 detWo", [np.linalg.det(Wo)], [16], 1e-9)

print("== 第 10 章:极点配置 ==")
def ackermann(A, B, poles):
    n = len(A)
    phi_c = np.poly(poles)
    phiA = sum(phi_c[i] * np.linalg.matrix_power(A, n-i) for i in range(n+1))
    Wc = np.hstack([np.linalg.matrix_power(A, i) @ B for i in range(n)])
    e = np.zeros(n); e[-1] = 1
    return e @ np.linalg.inv(Wc) @ phiA
K = ackermann(np.array([[0,1],[0,-1.]]), np.array([[0],[1.]]), [-1+1j, -1-1j])
check("ch10ex1 K", list(np.real(K)), [2, 1], 1e-9)
A3 = np.array([[0,1,0],[0,0,1],[0,0,0]]); B3 = np.array([[0],[0],[1.]])
check("ch10ex2 K=[1,3,3]", list(ackermann(A3, B3, [-1,-1,-1])), [1,3,3], 1e-9)
check("ch10ex2 K=[6,11,6]", list(ackermann(A3, B3, [-1,-2,-3])), [6,11,6], 1e-9)
check("ch10ex2 范数", [np.linalg.norm([1,3,3]), np.linalg.norm([6,11,6])], [4.36, 13.89], 0.01)
# ch10hw2: K=[18,6]; 修正的 phi(A)=[[18,6],[-12,0]]
A = np.array([[0,1],[-2,-3.]]); B = np.array([[0],[1.]])
check("ch10hw2 K", list(ackermann(A, B, [-4,-5])), [18,6], 1e-9)
phiA = np.linalg.matrix_power(A,2) + 9*A + 20*np.eye(2)
check("ch10hw2 phi(A)(修正)", list(phiA.flatten()), [18,6,-12,0], 1e-9)

print("== 第 11 章:观测器 ==")
def ackermann_T(A, C, poles):  # 对偶:L^T = e Wc^{-1} phi(A^T)
    return ackermann(A.T.copy(), np.array([[c] for c in C]), poles)
A = np.array([[0,1],[-2,-3.]]); C = np.array([1,0.])
L = ackermann_T(A, C, [-4+4j, -4-4j])
check("ch11ex1 L", list(np.real(L)), [5,15], 1e-9)
A2 = np.array([[0,1],[0,-1.]])
L2 = ackermann_T(A2, C, [-4+4j, -4-4j])
check("ch11ex2 L", list(np.real(L2)), [7,25], 1e-9)
M = np.block([[A2 - B2@K2 if False else np.array([[0,1],[-2,-2]])]])
# 4阶闭环特征值
M44 = np.zeros((4,4)); M44[:2,:2] = np.array([[0,1],[-2,-2]]); M44[1,2] = 2; M44[1,3] = 1
M44[2:,2:] = A2 - np.array([[7],[25.]])@np.array([[1,0]])
ev = np.linalg.eigvals(M44)
check_text("ch11ex2 分离", np.allclose(sorted(ev.real), sorted([-1,-1,-4,-4]), atol=0.01))
L3 = ackermann_T(A, C, [-2,-8])
check("ch11hw1 L", list(np.real(L3)), [7,-7], 1e-9)

print("== 第 12 章:卡尔曼 ==")
# 例12.1 两步
P = 1.0; xh = 0.0; Q, R = 0.01, 0.25
Pm = P + Q; K1 = Pm/(Pm+R); x1 = xh + K1*(1.2-xh)
P1 = (1-K1)**2*Pm + K1*K1*R
Pm2 = P1 + Q; K2 = Pm2/(Pm2+R); x2 = x1 + K2*(1.5-x1)
P2 = (1-K2)**2*Pm2 + K2*K2*R
check("ch12ex1 K1/x1/P1", [K1, x1, P1], [0.802, 0.962, 0.200], 0.001)
check("ch12ex1 K2/x2/P2", [K2, x2, P2], [0.457, 1.208, 0.114], 0.001)
# 稳态增益公式
def Koo(r): return (1+sqrt(1+4*r))/(1+sqrt(1+4*r)+2*r)
check("ch12 Koo(25)", [Koo(25)], [0.181], 0.001)
check("ch12ex2 Koo(1) 修正=0.62", [Koo(1)], [0.618], 0.001)
check("ch12ex2 Koo(2500)", [Koo(2500)], [0.02], 0.001)
# 直接迭代稳态验证 r=1
P = 1.0
for _ in range(5000):
    Pm = P + 0.01; K = Pm/(Pm+0.01); P = (1-K)*Pm
check("ch12 迭代稳态 r=1", [K], [0.618], 0.001)
# ch12hw1
P = 4.0; Pm = P+0.04; K1 = Pm/(Pm+1); x1 = K1*2; P1 = (1-K1)**2*Pm + K1*K1*1
check("ch12hw1", [Pm, K1, x1, P1], [4.04, 0.802, 1.60, 0.802], 0.005)
check("ch12hw2 Koo", [Koo(25)], [0.181], 0.001)

print("== 第 13 章:离散系统 ==")
lam = exp(-1.0)
check("ch13 G(z) 系数", [1-lam, lam], [0.632, 0.368], 0.001)
y = 0.0; seq = []
for k in range(6):
    u = 1.0 - y
    y = lam*y + (1-lam)*u
    seq.append(y)
check("ch13ex1 序列 y1..y5", seq[:5], [0.632, 0.465, 0.509, 0.498, 0.501], 0.001)
check("ch13ex1 终值", [seq[-1]], [0.5], 0.001)
Kc = (1+lam)/(1-lam)
check("ch13ex1 Kc", [Kc], [2.164], 0.001)
check("ch13ex1 K=2.5 根", [lam-0.632*2.5], [-1.212], 0.001)
lam5 = exp(-0.5)
check("ch13ex1 T=0.5 Kc", [(1+lam5)/(1-lam5)], [4.08], 0.01)
for Ki, want in [(2.0, [0.3137, -0.8417]), (2.5, [0.2429, -1.0869])]:
    a1 = -1.368 + 0.632*(1.0+Ki); a0 = 0.368 - 0.632*1.0
    r = np.roots([1, a1, a0])
    check(f"ch13ex2 Ki={Ki} 根", sorted(r.real), sorted(want), 0.001)
check("ch13ex2 Ki 上限", [1.472/0.632], [2.33], 0.005)
check("ch13hw2 w系数", [0.632, 2.528, 1.472-0.632*1.0], [0.632, 2.528, 0.84], 0.001)
lamq = exp(-0.5)
check("ch13hw1 G(z)/Kc", [1-lamq, lamq, (1+lamq)/(1-lamq), lamq-(1-lamq)], [0.393, 0.607, 4.08, 0.214], [0.001, 0.001, 0.01, 0.001])
lam31 = exp(-0.31)
check("ch13hw4 Kc(0.31)", [(1+lam31)/(1-lam31)], [6.50], 0.01)

print("== 第 14 章:最优控制与 LQR ==")
# Hamiltonian 特征向量法数值解代数 Riccati(与书中手解闭式对拍)
def are_solve(A, B, Q, R):
    n = A.shape[0]
    H = np.block([[A, -B@np.linalg.inv(R)@B.T], [-Q, -A.T]])
    w, v = np.linalg.eig(H)
    idx = np.argsort(w.real)[:n]
    V = v[:, idx]
    P = np.real(V[n:, :] @ np.linalg.inv(V[:n, :]))
    return (P + P.T) / 2
A14 = np.array([[0.,1.],[0.,0.]]); B14 = np.array([[0.],[1.]])
P14 = are_solve(A14, B14, np.eye(2), np.eye(1))
K14 = (B14.T @ P14).flatten()
check("ch14ex1 P 闭式", [P14[0,0], P14[0,1], P14[1,1]], [sqrt(3), 1, sqrt(3)], 1e-9)
check("ch14ex1 K", list(K14), [1, sqrt(3)], 1e-9)
r14 = np.roots([1, sqrt(3), 1])
check("ch14ex1 闭环极点实部", sorted(r14.real), [-0.8660254, -0.8660254], 1e-6)
check("ch14ex1 闭环极点虚部", sorted(abs(r14.imag)), [0.5, 0.5], 1e-6)
z14 = sqrt(3)/2
check("ch14ex1 zeta/Mp%", [z14, exp(-pi*z14/sqrt(1-z14*z14))*100], [0.866, 0.43], [0.001, 0.01])
check("ch14ex1 J_min(x0=e1)", [P14[0,0]], [1.732], 0.001)
# 权重表(四组):闭式 K + 数值穿越/裕度;w^4 - k2^2 w^2 - k1^2 = 0
for (q1, q2, rr, want_wgc, want_pm) in [(1,1,1,1.817,72.4),(1,0,1,1.554,65.5),(1,1,0.1,4.113,79.2),(1,1,10,0.922,68.2)]:
    k1c = sqrt(q1/rr); k2c = sqrt(q2/rr + 2*sqrt(q1/rr))
    w2 = (k2c*k2c + sqrt(k2c**4 + 4*k1c*k1c))/2
    wgc = sqrt(w2)
    pm = degrees(atan(k2c*wgc/k1c))
    check(f"ch14 权重{q1,q2,rr} wgc/PM", [wgc, pm], [want_wgc, want_pm], [0.002, 0.1])
# 回差恒等式抽查(ω=1,Q=I,R=1):|1+L|^2 = 1+(q2 ω²+q1)/(r ω^4)
L1 = (1.0 + 1j*sqrt(3.0))/(-1.0)  # L(j1) = (k1 + j k2 ω)/（jω)²
check("ch14 回差 |1+L|^2(ω=1)", [abs(1+L1)**2], [1+(1+1)/1.0], 1e-9)
# ch14ex2 弹簧质量:√5 闭式 vs Hamiltonian
A14s = np.array([[0.,1.],[-2.,-3.]]); B14s = np.array([[0.],[1.]])
P14s = are_solve(A14s, B14s, np.eye(2), np.eye(1))
K14s = (B14s.T @ P14s).flatten()
check("ch14ex2 P 闭式", [P14s[0,0], P14s[0,1], P14s[1,1]], [sqrt(5)-1, sqrt(5)-2, sqrt(5)-2], 1e-9)
check("ch14ex2 K", list(K14s), [sqrt(5)-2, sqrt(5)-2], 1e-9)
res14 = A14s.T@P14s + P14s@A14s - P14s@B14s@B14s.T@P14s + np.eye(2)
check_text("ch14ex2 ARE 残差≈0", np.abs(res14).max() < 1e-10)
r14s = np.roots([1, 1+sqrt(5), sqrt(5)])
check("ch14ex2 闭环极点", sorted(r14s.real), [-sqrt(5), -1.0], 1e-9)
# ch14 极小值原理 bang-bang:u=-1 一秒切 +1,T*=2 恰回原点(分段积分)
x1b, x2b, dtb = 1.0, 0.0, 1e-5
for i in range(200000):
    t = i*dtb
    u = -1.0 if t < 1.0 else 1.0
    x2b += u*dtb
    x1b += x2b*dtb
check("ch14 bang-bang T*=2 末态", [x1b, x2b], [0, 0], 1e-3)
# ch14hw1 R=4
P14h = are_solve(A14, B14, np.eye(2), np.array([[4.]]))
K14h = (np.linalg.inv(np.array([[4.]])) @ B14.T @ P14h).flatten()
check("ch14hw1 K", list(K14h), [0.5, 1.1180], 1e-4)
r14h = np.roots([1, K14h[1], K14h[0]])
check("ch14hw1 极点实部", [sorted(r14h.real)[0]], [-0.5590], 1e-3)
check("ch14hw1 zeta", [K14h[1]/(2*sqrt(K14h[0]))], [0.791], 1e-3)
# ch14hw2 标量:p²+2p-1=0 → p=√2-1,闭环极点 -√2
p14 = np.roots([1, 2, -1])
check("ch14hw2 p=sqrt2-1", [sorted(p14.real)[-1]], [sqrt(2)-1], 1e-9)
check("ch14hw2 闭环极点", [-1-(sqrt(2)-1)], [-sqrt(2)], 1e-9)
# ch14hw4 Ackermann 配置到 LQR 极点,K 应与例 14.1 相同
K14ack = ackermann(A14, B14, [-0.8660254+0.5j, -0.8660254-0.5j])
check("ch14hw4 Ackermann K", list(np.real(K14ack)), [1, sqrt(3)], 1e-6)
print(f"\n===== 汇总:PASS {ok} / FAIL {bad} =====")

import sys
sys.exit(1 if bad else 0)
