//+------------------------------------------------------------------+
//|                                                         MACD.mq4 |
//|                                Copyright © 2005, David W. Thomas |
//|                                           mailto:davidwt@usa.net |
//+------------------------------------------------------------------+
// This is the correct computation and display of MACD.
#property copyright "Copyright © 2005, David W. Thomas"
#property link      "mailto:davidwt@usa.net"

//---- Changes - SwingMan - 2010.02.18

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 C'51,155,98;'
#property indicator_color2 C'239,71,105;'
#property indicator_color3 C'0,150,0;' // Green
#property indicator_color4 C'237,61,96;' // Red

#property indicator_style2 STYLE_SOLID
#property indicator_width3 2
#property indicator_width4 2
#property indicator_level1 0

//---- input parameters
extern int       FastMAPeriod=5;
extern int       SlowMAPeriod=15;
extern int       SignalMAPeriod=9;

//---- buffers
double MACDLineBuffer[];
double SignalLineBuffer[];
double HistogramBufferUP[],HistogramBufferDN[];

//---- variables
double alpha = 0;
double alpha_1 = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
   //---- indicators
   
   SetIndexBuffer(0,MACDLineBuffer); SetIndexStyle(0,DRAW_LINE); SetIndexDrawBegin(0,SlowMAPeriod);
   SetIndexBuffer(1,SignalLineBuffer); SetIndexStyle(1,DRAW_LINE,STYLE_SOLID); SetIndexDrawBegin(1,SlowMAPeriod+SignalMAPeriod);   
   SetIndexBuffer(2,HistogramBufferUP); SetIndexStyle(2,DRAW_HISTOGRAM); SetIndexDrawBegin(2,SlowMAPeriod+SignalMAPeriod);
   SetIndexBuffer(3,HistogramBufferDN); SetIndexStyle(3,DRAW_HISTOGRAM); SetIndexDrawBegin(3,SlowMAPeriod+SignalMAPeriod);
   
   //---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD");
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
   SetIndexLabel(2,"Trend UP");
   SetIndexLabel(3,"Trend DN");
   //----
	alpha = 2.0 / (SignalMAPeriod + 1.0);
	alpha_1 = 1.0 - alpha;
   //----
   return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   //---- 
   
   //----
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int limit;
   int counted_bars = IndicatorCounted();
   //---- check for possible errors
   if (counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if (counted_bars>0) counted_bars--;
   limit = Bars - counted_bars;

   for(int i=limit; i>=0; i--)
   {
      MACDLineBuffer[i] = iMA(NULL,0,FastMAPeriod,0,MODE_EMA,PRICE_CLOSE,i) - iMA(NULL,0,SlowMAPeriod,0,MODE_EMA,PRICE_CLOSE,i);
      SignalLineBuffer[i] = alpha*MACDLineBuffer[i] + alpha_1*SignalLineBuffer[i+1];
      
      //---- MACD
      double diff = MACDLineBuffer[i] - SignalLineBuffer[i];
      if (diff>=0)
      {
         HistogramBufferUP[i] = diff;
         HistogramBufferDN[i] = EMPTY_VALUE;
      }
      else
      {
         HistogramBufferUP[i] = EMPTY_VALUE;
         HistogramBufferDN[i] = diff;
      }
      
      //---- MACD previous bar
      double diff1 = MACDLineBuffer[i+1] - SignalLineBuffer[i+1];
      if (diff1>=0)
      {
         HistogramBufferUP[i+1] = diff1;
         HistogramBufferDN[i+1] = EMPTY_VALUE;
      }
      else
      {
         HistogramBufferUP[i+1] = EMPTY_VALUE;
         HistogramBufferDN[i+1] = diff1;
      }
   }
   
   //----
   return(0);
}
//+------------------------------------------------------------------+