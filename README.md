# mt4-test

MT4 / MQL4 仓库。**本机 MT4 的安装目录就是本仓库的 git 工作区**：改这里的文件 = 改仓库文件，没有"复制同步"这一步。远端：`https://github.com/fzlg2015/mt4-test`

**第一个指标**：`MQL4/Indicators/SimpleMA.mq4` —— 最简单的一根 20 周期 SMA 均线，画在主图上，周期可在指标属性里改。

## 一、工作方式（2026-11-16 起）

本机目录 `D:\Program Files\MetaTrader 4\` 已初始化为 git 工作区，远端即本仓库，历史连续（`cc06c67` 起）。

- **跟踪范围**：只有 `MQL4/`、`README.md`、`.gitignore`，且 **只存源码与原文件**。`terminal.exe`（34 MB）、`metaeditor.exe`（16 MB）、`config/`、`logs/`、`templates/`、`tester/`、`history/`、`profiles/` 全部不跟踪，见 `.gitignore` 的白名单写法。
- **产物不进库**：`*.ex4`、`*.ex5`、`mqlcache.dat`、`*.dat` 一律忽略——它们是本机编译/运行生成的，谁拉下来谁自己编译。仓库里只有 `.mq4` 源码、`.mqh` 头文件、`.bmp` 资源，以及 **`.dll` 保留入库**（见下方说明）。
- **零复制**：MT4 读的文件就是 git 管的文件。改完直接提交，不存在"拷进仓库"的环节。
- **日常三步**：在 MT4 / MetaEditor 里改 → `git add -A` → `git commit -m "说明"` → `git push`。
- **日志不跟踪**：`MQL4/Logs/`、`*.log`、`*.bak`、`*.tmp` 均在忽略列表内。
- **另一台机器 / 服务器**：`git clone` 或 `git pull`，把 `MQL4/` 覆盖到那台机器的数据文件夹，然后**在那边 F7 或命令行编译一次**——仓库只给源码，`.ex4` 得在目标机自己生成（`.ex4` 与机器、与 build 版本相关，跨机拷过去反而可能不被识别）。

## 二、指标到底该放哪个文件夹

官方规定：自定义指标（源码 `.mq4` + 编译产物 `.ex4`）一律放在 `<data_folder>\MQL4\Indicators\`。
MT4 导航器里的「自定义指标」只列出这个目录里的 `.ex4`，**没编译出 .ex4 就看不到、也挂不上图**。

`<data_folder>` 怎么找：MT4 菜单「文件 → 打开数据文件夹」，或 MetaEditor 里 `File → Open Data Folder`。
注意：Windows 开了 UAC 且非便携模式时，它通常在 `%APPDATA%\MetaQuotes\Terminal\<一长串实例ID>\`，**不是** MT4 的安装目录。
本机用的是 **便携模式**（`terminal.exe /portable`），所以数据目录就是安装目录 `D:\Program Files\MetaTrader 4\`，与仓库完全重合。

## 三、标准子目录（官方原样）

| 文件夹 | 放什么 |
|---|---|
| `MQL4/Experts` | EA 自动交易程序（.mq4 / .ex4） |
| `MQL4/Indicators` | 自定义指标 ← 本次指标在这里 |
| `MQL4/Scripts` | 脚本，在图表上跑一次就结束 |
| `MQL4/Include` | 公共头文件 `.mqh`，被 `#include` 引用 |
| `MQL4/Libraries` | 库（.mq4 / .ex4），供别的程序动态调用 |
| `MQL4/Files` | 文件沙箱，MQL4 程序只允许在这个目录读写文件 |
| `MQL4/Images` | 图片资源 |
| `MQL4/Logs` | 运行日志（终端自动生成，不进版本库） |
| `MQL4/Presets` | EA 参数预设 `.set` |

官方依据：
- https://docs.mql4.com/mql4changes （新版 MQL4 文件结构，明确 MetaEditor 根目录就是 `\MQL4\`）
- https://www.metatrader4.com/en/trading-platform/help/userguide/start_comm （数据文件夹迁移对照表，含 Logs / Presets / Images）
- https://docs.mql4.com/cn （Experts / Indicators / Scripts / Libraries / Include 各自用途）
- https://www.metatrader4.com/en/trading-platform/help/overview/navigator （导航器只显示 `.ex4`，拷入后需「刷新」）

## 四、在本机写一个指标并上线

