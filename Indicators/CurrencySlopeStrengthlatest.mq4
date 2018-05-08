//+------------------------------------------------------------------+
//|                                        CurrencySlopeStrength.mq4 |
//|                      Copyright 2012, Deltabron - Paul Geirnaerdt |
//|                                          http://www.deltabron.nl |
//+------------------------------------------------------------------+
//
// Parts based on CCFp.mq4, downloaded from mql4.com
// TMA Calculations © 2012 by ZZNBRM
//
#property copyright "Copyright 2012, Deltabron - Paul Geirnaerdt"
#property link      "http://www.deltabron.nl"
//----
#property indicator_separate_window
#property indicator_buffers 8

#define version            "v1.0.2"

//+------------------------------------------------------------------+
//| Release Notes                                                    |
//+------------------------------------------------------------------+
// v1.0.0 (alpha), 6/1/12
// * Added support to auto create symbolnames
// * Added 'maxBars' setting to limit number of history bars calculated and improve performance
// v1.0.0, 6/4/12
// * BUG: added (almost) unique identifier for objects to get multiple instances in one window (thanks, Verb)
// * New default for user setting 'symbolsToWeigh', it now has all symbols that the NanningBob 10.2 system looks at
// v1.0.1, 6/11/12
// * Added a alert for crosses of the Currency Slope Strength
// * Added user settings for the colo(u)r of weak, normal and strong cross alerts.
// * Added user setting 'autoTimeFrame' to use timeframe on chart. If set to false setting 'timeFrame' is used.
// * User can now set all timeframes.
// v1.0.2, 6/12/12
// * Added option to disable so-called 'repainting', that is not to consider future bars for any calculation
// * Changed indicator short name
// * Code optimization

#define EPSILON            0.00000001

#define CURRENCYCOUNT      8

//---- parameters

extern string  gen               = "----General inputs----";
extern bool    autoSymbols       = false;
extern string	symbolsToWeigh    = "GBPNZD,EURNZD,GBPAUD,GBPCAD,GBPJPY,GBPCHF,CADJPY,EURCAD,EURAUD,USDCHF,GBPUSD,EURJPY,NZDJPY,AUDCHF,AUDJPY,USDJPY,EURUSD,NZDCHF,CADCHF,AUDNZD,NZDUSD,CHFJPY,AUDCAD,USDCAD,NZDCAD,AUDUSD,EURCHF,EURGBP";
extern int     maxBars           = 0;
extern string  nonPropFont       = "Lucida Console";
extern bool    showOnlySymbolOnChart = false;

extern string  ind               = "----Indicator inputs----";
extern bool    autoTimeFrame     = true;
extern string  ind_tf            = "timeFrame M1,M5,M15,M30,H1,H4,D1,W1,MN";
extern string  timeFrame         = "D1";
extern bool    ignoreFuture      = false;
extern bool    showCrossAlerts   = true;

extern string  cur               = "----Currency inputs----";
extern bool    USD               = true;
extern bool    EUR               = true;
extern bool    GBP               = true;
extern bool    CHF               = true;
extern bool    JPY               = true;
extern bool    AUD               = true;
extern bool    CAD               = true;
extern bool    NZD               = true;

extern string  col               = "----Colo(u)r inputs----";
extern color   Color_USD         = Green;
extern color   Color_EUR         = DeepSkyBlue;
extern color   Color_GBP         = Red;
extern color   Color_CHF         = Chocolate;
extern color   Color_JPY         = FireBrick;
extern color   Color_AUD         = DarkOrange;
extern color   Color_CAD         = Purple;
extern color   Color_NZD         = Teal;
extern color   colorWeakCross    = OrangeRed;
extern color   colorNormalCross  = Gold;
extern color   colorStrongCross  = LimeGreen;

// global indicator variables
string   indicatorName = "CurrencySlopeStrength";
string   shortName;
int      userTimeFrame;
string   almostUniqueIndex;

