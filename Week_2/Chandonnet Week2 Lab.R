setwd('/Users/raychandonnet/Dropbox (Personal)/Merrimack College - MS in Data Science/DSE5002')
getwd()
library(stringr)
library(lubridate)
library(forcats)
library(readr)
encoding_input <- guess_encoding("Week_2/Data/sales_pipe_mac.txt", n_max = 10000)
encoding_input
sales <- read.delim(file="Week_2/Data/sales_pipe_mac.txt",
                    stringsAsFactors=FALSE,
                    fileEncoding = "UTF-16LE",
                    header=TRUE,
                    sep="|",
                    # quote = "\",
                    fill=TRUE)
lastcol <- length(sales)
sales <- sales[,-lastcol]
                    
