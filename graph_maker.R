#! /usr/local/bin/Rscript
# Susceptibility plot construction 
library(tcltk)
source('varEntryDialog.r')

Sys.setlocale('LC_ALL', 'en_US.UTF-8')
print("Susceptibility plots construction")
print("Выберите файл данных .cur")
data_file <- tk_choose.files(caption = 'Please select data file', 
                        multi = F, filters = matrix(c("*", ".CUR", "*", ".cur"),2,2, byrow = T))

dir  <- 1
list.files(dr, pattern = "\\.(cur)|(CUR)$")

inputs <- varEntryDialog(vars = c('item', 'source'), labels = c('Номер образца', "Источник образца"))
data_lines  <- gsub("(?<=[0-9])((-|\\s)[0-9]+)", " \\1", readLines(data_file), perl=TRUE)
data <- read.table(text = data_lines, sep = "", header = T, fill = T)
max_index <- which.max(data$TEMP)
tot_length <- length(data$NSUSC)
heat_part <- data[1:max_index, ]
cool_part <- data[(max_index-1):tot_length, ]

#1 graph
png(paste(inputs$item, "plot_norm.png", sep = '_'), height=480, width=640)
lims  <- c(min(data$NSUSC), max(data$NSUSC))
with(heat_part, plot(TEMP, NSUSC, type = 'l', col = 'red', xlab = 'T, °C',
                     ylab = 'k/k max T', main = inputs$source, ylim = lims*1.05))
with(cool_part, lines(TEMP, NSUSC, col = 'blue'))
legend('bottomleft', c("Нагрев", "Охлаждение"), col = c('red', 'blue'), lty = c(1,1,1))
dev.off()
print(paste("Graph", paste(inputs$item, "plot_norm.png", sep = '_'), "written"))
#2 graph
png(paste(inputs$item, "plot_cur.png", sep = '_'), height=480, width=640)
lims  <- c(min(data$CSUSC), max(data$CSUSC))
with(heat_part, plot(TEMP, CSUSC, type = 'l', col = 'red', xlab = 'T, °C',
                     ylab = 'k*1e-6 SI', main = inputs$source, ylim = lims*1.05))
with(cool_part, lines(TEMP, CSUSC, col = 'blue'))
legend('bottomleft', c("Нагрев", "Охлаждение"), col = c('red', 'blue'), lty = c(1,1,1))
dev.off()
print(paste("Graph", paste(inputs$item, "plot_cur.png", sep = '_'), "written"))
