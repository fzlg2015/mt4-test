# mt4-test

MT4 / MQL4 仓库。**本机 MT4 的安装目录就是本仓库的 git 工作区**：改这里的文件 = 改仓库文件，没有"复制同步"这一步。远端：`https://github.com/fzlg2015/mt4-test`

**第一个指标**：`MQL4/Indicators/SimpleMA.mq4` —— 最简单的一根 20 周期 SMA 均线，画在主图上，周期可在指标属性里改。

## 一、工作方式（2026-11-16 起）

本机目录 `D:\Program Files\MetaTrader 4\` 已初始化为 git 工作区，远端即本仓库，历史连续（`cc06c67` 起）。

- **跟踪范围**：只有 `MQL4/`、`README.md`、`.gitignore`。`terminal.exe`（34 MB）、`metaeditor.exe`（16 MB）、`config/`、`logs/`、`templates/`、`tester/`、`history/`、`profiles/` 全部不跟踪，见 `.gitignore` 的白名单写法。
- **零复制**：MT4 读的文件就是 git 管的文件。改完直接提交，不存在"拷进仓库"的环节。
- **日常三步**：在 MT4 / MetaEditor 里改 → `git add -A` → `git commit -m "说明"` → `git push`。
- **日志不跟踪**：`MQL4/Logs/`、`*.log`、`*.bak`、`*.tmp` 均在忽略列表内。
- **另一台机器 / 服务器**：`git clone` 或 `git pull`，再把 `MQL4/` 覆盖到那台机器的数据文件夹即可直接使用（`.ex4` 已入库，不必先装 MetaEditor 编译）。

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
2. MetaEditor 里 **F7** 编译，同目录生成 `.ex4`。或用命令行：`metaeditor.exe /compile:"路径\X.mq4" /log`，**别信退出码，看 `.log` 里的 `Result: 0 errors`**。
3. MT4 导航器 →「自定义指标」右键 **刷新** → 拖到图表验证效果。
4. `git add -A && git commit -m "..." && git push`。

## 五、当前状态与约定

- 本机 MT4：便携模式，`build 1440`，程序与数据都在 `D:\Program Files\MetaTrader 4\`，C 盘零写入。
- `.ex4` **已纳入版本库**（2026-11-16 起）：目的是服务器/另一台机器 pull 下来即可用，不必先编译。想回到"只存源码"，在 `.gitignore` 里重新放开 `*.ex4`。
- 改代码留干净 commit，随时能 `git revert`。
- 仓库是 **public**；`MQL4/Include` 里的 `.mqh` 标准库、`bmp` 资源、多数示例 EA/指标均为 MetaQuotes 随终端自带的官方文件。以后放真实交易策略（EA）建议先转私有或另建私有仓库。

## 六、仓库

`https://github.com/fzlg2015/mt4-test`