1. 在 `MQL4\Indicators\` 里新建/修改 `.mq4`（UTF-8 **带 BOM**，中文注释才不乱码）。
2. MetaEditor 里 **F7** 编译，同目录生成 `.ex4`。
3. MT4 导航器 →「自定义指标」右键 **刷新** → 拖到图表验证效果。
4. `git add -A && git commit -m "..." && git push`。

### 命令行编译（本机实测有效的写法）

```bat
cd /d "D:\Program Files\MetaTrader 4"
metaeditor.exe "/compile:D:\PROGRA~1\METATR~1\MQL4\Indicators\X.mq4" /log
```

三条实测结论，缺一个就拿不到结果：

- **路径必须用 8.3 短名**。写 `D:\Program Files\...` 这种带空格的绝对路径，或写相对路径，`/log` 都**静默不生成日志**，只能靠产物时间戳猜；用短名（`PROGRA~1`、`METATR~1`）才正常输出。
- **日志是同目录同名 `.log`，UTF-16 编码**，内容形如 `Result: 0 errors, 0 warnings, 134 msec elapsed`。
- **退出码不可信**：编译成功也可能是 `1`；反过来，语法错误时**不会产出 `.ex4`**——产物没更新才是最硬的失败信号。
- 编译失败时 `*.log` 里带行号（如 `'int bad = ;' - expression expected`），照行号改即可。

拿到本机短路径的方法：对目录执行 `GetShortPathNameW`（本机为 `D:\PROGRA~1\METATR~1`）。

### 为什么 `.ex4` 不进版本库，但 `.dll` 要进

`.ex4` 是纯编译产物：内含时间戳，**同一份源码编译两次字节都不同**，且与机器、与终端 build 版本相关。把它塞进 git 只会让每次提交都多出一堆无意义的二进制 diff，改坏了也看不出改在哪。约定：**仓库只存源码（`.mq4` / `.mqh`）**，`.ex4` 由每台机器自己编译生成，已被 `.gitignore` 排除。

`.dll` 相反，**保留入库**（2026-11-16 定）。理由：

- 它是 **MQL4 运行时的依赖**，`#import` 不到就直接报 `cannot load dll`，程序根本跑不起来；
- 没有源码的第三方 dll，一旦本地丢了就**再也补不回来**，而 `.ex4` 随时能重新编译；
- 体积很小（本仓库唯一的一个 `DLLSample.dll` 仅 105 KB），进库成本可以忽略。

判断口径：**能重新生成的（`.ex4`）不进库，不能重新生成的（第三方 `.dll`）必须进库。** 有源码的 dll（如 `DLLSample.cpp` + `.vcxproj`）能重编，但为省事也一并保留二进制。

### DLL 的两个实操坑

- **位数**：MT4 是 32 位程序，只加载 x86 的 dll，64 位的 `BadImageFormatException` 一律不认。
- **依赖**：目标机若缺对应版本的 Visual C++ 运行库，会加载失败且报错含糊——换机器跑 EA 时优先怀疑这个。

### 自建指标清单（`MQL4\Indicators\任意周期\`）

同系列指标统一放这个子目录，文件名以「任意周期」开头，MT4 导航器里显示为「自定义指标 → 任意周期 → xxx」。

| 文件 | 作用 | 参数 |
|---|---|---|
| `任意周期中轴线.mq4` | 画一条横贯全图的水平线，值 = **所选周期上一根 K 线**的 `(最高价 + 最低价) / 2`。选日线就是昨天的中轴，选周线就是上周的中轴 | `InpTF` 周期下拉（M1/M5/M15/M30/H1/H4/D1/W1/MN1，默认日线）、`InpColor` 线色、`InpWidth` 线宽、`InpDebug` 日志开关 |

实现要点：`iHigh(NULL, tf, 1)` / `iLow(NULL, tf, 1)` 取所选周期的上一根（`shift=0` 是正在走的那根，不能用）；每根 bar 填同一个值，于是画成水平线；该周期无数据时 `iHigh` 返回 0（官方明确行为），此时判定无效、不画线，不会画出 0 价位的假线。

## 五、当前状态与约定

- 本机 MT4：便携模式，`build 1440`，程序与数据都在 `D:\Program Files\MetaTrader 4\`，C 盘零写入。
- **产物排除、依赖保留**（2026-11-16 定）：`.ex4`、`mqlcache.dat` 已从版本库移除并加入忽略列表；**`.dll` 保留入库**（`MQL4/Scripts/Examples/DLL/Libraries/DLLSample.dll`，105 KB）。本地产物文件全部保留，MT4 照常使用。跟踪文件 191 → 158。
- 改代码留干净 commit，随时能 `git revert`。
- 仓库是 **public**；`MQL4/Include` 里的 `.mqh` 标准库、`bmp` 资源、多数示例 EA/指标均为 MetaQuotes 随终端自带的官方文件。以后放真实交易策略（EA）建议先转私有或另建私有仓库。

## 六、仓库

`https://github.com/fzlg2015/mt4-test`