// indicator buffers
double   arrUSD[];
double   arrEUR[];
double   arrGBP[];
double   arrCHF[];
double   arrJPY[];
double   arrAUD[];
double   arrCAD[];
double   arrNZD[];

// symbol & currency variables
int      symbolCount;
string   symbolNames[];
string   currencyNames[CURRENCYCOUNT]        = { "USD", "EUR", "GBP", "CHF", "JPY", "AUD", "CAD", "NZD" };
double   currencyValues[CURRENCYCOUNT];      // Currency slope strength
double   currencyValuesPrior[CURRENCYCOUNT]; // Currency slope strength prior bar
double   currencyOccurrences[CURRENCYCOUNT]; // Holds the number of occurrences of each currency in symbols
color    currencyColors[CURRENCYCOUNT];

// object parameters
int      verticalShift = 14;
int      verticalOffset = 30;
int      horizontalShift = 100;
int      horizontalOffset = 10;

//----

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   initSymbols();
 
//---- indicators
   shortName = indicatorName + " - " + version;
   IndicatorShortName(shortName);
//----
   currencyColors[0] = Color_USD;
   SetIndexBuffer(0, arrUSD);
   SetIndexLabel(0, "USD"); 
   
   currencyColors[1] = Color_EUR;
   SetIndexBuffer(1, arrEUR);
   SetIndexLabel(1, "EUR"); 
   
   currencyColors[2] = Color_GBP;
   SetIndexBuffer(2, arrGBP);
   SetIndexLabel(2, "GBP"); 

   currencyColors[3] = Color_CHF;
   SetIndexBuffer(3, arrCHF);
   SetIndexLabel(3, "CHF"); 

   currencyColors[4] = Color_JPY;
   SetIndexBuffer(4, arrJPY);
   SetIndexLabel(4, "JPY"); 

   currencyColors[5] = Color_AUD;
   SetIndexBuffer(5, arrAUD);
   SetIndexLabel(5, "AUD"); 

   currencyColors[6] = Color_CAD;
   SetIndexBuffer(6, arrCAD);
   SetIndexLabel(6, "CAD"); 

   currencyColors[7] = Color_NZD;
   SetIndexBuffer(7, arrNZD);
   SetIndexLabel(7, "NZD"); 
//----
   string now = TimeCurrent();
   almostUniqueIndex = StringSubstr(now, StringLen(now) - 3);

   return(0);
}

//+------------------------------------------------------------------+
//| Initialize Symbols Array                                         |
//+------------------------------------------------------------------+
int initSymbols()
{
   int i;
   
   // Get extra characters on this crimmal's symbol names
   string symbolExtraChars = StringSubstr(Symbol(), 6, 4);

   // Trim user input
   symbolsToWeigh = StringTrimLeft(symbolsToWeigh);
   symbolsToWeigh = StringTrimRight(symbolsToWeigh);

   // Add extra comma
   if (StringSubstr(symbolsToWeigh, StringLen(symbolsToWeigh) - 1) != ",")
   {
      symbolsToWeigh = StringConcatenate(symbolsToWeigh, ",");   
   }   

   // Build symbolNames array as the user likes it
   if ( autoSymbols )
   {
      createSymbolNamesArray();
   }
   else
   {
      // Split user input
      i = StringFind(symbolsToWeigh, ","); 
      while (i != -1)
      {
         int size = ArraySize(symbolNames);
         // Resize array
         ArrayResize(symbolNames, size + 1);
         // Set array
         symbolNames[size] = StringConcatenate(StringSubstr(symbolsToWeigh, 0, i), symbolExtraChars);
         // Trim symbols
         symbolsToWeigh = StringSubstr(symbolsToWeigh, i + 1);
         i = StringFind(symbolsToWeigh, ","); 
      }
   }   
   
   symbolCount = ArraySize(symbolNames);

   for ( i = 0; i < symbolCount; i++ )
   {
      // Increase currency occurrence
      int currencyIndex = GetCurrencyIndex(StringSubstr(symbolNames[i], 0, 3));
      currencyOccurrences[currencyIndex]++;
      currencyIndex = GetCurrencyIndex(StringSubstr(symbolNames[i], 3, 3));
      currencyOccurrences[currencyIndex]++;
   }   

   userTimeFrame = PERIOD_D1;
   if ( autoTimeFrame )
   {
      userTimeFrame = Period();
   }
   else
   {   
		if ( timeFrame == "M1" )       userTimeFrame = PERIOD_M1;
		else if ( timeFrame == "M5" )  userTimeFrame = PERIOD_M5;
		else if ( timeFrame == "M15" ) userTimeFrame = PERIOD_M15;
		else if ( timeFrame == "M30" ) userTimeFrame = PERIOD_M30;
		else if ( timeFrame == "H1" )  userTimeFrame = PERIOD_H1;
		else if ( timeFrame == "H4" )  userTimeFrame = PERIOD_H4;
		else if ( timeFrame == "D1" )  userTimeFrame = PERIOD_D1;
		else if ( timeFrame == "W1" )  userTimeFrame = PERIOD_W1;
		else if ( timeFrame == "MN" )  userTimeFrame = PERIOD_MN1;
	}
}

