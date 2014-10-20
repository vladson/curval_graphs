#! /usr/local/bin/Rscript
# Susceptibility plot construction 
library(tcltk)
library(tools)
source('varEntryDialog.r')

Sys.setlocale('LC_ALL', 'en_US.UTF-8')
print("Susceptibility plots construction")
print("Please select data directory .cur")
#data_file <- tk_choose.files(caption = 'Please select data file', 
#                        multi = F, filters = matrix(c("*", ".CUR", "*", ".cur"),2,2, byrow = T))

src_dir <- tk_choose.dir(caption = "Select data directory")
files <- list.files(src_dir, pattern = "\\.(cur)|(CUR)$")
print(paste("Preparing graphs for files in", src_dir))
inputs <- varEntryDialog(vars = c('dst', 'position', 'heating', 'cooling'), 
                         labels = c('Destination subdir name(e.g. graphs)',
                                    "Legend (topleft, bottomleft, topright, bottomright",
                                    "Heating legend label", "Cooling legend label"),
                                    prompt = "Graphs dir and legend position")
dir.create(file.path(src_dir, inputs$dst))
was_wd <- getwd()
setwd(file.path(src_dir, inputs$dst))
for (data_file in files) {
  name_part <- sub("\\.[[:alnum:]]+$", "", data_file)
  data_lines  <- gsub("(?<=[0-9])((-|\\s)[0-9]+)", " \\1",
                      readLines(file.path(src_dir, data_file)), perl=TRUE)
  data <- read.table(text = data_lines, sep = "", header = T, fill = T)
  max_index <- which.max(data$TEMP)
  tot_length <- length(data$NSUSC)
  heat_part <- data[1:max_index, ]
  cool_part <- data[(max_index-1):tot_length, ]
  
  #1 graph
  png(paste(name_part, "norm.png", sep = '_'), height=480, width=640)
  lims  <- c(min(data$NSUSC), max(data$NSUSC))
  with(heat_part, plot(TEMP, NSUSC, type = 'l', col = 'red', xlab = 'T, °C',
                       ylab = 'k/k max T', main = name_part, ylim = lims*1.05))
  with(cool_part, lines(TEMP, NSUSC, col = 'blue'))
  legend('bottomleft', c(inputs$heating, inputs$cooling), col = c('red', 'blue'), lty = c(1,1,1))
  dev.off()
  print(paste("Graph", paste(name_part, "norm.png", sep = '_'), "written"))
  #2 graph
  png(paste(name_part, "cur.png", sep = '_'), height=480, width=640)
  lims  <- c(min(data$CSUSC), max(data$CSUSC))
  with(heat_part, plot(TEMP, CSUSC, type = 'l', col = 'red', xlab = 'T, °C',
                       ylab = 'k*1e-6 SI', main = name_part, ylim = lims*1.05))
  with(cool_part, lines(TEMP, CSUSC, col = 'blue'))
  legend('bottomleft', c(inputs$heating, inputs$cooling), col = c('red', 'blue'), lty = c(1,1,1))
  dev.off()
  print(paste("Graph", paste(name_part, "cur.png", sep = '_'), "written"))
}
setwd(was_wd)