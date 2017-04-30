//+------------------------------------------------------------------+
//|                                                ExportHistory.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql4.com"
#property version   "1.00"
#property strict
#property show_inputs

#include <PCFramework/PCMultiTimeframe.mqh>

int fileh =-1;
int lasterror;
extern string inputCcies ="";
//string Currencies[] = {"EURUSD"};
int TFs[] = {PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
extern int BarCount = 100;
string dSymbol;
double Poin;
int handle;
extern datetime dtDateStart   = D'2014.01.01 00:00';

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
//---


 string Currencies[];
 getCurrencies(Currencies);
 int count = ArraySize(Currencies);

   for (int ii=0; ii<count; ii++)
   {
     for (int jj=0; jj<ArraySize(TFs); jj++)
     {
        dSymbol = Currencies[ii];   
        int dTF=TFs[jj];
        string strTF=PeriodToStr(dTF);
        handle = FileOpen("Hist_"+dSymbol+"_"+strTF+".csv", FILE_BIN|FILE_WRITE);

        int maxBars = Bars(dSymbol,dTF,dtDateStart, TimeCurrent());
        if( maxBars<BarCount )
         maxBars = BarCount;
         
        if(handle < 1)
        {
           Print("Err ", GetLastError());
        }
        WriteHeader();
   
        for(int i = 0; i < maxBars - 1; i++)
        {
          WriteDataRow(i,dTF);
        }
        FileClose(handle);
     
     }
   }
}
//+------------------------------------------------------------------+

void WriteData(string txt)
{
  FileWriteString(handle, txt,StringLen(txt));
  return;
}

void WriteHeader()
{
  WriteData("Symbol,");
  
  //WriteData("Time,");
  WriteData("Year,");
  WriteData("Month,");
  WriteData("Week,");
  WriteData("Day,");
  WriteData("Hour,");  
  WriteData("Minute,");  

  WriteData("Open,");
  WriteData("High,");
  WriteData("Low,");
  WriteData("Close,");
  WriteData("Volume");
  
  WriteData("\n");
  return;
}

void WriteDataRow(int i,int Timef)
{
 
 double  dSymTime, dSymOpen, dSymHigh, dSymLow, dSymClose, dSymVolume;
 //int dDayofWk,dDayofYr,iDigits;
 int iDigits;

 dSymTime = (iTime(dSymbol,Timef,i));
 
 int dYear = TimeYear(dSymTime);
 int dMonth = TimeMonth(dSymTime);
 int dWeek = TimeDayOfWeek(dSymTime); 
 int dDay   = TimeDay(dSymTime);
 int dHour = TimeHour(dSymTime);
 int dMin  = TimeMinute(dSymTime);
 
 dSymOpen = (iOpen(dSymbol,Timef,i));

 if(dSymOpen>0)
 {
  WriteData(dSymbol+",");
  //WriteData(TimeToStr(dSymTime, TIME_DATE|TIME_MINUTES|TIME_SECONDS)+",");
  
  WriteData(dYear+","); 
  WriteData(dMonth+","); 
  WriteData(dWeek+","); 
  WriteData(dDay+","); 
  WriteData(dHour+","); 
  WriteData(dMin+","); 

  iDigits=MarketInfo(Symbol(),MODE_DIGITS);
  
  
  dSymOpen = (iOpen(dSymbol,Timef,i));
  dSymHigh = (iHigh(dSymbol,Timef,i));
  dSymLow = (iLow(dSymbol,Timef,i));
  dSymClose = (iClose(dSymbol,Timef,i));
  dSymVolume = (iVolume(dSymbol,Timef,i));
 
  //  int BarsInBox=8;
  //  double PeriodHighest = High[iHighest(dSymbol,Period(),MODE_HIGH,BarsInBox+1,i)];
  //  double PeriodLowest  =  Low[iLowest(dSymbol,Period(),MODE_LOW,BarsInBox+1,i)];
  //  double PeriodRNG  =  (PeriodHighest-PeriodLowest)/Poin;

  //WriteData(dDayofWk+","+dDayofYr+",");
  WriteData(DoubleToStr(dSymOpen, iDigits)+",");
  WriteData(DoubleToStr(dSymHigh, iDigits)+",");
  WriteData(DoubleToStr(dSymLow, iDigits)+",");
  WriteData(DoubleToStr(dSymClose, iDigits)+",");
  WriteData(DoubleToStr(dSymVolume, iDigits)+",");  
  WriteData("\n");
 }
 
 return;
}

void getCurrencies(string &result[])
{
   string to_split=inputCcies;   // A string to split into substrings
   string sep=",";                // A separator as a character
   ushort u_sep;                  // The code of the separator character
   //string result[];               // An array to get strings
   //--- Get the separator code
   u_sep=StringGetCharacter(sep,0);
   //--- Split the string to substrings
   int k=StringSplit(to_split,u_sep,result);
   //return(result);
}