//+------------------------------------------------------------------+
//| GetCurrencyIndex(string currency)                                |
//+------------------------------------------------------------------+
int GetCurrencyIndex(string currency)
{
   for (int i = 0; i < CURRENCYCOUNT; i++)
   {
      if (currencyNames[i] == currency)
      {
         return(i);
      }   
   }   
   return (-1);
}

//+------------------------------------------------------------------+
//| createSymbolNamesArray()                                         |
//+------------------------------------------------------------------+
void createSymbolNamesArray()
{
   int hFileName = FileOpenHistory ("symbols.raw", FILE_BIN|FILE_READ );
   int recordCount = FileSize ( hFileName ) / 1936;
   int counter = 0;
   for ( int i = 0; i < recordCount; i++ )
   {
      string tempSymbol = StringTrimLeft ( StringTrimRight ( FileReadString ( hFileName, 12 ) ) );
      if ( MarketInfo ( tempSymbol, MODE_BID ) > 0 && MarketInfo ( tempSymbol, MODE_TRADEALLOWED ) )
      {
         ArrayResize( symbolNames, counter + 1 );
         symbolNames[counter] = tempSymbol;
         counter++;
      }
      FileSeek( hFileName, 1924, SEEK_CUR );
   }
   FileClose( hFileName );
   return ( 0 );
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   int windex = WindowFind ( shortName );
   if ( windex > 0 )
   {
      ObjectsDeleteAll ( windex );
   }   
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

   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)  counted_bars -= 10;

   limit = Bars - counted_bars;

   if ( maxBars > 0 )
   {
      limit = MathMin (maxBars, limit);   
   }   

   int i;
   
   for ( i = 0; i < CURRENCYCOUNT; i++ )
   {
      SetIndexStyle( i, DRAW_LINE, STYLE_SOLID, 2, currencyColors[i] );
   }   

   RefreshRates();
   
   for ( i = limit; i >= 0; i-- )
   {
      int index;
      
      ArrayInitialize(currencyValues, 0.0);

      // Calc Slope into currencyValues[]  
      CalculateCurrencySlopeStrength(userTimeFrame, i);

      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "USD" ) != -1 ) ) || ( !showOnlySymbolOnChart && USD ) )        
      {
         arrUSD[i] = currencyValues[0];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "EUR" ) != -1 ) ) || ( !showOnlySymbolOnChart && EUR ) )        
      {
         arrEUR[i] = currencyValues[1];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "GBP" ) != -1 ) ) || ( !showOnlySymbolOnChart && GBP ) )        
      {
         arrGBP[i] = currencyValues[2];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "CHF" ) != -1 ) ) || ( !showOnlySymbolOnChart && CHF ) )        
      {
         arrCHF[i] = currencyValues[3];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "JPY" ) != -1 ) ) || ( !showOnlySymbolOnChart && JPY ) )        
      {
         arrJPY[i] = currencyValues[4];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "AUD" ) != -1 ) ) || ( !showOnlySymbolOnChart && AUD ) )        
      {
         arrAUD[i] = currencyValues[5];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "CAD" ) != -1 ) ) || ( !showOnlySymbolOnChart && CAD ) )        
      {
         arrCAD[i] = currencyValues[6];
      }
      if ( ( showOnlySymbolOnChart && ( StringFind ( Symbol(), "NZD" ) != -1 ) ) || ( !showOnlySymbolOnChart && NZD ) )        
      {
         arrNZD[i] = currencyValues[7];
      }
      
      if ( i == 1 )
      {
         ArrayCopy(currencyValuesPrior, currencyValues);
      }
      if ( i == 0 )
      {
         // Show ordered table
         ShowCurrencyTable();
      }   

   }//end block for(int i=0; i<limit; i++)
   
   return(0);
}

