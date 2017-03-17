library(plyr)
if(!exists("barcolor", mode="function")) source("H:\\Trading\\EATesting\\Utilities.R")


pairs <- c("EURUSD","USDJPY","USDCAD","GBPUSD","AUDUSD","NZDUSD",
           "EURJPY","EURGBP","EURCAD","AUDJPY","NZDJPY","CADJPY")

#pairs <- c("EURUSD","USDJPY")
timeframes <- c(60)

pipsDiffList <-  c(  6, 7, 8, 9 )
#pipsDiffList <-  c(  6, 7 )
FlowCheckList <-c( 30, 40 , 45 , 50 , 55 )
#FlowCheckList <-c(30, 40 )
basePath = "H:\\Trading\\EATesting\\ShavedBar\\"

#---- INPUTS  -----

#sy
#tf
#pipsDiff
#FlowCheck
#getPoint("EURGBP")
#res <- c()

res <- NULL
for( sy in pairs )
{ 
  for( tf in timeframes )
  {   
  
     for( pipsDiff in pipsDiffList )
     {  
       for( FlowCheck in FlowCheckList )
       {  

point = getPoint(sy)
filename = paste("ShavedBar-",sy,"-",toString(tf),".csv", sep="")#"ShavedBar-GBPUSD-60.csv"
startDate = as.POSIXct("2016-01-01")
#pipsDiff = 1 # Diff between close, and High or Low
#FlowCheck = 50 # Range of the bar, atleast
#---- INPUTS  -----


# Shave = High/Low to Close
# fBreak = High to next High, Low to Next Low

file = paste(basePath ,filename , sep="")
rawdf = read.csv(file, header = TRUE , as.is = TRUE )
rawdf$date <- as.POSIXct(rawdf$Time, format = "%Y.%m.%d %H:%M")


rawdf$color <- apply( rawdf , 1 , function(x) barcolor( x['Open'] , x['Close'] ))
rawdf$shave <- apply( rawdf , 1 , function(x) shaveSize( as.numeric(x['High']),as.numeric(x['Low']) , as.numeric(x['Close']),toString(x['color']) ))
rawdf$fbreakUP <- c(diff( rawdf$High)/point,0)
rawdf$fbreakDN <- c(diff( rawdf$Low )/point,0)
rawdf$fbreak <- apply( rawdf , 1 , function(x) falsebreak( toString(x['color']) , as.numeric(x['fbreakUP']), as.numeric(x['fbreakDN']) ))
rawdf$EAEligible <-  apply( rawdf , 1 , function(x) inTrend( toString(x['color']) , as.numeric(x['fbreak']) ))
rawdf$Flow = ( rawdf$High - rawdf$Low )/point

#print( paste("Raw Transformation yields - " , nrow(rawdf), " Rows " ))
nRowsBefore <- c(nrow(rawdf))

# Filtering
rawdf <- rawdf[rawdf$Flow > FlowCheck,]
rawdf <- rawdf[rawdf$shave < pipsDiff,]


#print( paste("**** OUT **** Flow Chars before Filter - MeanFlow:" , mean(rawdf$Flow), " SDFlow:", sd(rawdf$Flow) , " MedianFlow: " , median(rawdf$Flow) ))
#print( paste("**** OUT **** Shave Chars before Filter - MeanShave:" , mean(rawdf$shave), " SDShave:", sd(rawdf$shave) , " MedianShave: " , median(rawdf$shave) ))

AvgFlowBefore <- c(mean(rawdf$Flow))
SdFlowBefore <- c(sd(rawdf$Flow))
MdFlowBefore <- c(median(rawdf$Flow))
AvgShaveBefore <- c(mean(rawdf$shave))
SdShaveBefore <- c(sd(rawdf$shave))
MdShaveBefore <- c(median(rawdf$shave))

Sep <- c("-")

# Pct of Eligible bars between R-G
eligbBars <- rawdf[rawdf$EAEligible=="Y",]
falseBars <- rawdf[rawdf$EAEligible=="N",]

PctElig <- (nrow(eligbBars)/nrow(rawdf))*100
PctFalse <- (nrow(falseBars)/nrow(rawdf))*100

PctEli <- c(PctElig)
PctFal <- c(PctFalse)

PctGreenBars <- (nrow(eligbBars[eligbBars$color=="G",])/nrow(eligbBars))*100
PctRedBars <- (nrow(eligbBars[eligbBars$color=="R",])/nrow(eligbBars))*100

PctGBar <- c(PctGreenBars)
PctRBar <- c(PctRedBars)

#print( paste("**** OUT **** Pct of GreenBars Eligible : " , PctGreenBars, "Pct of RedBars Eligible : " , PctRedBars ) )
#print( paste("**** OUT **** Flow Chars After Filter - MeanFlow:" , mean(eligbBars$Flow), " SDFlow:", sd(eligbBars$Flow) , " MedianFlow: " , median(eligbBars$Flow) ))
#print( paste("**** OUT **** Shave Chars After Filter - MeanShave:" , mean(eligbBars$shave), " SDShave:", sd(eligbBars$shave) , " MedianShave: " , median(eligbBars$shave) ))

AvgFlowElig <- c(mean(eligbBars$Flow))
SdFlowElig <- c(sd(eligbBars$Flow))
MdFlowElig <- c(median(eligbBars$Flow))
AvgShaveElig <- c(mean(eligbBars$shave))
SdShaveElig <- c(sd(eligbBars$shave))
MdShaveElig <- c(median(eligbBars$shave))


# Breakout Chars
AvgTP<- c(mean(abs(eligbBars$fbreak)))
SdTP <- c(sd(abs(eligbBars$fbreak)))
MdTP <- c(median(abs(eligbBars$fbreak)))
#print( paste("**** OUT **** BreakoutPips Mean:", mean(abs(eligbBars$fbreak))," SD:", sd(abs(eligbBars$fbreak)), " Median:" ,median(abs(eligbBars$fbreak))  ) )

# Pct of Eligible bars between R-G

#AvgSL<- c(mean(falseBars$Flow))
#SdFlowFalse <- c(sd(falseBars$Flow))
#MdFlowFalse <- c(median(falseBars$Flow))
AvgSL <- c(mean(falseBars$shave))
SdSL <- c(sd(falseBars$shave))
MdSL <- c(median(falseBars$shave))

row = data.frame(c(sy),c(toString(tf)),c(toString(pipsDiff)),c(toString(FlowCheck)),nRowsBefore, AvgFlowBefore, SdFlowBefore,MdFlowBefore,AvgShaveBefore,SdShaveBefore,MdShaveBefore,Sep,PctEli,PctFal,PctGBar,PctRBar,AvgFlowElig,SdFlowElig,MdFlowElig,AvgShaveElig,SdShaveElig,MdShaveElig,AvgTP,SdTP,MdTP,AvgSL,SdSL,MdSL)
rbind(res,row) -> res
#res<-NULL;

    }
   } #pipsDiff
    
    #tfsep <- data.frame(  matrix(" ", ncol = 28, nrow = 1) )
    #rbind(res,tfsep) -> res
    
 } # tf
  
  #sysep <- data.frame(matrix(" ", ncol = 28, nrow = 1) )
  #rbind(res,sysep) -> res
} #sy

write.csv(res, "H:\\Trading\\EATesting\\ShavedBar\\Results.csv")


#print( paste("**** OUT **** False Break After Filter - MeanShave:" , mean(falseBars$shave), " SDShave:", sd(falseBars$shave) , " MedianShave: " , median(falseBars$shave) ))
##by(s1[, C(6,8)], color, colMeans)
#aggregate(eligbBars[,6],eligbBars['color'],count() )

#View(res[1])

#load("C:\\RData\\R-Sample_EURUSD_15.RData")


