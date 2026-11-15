# mt4-test

MT4 / MQL4 测试仓库。目录结构照 MetaQuotes 官方 `<data_folder>\MQL4\` 原样建，以后写 EA、指标、脚本，直接往对应文件夹放就行。

**第一个指标**：`MQL4/Indicators/SimpleMA.mq4` —— 最简单的一根 20 周期 SMA 均线，画在主图上，周期可在指标属性里改。

## 一、指标到底该放哪个文件夹

官方规定：自定义指标（源码 `.mq4` + 编译产物 `.ex4`）一律放在 `<data_folder>\MQL4\Indicators\`。
MT4 导航器里的「自定义指标」只列出这个目录里的 `.ex4`，**没编译出 .ex4 就看不到、也挂不上图**。

`<data_folder>` 怎么找：MT4 菜单「文件 → 打开数据文件夹」，或 MetaEditor 里 `File → Open Data Folder`。
注意：Windows 开了 UAC 时它通常在 `%APPDATA%\MetaQuotes\Terminal\<一长串实例ID>\`，**不是** MT4 的安装目录。

## 二、标准子目录（官方原样）

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

## 三、部署到 MT4 的步骤

1. MT4 里「文件 → 打开数据文件夹」，找到那个 `MQL4\`。
2. 把本仓库 `MQL4\Indicators\SimpleMA.mq4` 拷到数据文件夹的 `MQL4\Indicators\`。
3. MetaEditor 打开它 → 按 **F7** 编译，同目录生成 `SimpleMA.ex4`。
4. 回到 MT4 导航器 →「自定义指标」右键 **刷新** → 把 `SimpleMA` 拖到图表，弹出参数窗口可改周期。

适用 MT4 build 600 及以上（现在流通的 MT4 都是）。

## 四、当前状态与约定

- 这台 i7 **没有安装 MT4 / MetaEditor**，因此本仓库里的 `.mq4` 只做了静态检查，**没有实际编译出 .ex4**。到你那台装了 MT4 的机器上 F7 编译一次即可（正常应 0 errors / 0 warnings）。
- `.gitignore` 目前排除 `*.ex4` 编译产物和日志：源码进 git、可 diff、可回退。以后若服务器不方便编译、需要直接拉 `.ex4`，把这行删掉即可。
- 改代码留干净 commit，随时能 `git revert`。
- 仓库是 **public**；以后要放真实交易策略（EA），建议先转私有或另建私有仓库。

## 五、仓库

`https://github.com/fzlg2015/mt4-test`