//+------------------------------------------------------------------+
//| GetSlope()                                                       |
//+------------------------------------------------------------------+
double GetSlope(string symbol, int tf, int shift)
{
   double dblTma, dblPrev;
   double atr = iATR(symbol, tf, 100, shift + 10) / 10;
   double gadblSlope = 0.0;
   if ( atr != 0 )
   {
      if ( ignoreFuture )
      {
         dblTma = calcTmaTrue( symbol, tf, shift );
         dblPrev = calcPrevTrue( symbol, tf, shift );
      }
      else
      {   
         dblTma = calcTma( symbol, tf, shift );
         dblPrev = calcTma( symbol, tf, shift + 1 );
      }   
      gadblSlope = ( dblTma - dblPrev ) / atr;
   }
   
   return ( gadblSlope );

}//End double GetSlope(int tf, int shift)

//+------------------------------------------------------------------+
//| calcTma()                                                        |
//+------------------------------------------------------------------+
double calcTma( string symbol, int tf,  int shift )
{
   double dblSum  = iClose( symbol, tf, shift ) * 21;
   double dblSumw = 21;
   int jnx, knx;
         
   for ( jnx = 1, knx = 20; jnx <= 20; jnx++, knx-- )
   {
      dblSum  += iClose(symbol, tf, shift + jnx) * knx;
      dblSumw += knx;

      if ( jnx <= shift )
      {
         dblSum  += iClose(symbol, tf, shift - jnx) * knx;
         dblSumw += knx;
      }
   }
   
   return ( dblSum / dblSumw );
}// End calcTma()


//+------------------------------------------------------------------+
//| calcTmaTrue()                                                    |
//+------------------------------------------------------------------+
double calcTmaTrue( string symbol, int tf, int inx )
{
   return ( iMA( symbol, tf, 21, 0, MODE_LWMA, PRICE_CLOSE, inx ) );
}

//+------------------------------------------------------------------+
//| calcPrevTrue()                                                   |
//+------------------------------------------------------------------+
double calcPrevTrue( string symbol, int tf, int inx )
{
   double dblSum  = iClose( symbol, tf, inx + 1 ) * 21;
   double dblSumw = 21;
   int jnx, knx;
   
   dblSum  += iClose( symbol, tf, inx ) * 20;
   dblSumw += 20;
         
   for ( jnx = 1, knx = 20; jnx <= 20; jnx++, knx-- )
   {
      dblSum  += iClose( symbol, tf, inx + 1 + jnx ) * knx;
      dblSumw += knx;
   }
   
   return ( dblSum / dblSumw );
}
 
