//+------------------------------------------------------------------+
//|                                                          CII.mq4 |
//|     From http://www.fxcodebase.com/code/viewtopic.php?f=27&t=258 |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Gold
#property indicator_color3 Lime

//
//
//
//
//

extern int  RSI.Price       = PRICE_CLOSE;
extern int  RSI.SlowLength  = 14;
extern int  RSI.FastLength  =  3;
extern int  Momentum.Length =  9;
extern int  SMA.Length1     =  3;
extern int  SMA.Length2     = 13;
extern int  SMA.Length3     = 33;

//
//
//
//
//

double buffer1[];
double buffer2[];
double buffer3[];
double working[][3];

//+----------------------------------------------------------------------------------+
//|                                                                                  |
//+----------------------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   SetIndexBuffer(0,buffer1);
   SetIndexBuffer(1,buffer2);
   SetIndexBuffer(2,buffer3);
   return(0);
}
int deinit()
{
   return(0);
}

//+----------------------------------------------------------------------------------+
//|                                                                                  |
//+----------------------------------------------------------------------------------+
//
//
//
//
//

#define __slowRSI 0
#define __fastRSI 1
#define __composite 2

//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,r,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = Bars-counted_bars;
         if (ArrayRange(working,0) != Bars) ArrayResize(working,Bars);

   //
   //
   //
   //
   //
        
   for(i=limit, r=Bars-i-1; i >= 0; i--,r++)
   {
      working[r][__slowRSI] = iRSI(NULL,0,RSI.SlowLength,RSI.Price,i);
      working[r][__fastRSI] = iRSI(NULL,0,RSI.FastLength,RSI.Price,i);
      
         double RSIDelta = working[r][__slowRSI]-working[r-Momentum.Length][__slowRSI];
         double RSIsma   = iSma(__fastRSI,SMA.Length1,r);
         
      working[r][__composite] = RSIDelta+RSIsma;
      
      //
      //
      //
      //
      //
      
      buffer1[i] = working[r][__composite];
      buffer2[i] = iSma(__composite,SMA.Length2,r);
      buffer3[i] = iSma(__composite,SMA.Length3,r);
   }
   return(0);
}

//+----------------------------------------------------------------------------------+
//|                                                                                  |
//+----------------------------------------------------------------------------------+
//
//
//
//
//

double iSma(int forBuffer,int period, int shift)
{
   double sum   =0;
   
   if (shift>=period)
   {
      for (int i=0; i<period; i++) sum += working[shift-i][forBuffer];
      return(sum/period);
   }
   else return(working[shift][forBuffer]);
}