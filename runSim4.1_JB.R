#runSim4.1.R
#Jen Bradham, Clara Yip, Max Guillet

# -----------------------------

rm(list=ls())
source("C:/Users/guill/workspace/peccarry-proj/mg4.1_JB.R")
library(RColorBrewer)

# UPDATE VARS

setwd("C:/Users/guill/Downloads")
x_length <- 100      # x size of grid
y_length <- 100      # y size of grid
count_forest <- 5   # number of forests
steps <- 200        # number of steps for simulation to run
max_dist <- 3       # maximum distance a peccary can move in one step
max_iter <- 30       # number of iterations

freq_holder <- matrix(0L, nrow =  10, ncol = max_iter)
times_crossed <- matrix(0L, nrow =  10, ncol = max_iter)
dist_bw_patches <- matrix(0L, nrow = 10, ncol = max_iter)

for (percent_forest in seq(from=10, to=100, by=10)) {
  print(paste("Simulating", percent_forest, "percent viable", sep = " "))
  for (iter in 1:max_iter) {
    print(".")
    print(iter)
    result <- simulate_movement(x_length, y_length, count_forest, percent_forest, steps,
                                3, iter)
    print(result)
    #browser()
    freq_holder[percent_forest / 10, iter] <- result[1]                    
    times_crossed[percent_forest / 10, iter] <- result[2]
    dist_bw_patches[percent_forest / 10, iter] <- result[3]  
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
write.csv(dist_bw_patches, file = "avg_dist.csv")

for (i in 1:10) {
  plot(dist_bw_patches[i,], freq_holder[i,], ylab = "Percent of unused forest", xlab = "Avg distance between forest patches")
  dev.copy(jpeg, paste("avg0byDist", i*10, ".jpeg", sep = ""))
  dev.off()
}