//+------------------------------------------------------------------+
//| CalculateCurrencySlopeStrength(int tf, int shift                 |
//+------------------------------------------------------------------+
void CalculateCurrencySlopeStrength(int tf, int shift)
{
   int i;
   // Get Slope for all symbols and totalize for all currencies   
   for ( i = 0; i < symbolCount; i++)
   {
      double slope = GetSlope(symbolNames[i], tf, shift);
      currencyValues[GetCurrencyIndex(StringSubstr(symbolNames[i], 0, 3))] += slope;
      currencyValues[GetCurrencyIndex(StringSubstr(symbolNames[i], 3, 3))] -= slope;
   }
   for ( i = 0; i < CURRENCYCOUNT; i++ )
   {
      // average
      currencyValues[i] /= currencyOccurrences[i];
   }
}

//+------------------------------------------------------------------+
//| ShowCurrencyTable()                                              |
//+------------------------------------------------------------------+
void ShowCurrencyTable()
{
   int i;
   int tempValue;
   string objectName;
   string showText;
   color showColor;
   int windex = WindowFind ( shortName );
   double tempCurrencyValues[CURRENCYCOUNT][3];
   
   for ( i = 0; i < CURRENCYCOUNT; i++ )
   {
      tempCurrencyValues[i][0] = currencyValues[i];
      tempCurrencyValues[i][1] = NormalizeDouble(currencyValuesPrior[i], 2);
      tempCurrencyValues[i][2] = i;
   }
   
   // Sort currency to values
   ArraySort(tempCurrencyValues, WHOLE_ARRAY, 0, MODE_DESCEND);

   int horizontalOffsetCross = 0;
   // Loop currency values and header output objects, creating them if necessary 
   for ( i = 0; i < CURRENCYCOUNT; i++ )
   {
      objectName = almostUniqueIndex + "_css_obj_column_currency_" + i;
      if ( ObjectFind ( objectName ) == -1 )
      {
         if ( ObjectCreate ( objectName, OBJ_LABEL, windex, 0, 0 ) )
         {
            ObjectSet ( objectName, OBJPROP_CORNER, 1 );
            ObjectSet ( objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset + 150 );
            ObjectSet ( objectName, OBJPROP_YDISTANCE, (verticalShift + 2) * i + verticalOffset - 18 );
         }
      }
      tempValue = tempCurrencyValues[i][2];
      showText = currencyNames[tempValue];
      ObjectSetText ( objectName, showText, 12, nonPropFont, currencyColors[tempValue] );

      objectName = almostUniqueIndex + "_css_obj_column_value_" + i;
      if ( ObjectFind ( objectName ) == -1 )
      {
         if ( ObjectCreate ( objectName, OBJ_LABEL, windex, 0, 0 ) )
         {
            ObjectSet ( objectName, OBJPROP_CORNER, 1 );
            ObjectSet ( objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset - 55 + 150 );
            ObjectSet ( objectName, OBJPROP_YDISTANCE, (verticalShift + 2) * i + verticalOffset - 18 );
         }
      }
      showText = RightAlign(DoubleToStr(tempCurrencyValues[i][0], 2), 5);
      ObjectSetText ( objectName, showText, 12, nonPropFont, currencyColors[tempValue] );
      
      // Detect and show crosses if users want to
      // Test for normalized values to filter trivial crosses
      objectName = almostUniqueIndex + "_css_obj_column_cross_" + i;
      if ( showCrossAlerts
           && i < CURRENCYCOUNT - 1
           && NormalizeDouble( tempCurrencyValues[i][0], 2 ) > NormalizeDouble( tempCurrencyValues[i + 1][0], 2 )
           && tempCurrencyValues[i][1] < tempCurrencyValues[i + 1][1]
         )
      {
         showColor = colorStrongCross;
         if ( tempCurrencyValues[i][0] > 0.8 || tempCurrencyValues[i + 1][0] < -0.8 )
         {
            showColor = colorWeakCross;
         }
         else if  ( tempCurrencyValues[i][0] > 0.4 || tempCurrencyValues[i + 1][0] < -0.4 )
         {
            showColor = colorNormalCross;
         }
      
         // Prior values of this currency is lower than next currency, this is a cross.
         DrawCell(windex, objectName, horizontalShift * 0 + horizontalOffset + 88 + horizontalOffsetCross, (verticalShift + 2) * i + verticalOffset - 20, 1, 27, showColor );
      
         // Move cross location to next column if necessary
         if ( horizontalOffsetCross == 0 )
         {
            horizontalOffsetCross = -4;
         }
         else
         {
            horizontalOffsetCross = 0;
         }
      }
      else
      {
         DeleteCell(objectName);
         horizontalOffsetCross = 0;
      }
   }
}

