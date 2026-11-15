//+------------------------------------------------------------------+
//|                                                    SimpleMA.mq4  |
//|                    MT4 测试：最简单的一根均线（SMA）              |
//|                    fzlg2015 / mt4-test                            |
//+------------------------------------------------------------------+
//  说明：这是「能编译、能挂图、能画一根线」的最小完整指标。
//  均线值直接调用 MT4 内置 iMA() 算，等价于系统自带的 Moving Average。
//  想自己算的话，把 iMA 那一行换成对 close[] 的 N 根累加求平均即可。
//+------------------------------------------------------------------+
#property copyright "fzlg2015"
#property link      "https://github.com/fzlg2015/mt4-test"
#property version   "1.00"
#property description "最简单的一根均线：对收盘价做 N 周期简单移动平均（SMA），画在主图上"
#property strict

//--- 画在主图（价格窗口）：1 个数据缓冲区、1 条线
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "SimpleMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- 输入参数：在指标属性窗口里可以直接改，不用改代码
input int InpMAPeriod = 20;   // 均线周期（默认 20）

//--- 指标缓冲区：每根 K 线存一个均线值
double MaBuffer[];

//+------------------------------------------------------------------+
//| 初始化：绑定缓冲区，指定从第几根 K 线开始画                      |
//+------------------------------------------------------------------+
int OnInit()
{
   if(InpMAPeriod < 1)
   {
      Print("SimpleMA：均线周期必须 >= 1");
      return(INIT_PARAMETERS_INCORRECT);
   }

   SetIndexBuffer(0, MaBuffer, INDICATOR_DATA);
   ArraySetAsSeries(MaBuffer, true);                       // 0 号 = 当前 K 线
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpMAPeriod - 1);  // 前 N-1 根数据不够，不画

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| 每次行情更新时计算：把内置 iMA 的值填进缓冲区                   |
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
   if(rates_total < InpMAPeriod)
      return(0);                                  // K 线还不够，暂时不画

   // 首次从第 N-1 根开始；之后只重算最后一根（它还在变动）
   int start = (prev_calculated > 0) ? prev_calculated - 1 : InpMAPeriod - 1;

   for(int i = start; i < rates_total && !IsStopped(); i++)
   {
      // 最后一个参数 shift：0 = 当前 K 线，与缓冲区索引方向一致
      MaBuffer[i] = iMA(NULL, 0, InpMAPeriod, 0, MODE_SMA, PRICE_CLOSE, i);
   }

   return(rates_total);                           // 下次从 prev_calculated-1 继续
}
//+------------------------------------------------------------------+
