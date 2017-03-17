library(xts)
file="H:\\Trading\\EATesting\\MedAvgCross\\EURJPY_1H_13.csv";
df = read.csv(file, header = TRUE , as.is = TRUE )
df$date <- as.POSIXct(df$time, format = "%d-%m-%Y %H:%M")
IndiRawXTS <- xts(x = df, order.by = df$date)

mean(df$cross)
sd(df$cross)