//+------------------------------------------------------------------+
//| Right Align Text                                                 |
//+------------------------------------------------------------------+
string RightAlign ( string text, int length = 10, int trailing_spaces = 0 )
{
   string text_aligned = text;
   for ( int i = 0; i < length - StringLen ( text ) - trailing_spaces; i++ )
   {
      text_aligned = " " + text_aligned;
   }
   return ( text_aligned );
}

//+------------------------------------------------------------------+
//| DrawCell(), credits go to Alexandre A. B. Borela                 |
//+------------------------------------------------------------------+
void DrawCell ( int nWindow, string nCellName, double nX, double nY, double nWidth, double nHeight, color nColor )
{
   double   iHeight, iWidth, iXSpace;
   int      iSquares, i;

   if ( nWidth > nHeight )
   {
      iSquares = MathCeil ( nWidth / nHeight ); // Number of squares used.
      iHeight  = MathRound ( ( nHeight * 100 ) / 77 ); // Real height size.
      iWidth   = MathRound ( ( nWidth * 100 ) / 77 ); // Real width size.
      iXSpace  = iWidth / iSquares - ( ( iHeight / ( 9 - ( nHeight / 100 ) ) ) * 2 );

      for ( i = 0; i < iSquares; i++ )
      {
         ObjectCreate   ( nCellName + i, OBJ_LABEL, nWindow, 0, 0 );
         ObjectSetText  ( nCellName + i, CharToStr ( 110 ), iHeight, "Wingdings", nColor );
         ObjectSet      ( nCellName + i, OBJPROP_CORNER, 1 );
         ObjectSet      ( nCellName + i, OBJPROP_XDISTANCE, nX + iXSpace * i );
         ObjectSet      ( nCellName + i, OBJPROP_YDISTANCE, nY );
         ObjectSet      ( nCellName + i, OBJPROP_BACK, true );
      }
   }
   else
   {
      iSquares = MathCeil ( nHeight / nWidth ); // Number of squares used.
      iHeight  = MathRound ( ( nHeight * 100 ) / 77 ); // Real height size.
      iWidth   = MathRound ( ( nWidth * 100 ) / 77 ); // Real width size.
      iXSpace  = iHeight / iSquares - ( ( iWidth / ( 9 - ( nWidth / 100 ) ) ) * 2 );

      for ( i = 0; i < iSquares; i++ )
      {
         ObjectCreate   ( nCellName + i, OBJ_LABEL, nWindow, 0, 0 );
         ObjectSetText  ( nCellName + i, CharToStr ( 110 ), iWidth, "Wingdings", nColor );
         ObjectSet      ( nCellName + i, OBJPROP_CORNER, 1 );
         ObjectSet      ( nCellName + i, OBJPROP_XDISTANCE, nX );
         ObjectSet      ( nCellName + i, OBJPROP_YDISTANCE, nY + iXSpace * i );
         ObjectSet      ( nCellName + i, OBJPROP_BACK, true );
      }
   }
}

//+------------------------------------------------------------------+
//| DeleteCell()                                                     |
//+------------------------------------------------------------------+
void DeleteCell(string name)
{
   int square = 0;
   while ( ObjectFind( name + square ) > -1 )
   {
      ObjectDelete( name + square );
      square++;
   }   
}


