#runSim4.1.R
#Jen Bradham, Clara Yip, Max Guillet

# -----------------------------

rm(list=ls())
source("~/workspace/peccary-proj/mg4.1_JB.R")
library(RColorBrewer)
library(ggplot2)


# UPDATE VARS

setwd("~/workspace/peccary-proj/results")
x_length <- 100      # x size of grid
y_length <- 100      # y size of grid
count_forest <- 8   # number of forests
years <- 1         # duration of run
max_iter <- 3      # number of iterations

freq_holder <- matrix(0L, nrow =  10, ncol = max_iter)
times_crossed <- matrix(0L, nrow =  10, ncol = max_iter)
dist_bw_patches <- matrix(0L, nrow = 10, ncol = max_iter)
avg_daily_dist <- matrix(0L, nrow=10, ncol = max_iter)

steps <- years * 360 * 8       # number of steps for simulation to run ( 2880 = 1 year )

# from=10, to=100, by=10
for (percent_forest in seq(from=100, to=10, by=-10)) {
  print(paste("Simulating", percent_forest, "percent viable", sep = " "))
  for (iter in 1:max_iter) {
    print('.')
    result <- simulate_movement(x_length, y_length, count_forest, percent_forest, steps,
                                3, iter)
    freq_holder[percent_forest / 10, iter] <- result[1]                    
    times_crossed[percent_forest / 10, iter] <- result[2]
    dist_bw_patches[percent_forest / 10, iter] <- result[3]
    avg_daily_dist[percent_forest / 10, iter] <- result[4] / (years * 360)
  }
}


boxplot.matrix(freq_holder, use.cols = FALSE, las = 2, ylab = "Percent viable map with tread == 
               0", xlab = "Percent map viable", col = brewer.pal(9, "Spectral"), 
               names = c("10%", "20%", "30%", "40%", "50%", "60%", "70%", "80%",
                         "90%", "100%"))

dev.copy(jpeg, paste("totalBoxplot", ".jpeg", sep = ""))
dev.off()

write.csv(freq_holder, file = "total_boxplot.csv")
write.csv(times_crossed, file = "total_crossing_freq.csv")
write.csv(dist_bw_patches, file = "avg_dist.csv")
write.csv(avg_daily_dist, file = "avg_daily_dist.csv")

for (i in 1:10) {
  plot(dist_bw_patches[i,], freq_holder[i,], ylab = "Percent of unused forest", xlab = "Avg distance between forest patches")
  dev.copy(jpeg, paste("avg0byDist", i*10, ".jpeg", sep = ""))
  dev.off()
}
