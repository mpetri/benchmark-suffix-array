
args <- commandArgs(trailingOnly=TRUE)

input_file <- args[1]
output_file <- args[2]

data <- read.csv2(input_file,sep=';')
data$time_per_sym <- data$time_ns / data$total_syms
data$space_percent <- 100 * data$index_size_bytes / data$text_size_bytes
data$text_size_mib <- data$text_size_bytes / (1024*1024)

data_parsed <- subset(data, select = c(testcase,text_size_mib,index_name,time_per_sym,space_percent))

write.table(data_parsed, file = output_file,row.names=FALSE, na="",col.names=TRUE, sep=";")
