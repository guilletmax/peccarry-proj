#runSim4.1.R
#Jen Bradham, Clara Yip, Max Guillet


# UPDATE VARS

setwd("TODO")

x_length <- 10
y_length <- 10
count_forest <- 2
steps <- 200
max_dist <- 3

# -----------------------------

rm(list=ls())
source("mg4.1_JB (1).R")
library(RColorBrewer)
library(tidyverse)


freqHolder <- matrix(0L, nrow = 10, ncol = 30)
timesCrossed <- matrix(0L, nrow = 10, ncol = 30)
distBWPatches <- matrix(0L, nrow = 10, ncol = 30)

for (i in 1:10) {
  print(paste("Simulating", i*10, "percent viable", sep = " "))
  for (j in 1:30) {
    print(".")
    result <- simulateMovement(x_length, y_length, count_forest, i * 10, steps, 
                               max_dist, j)
    freqHolder[i, j] <- result[1]                    
    timesCrossed[i, j] <- result[2]
    distBWPatches[i, j] <- result[3]  
  }
}


boxplot.matrix(t(freqHolder), las = 2, ylab = "Percent viable map with tread == 
               0", xlab = "Percent map viable", col = brewer.pal(9, "Spectral"), 
               names = c("10%", "20%", "30%", "40%", "50%", "60%", "70%", "80%",
                         "90%", "100%"))

dev.copy(jpeg, paste("totalBoxplot", ".jpeg", sep = ""))
dev.off()

write.csv(freqHolder, file = "totalBoxplot.csv")
write.csv(timesCrossed, file = "totalCrossingFreq.csv")
write.csv(distBWPatches, file = "avgDist.csv")

for (i in 1:10) {
  plot(distBWPatches[i,], freqHolder[i,], ylab = "Percent of unused forest", xlab = "Avg distance between forest patches")
  dev.copy(jpeg, paste("avg0byDist", i*10, ".jpeg", sep = ""))
  dev.off()
}
