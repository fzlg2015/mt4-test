//+------------------------------------------------------------------+
//|                                           任意周期中轴线.mq4      |
//| 作用：在图上画一条水平线 = 所选周期「上一根 K 线」的              |
//|       (最高价 + 最低价) / 2                                       |
//| 例：选「日线」，画的就是昨天的 (最高+最低)/2                      |
//|     选「周线」，画的就是上周的 (最高+最低)/2                      |
//| 放在：MQL4\Indicators\任意周期\                                   |
//+------------------------------------------------------------------+
#property copyright "fzlg2015"
#property version   "1.00"
#property strict

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

#property indicator_label1  "中轴线"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGold
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- 周期下拉列表：只列常用 9 个，避免 M2/M3 之类一长串干扰选择
enum ENUM_ANY_TF
  {
   ANYTF_M1  = 1,      // 1 分钟
   ANYTF_M5  = 5,      // 5 分钟
   ANYTF_M15 = 15,     // 15 分钟
   ANYTF_M30 = 30,     // 30 分钟
   ANYTF_H1  = 60,     // 1 小时
   ANYTF_H4  = 240,    // 4 小时
   ANYTF_D1  = 1440,   // 日线
   ANYTF_W1  = 10080,  // 周线
   ANYTF_MN1 = 43200   // 月线
  };

//--- 用户可调参数
input ENUM_ANY_TF InpTF    = ANYTF_D1;   // 取哪个周期的上一根
input color       InpColor = clrGold;    // 线的颜色
input int         InpWidth = 1;          // 线的粗细（1-5）
input bool        InpDebug = false;      // 打印调试信息（只在日志里，图上无影响）

//--- 指标缓冲区
double MidBuf[];

//+------------------------------------------------------------------+
//| 把下拉选项转成 MQL4 的周期常量                                    |
//+------------------------------------------------------------------+
int TfFromEnum(ENUM_ANY_TF tf)
  {
   switch(tf)
     {
      case ANYTF_M1:  return(PERIOD_M1);
      case ANYTF_M5:  return(PERIOD_M5);
      case ANYTF_M15: return(PERIOD_M15);
      case ANYTF_M30: return(PERIOD_M30);
      case ANYTF_H1:  return(PERIOD_H1);
      case ANYTF_H4:  return(PERIOD_H4);
      case ANYTF_D1:  return(PERIOD_D1);
      case ANYTF_W1:  return(PERIOD_W1);
      case ANYTF_MN1: return(PERIOD_MN1);
     }
   return(PERIOD_D1);
  }

//+------------------------------------------------------------------+
//| 周期名字（显示在指标名后面）                                       |
//+------------------------------------------------------------------+
string TfName(ENUM_ANY_TF tf)
  {
   switch(tf)
     {
      case ANYTF_M1:  return("M1");
      case ANYTF_M5:  return("M5");
      case ANYTF_M15: return("M15");
      case ANYTF_M30: return("M30");
      case ANYTF_H1:  return("H1");
      case ANYTF_H4:  return("H4");
      case ANYTF_D1:  return("D1");
      case ANYTF_W1:  return("W1");
      case ANYTF_MN1: return("MN1");
     }
   return("D1");
  }

//+------------------------------------------------------------------+
//| 初始化                                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, MidBuf);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, InpWidth, InpColor);
   SetIndexEmptyValue(0, EMPTY_VALUE);

   // 每根 K 线都填同一个值 = 横贯全图的水平线，所以从第 0 根就画
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 0);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   IndicatorShortName("任意周期中轴线(" + TfName(InpTF) + ")");

   if(InpDebug)
      PrintFormat("[中轴线] 初始化：所选周期=%s(%d)，图表周期=%d",
                  TfName(InpTF), (int)InpTF, (int)Period());

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| 卸载：无自建对象，无需清理                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(InpDebug)
      PrintFormat("[中轴线] 卸载，原因码=%d", reason);
  }

//+------------------------------------------------------------------+
//| 主计算                                                            |
//| 说明：中轴线随所选周期的「新一根」K 线变化，因此每次都全量重填，   |
//|       不做 prev_calculated 增量优化（否则会长期停在旧值）。       |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- 数据还没加载完，先返回 0，下次再来
   if(rates_total <= 0)
      return(0);

   int tf = TfFromEnum(InpTF);

//--- 取所选周期的「上一根」K 线（shift=1；shift=0 是正在走的那根）
   double h = iHigh(NULL, tf, 1);
   double l = iLow(NULL, tf, 1);

//--- 有效性校验：该周期没数据时 iHigh/iLow 返回 0，此时不画线
//    （不算错误，只是那个周期还没取到数据，图上是空白）
   bool ok = (h > 0.0 && l > 0.0 && h >= l);
   double mid = ok ? (h + l) / 2.0 : EMPTY_VALUE;

//--- 全量填充
   int n = ArraySize(MidBuf);
   if(n < rates_total)
      return(0);
   for(int i = 0; i < rates_total; i++)
      MidBuf[i] = mid;

//--- 调试输出（只在首轮或周期切换时打一条，避免刷屏）
   if(InpDebug && prev_calculated == 0)
      PrintFormat("[中轴线] bars=%d 周期=%s 上一根 H=%.5f L=%.5f 中轴=%.5f 有效=%s",
                  rates_total, TfName(InpTF), h, l, ok ? mid : 0.0,
                  ok ? "是" : "否（该周期暂无数据）");

   return(rates_total);
  }
//+------------------------------------------------------------------+
