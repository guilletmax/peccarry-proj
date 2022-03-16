#runSim4.1.R
#Jen Bradham, Clara Yip, Max Guillet


# UPDATE VARS

setwd("C:/Users/guill/Downloads")

#x_length <- 10
#y_length <- 10
#count_forest <- 2
#steps <- 200
#max_dist <- 3

# -----------------------------

rm(list=ls())
source("C:/Users/guill/workspace/peccarry-proj/mg4.1_JB.R")
library(RColorBrewer)
#library(tidyverse)


freq_holder <- matrix(0L, nrow =  10, ncol = 30)
times_crossed <- matrix(0L, nrow =  10, ncol = 30)
dist_bw_patches <- matrix(0L, nrow = 10, ncol = 30)

for (i in 1:10) {
  print(paste("Simulating", i*10, "percent viable", sep = " "))
  for (j in 1:30) {
    print(".")
    result <- simulate_movement(10, 10, 3, (i * 10), 200,
                                3, j)
    freq_holder[i, j] <- result[1]                    
    times_crossed[i, j] <- result[2]
    dist_bw_patches[i, j] <- result[3]  
  }
}


boxplot.matrix(freq_holder, use.cols = FALSE, las = 2, ylab = "Percent viable map with tread == 
               0", xlab = "Percent map viable", col = brewer.pal(9, "Spectral"), 
               names = c("10%", "20%", "30%", "40%", "50%", "60%", "70%", "80%",
                         "90%", "100%"))

dev.copy(jpeg, paste("totalBoxplot", ".jpeg", sep = ""))
dev.off()

write.csv(freq_holder, file = "totalBoxplot.csv")
write.csv(times_crossed, file = "totalCrossingFreq.csv")
# write.csv(dist_bw_patches, file = "avgDist.csv")

# for (i in 1:10) {
#   plot(dist_bw_patches[i,], freq_holder[i,], ylab = "Percent of unused forest", xlab = "Avg distance between forest patches")
#   dev.copy(jpeg, paste("avg0byDist", i*10, ".jpeg", sep = ""))
#   dev.off()
# }
