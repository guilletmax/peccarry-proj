# mg4.1
# Jen Bradham, Clara Yip, Max Guillet

# move_grid : holds the number of times a peccary has crossed each space
  # 0 = forested
# forest_id_grid : tracks forest id

# x_length        : x size of grid
# y_length        : y size of grid
# count_forest    : number of forests
# percent_forest  : percent of grid that is forested
# steps           : number of steps for simulation to run
# max_dist        : maximum distance a peccary can move in one step
# iter            : number of iterations

simulate_movement <- function(x_length, y_length, count_forest, percent_forest, 
                             steps, max_dist, iter) {
  library(plyr)
  library(RColorBrewer)
  library(car)
  library(fields)
  
  # gen_grids: Generates move_grid and forest_grid by placing forests in randomly sampled
  # coordinates. 
  gen_grids <- function() {
    
    for (i in 1:count_forest) {
      x <- sample(1:x_length, 1)
      y <- sample(1:y_length, 1)
      
      # check that location hasn't been set yet. if it has, find a new location
      while (!is.na(move_grid[x, y])) {
        x <- sample(1:x_length, 1)  
        y <- sample(1:y_length, 1)
      }
      
      #set move_grid to 0 (no peccary count)
      move_grid[x, y] <<- 0   
      
      #set forest_id_grid to the forest id i
      forest_id_grid[x, y] <<- i
      
      #update the forst id
      update_forest_id(x, y)
      x_forested <<- c(x_forested, x)
      y_forested <<- c(y_forested, y)
    }
    
  }

  # in_bounds: verifies x and y coordinates are in bounds of grid
  in_bounds <- function(x, y) {
    check_x <- (x > 0) && (x <= x_length)
    check_y <- (y > 0) && (y <= y_length)
    return (check_x && check_y) 
  }

  # get_coor: Gets the new coordinate after move (1, 2, 3, 4 = left, up, right, down)
  get_coor <- function(x, y, direction, distance) {
    if (direction == 1) {
      new_coor <- c(x - distance, y)
    } else if (direction == 2) {
      new_coor <- c(x, y + distance)
    } else if (direction == 3) {
      new_coor <- c(x + distance, y)
    } else {
      new_coor <- c(x, y - distance)
    }
    return(new_coor)  
  }

  # update_forest_id : sets neighboring forest cells to same forest id
  update_forest_id <- function(cur_x, cur_y) {
    # cur_num is the forest id
    cur_num <- forest_id_grid[cur_x, cur_y]
    left <- get_coor(cur_x, cur_y, 1, 1)
    up <- get_coor(cur_x, cur_y, 2, 1)
    right <- get_coor(cur_x, cur_y, 3, 1)
    down <- get_coor(cur_x, cur_y, 4, 1)
    
    if (in_bounds(left[1], left[2]) && forest_id_grid[left[1], left[2]] != 0 && 
        forest_id_grid[left[1], left[2]] != cur_num) {
      forest_id_grid[forest_id_grid==forest_id_grid[left[1], left[2]]] <<- 
        cur_num
    } else if (in_bounds(up[1], up[2]) &&  forest_id_grid[up[1], up[2]] != 0 && 
               forest_id_grid[up[1], up[2]] != cur_num) {
      forest_id_grid[forest_id_grid== forest_id_grid[up[1], up[2]]] <<- cur_num
    } else if (in_bounds(right[1], right[2]) && forest_id_grid[right[1], 
                                                               right[2]] != 0 &&
               forest_id_grid[right[1], right[2]] != cur_num) {
      forest_id_grid[forest_id_grid==forest_id_grid[right[1], right[2]]] <<- 
        cur_num
    } else if (in_bounds(down[1], down[2]) && forest_id_grid[down[1], down[2]] 
               != 0 && forest_id_grid[down[1], down[2]] != cur_num) {
      forest_id_grid[forest_id_grid==forest_id_grid[down[1], down[2]]] <<- 
        cur_num
    }
  }

  # grow_forests: grows forests until desired percent forest cover is reached
  grow_forests <- function() {
    expected_count_forest <- as.integer(percent_forest / 100 * area)
    for (i in 1:(expected_count_forest - count_forest)) {
      added <- FALSE
      while (!added) {
        index <- sample(1:length(x_forested), 1)
        x <- x_forested[index]
        y <- y_forested[index]
        direction <- sample(1:4, 1)
        to_add <- get_coor(x, y, direction, 1)
        next_x <- to_add[1]
        next_y <- to_add[2]
        if (in_bounds(next_x, next_y) && is.na(move_grid[next_x, next_y])) {
          move_grid[next_x, next_y] <<- 0
          forest_id_grid[next_x, next_y] <<- forest_id_grid[x,y]  
          update_forest_id(next_x, next_y)
          x_forested <<- c(x_forested, next_x)
          y_forested <<- c(y_forested, next_y)
          added <- TRUE 
        }
      }
    }
  }
  
  # get_path: returns list of cells on path
  get_path <- function(x_orig, y_orig, direction, dist) {
    x_path <- c()
    y_path <- c()
    x <- x_orig
    y <- y_orig
    for (i in 1:dist) {
      nextCoor <- get_coor(x, y, direction, 1)
      x <- nextCoor[1]
      y <- nextCoor[2]
      x_path <- c(x_path, x)
      y_path <- c(y_path, y)
    }
    return(rbind(x_path, y_path))
  }

  ## all_forest: check if every cell in the path is forested
  all_forest <- function(path) {
    xPath <- path[1,]
    yPath <- path[2,]
    for (i in 1:length(xPath)) {
      if (is.na(move_grid[xPath[i], yPath[i]])) {
        return(FALSE)
      }
    }
    return(TRUE)
  }

  # count_nonforested: counts number of cells in  path that are non-forested
  count_nonforested <- function(path) {
    x_coors <- path[1, ]
    y_coors <- path[2, ]
    len <- length(x_coors)
    counter <- 0
    for (i in 1:len) {
      if (is.na(move_grid[x_coors[i], y_coors[i]])) {
        counter <- counter + 1
      }
    }
    return(counter)
  }

  
  ## choose_cross: peccary decides whether or not to cross nonforested cell
  choose_cross <- function(path, dist) {
    if (count_nonforested(path) > 0.25 * max_dist) {
      return(rbind(path[1], path[2]))  #stay
    } else {
      decision <- sample(1:2, 1)
      if (decision == 1) {  #stay
        return(rbind(path[1], path[2]))
      } else { #cross
        crossed <<- crossed + 1
        return(path)
      }
    }
  }

  
  # next_path: generate next path
  next_path <- function(x, y, direction, dist) {
    endpoint <- get_coor(x, y, direction, dist)
    
    # verify endpoint is forested
    if (in_bounds(endpoint[1], endpoint[2]) && !is.na(move_grid[endpoint[1], 
                                                                endpoint[2]])) {
      path <- get_path(x, y, direction, dist)
      if (all_forest(path)) {
        return(path)
      } else {
        return(choose_cross(path, dist))
      }
    }
    return(c())
  }

  
  # walk: peccary walks a given path
  walk <- function(path) {
    x_coors <- path[1,]
    y_coors <- path[2,]
    len <- length(x_coors)
    
    for (i in 1:len) {
      if ((!is.na(move_grid[x_coors[i], y_coors[i]]))) {
        move_grid[x_coors[i], y_coors[i]] <<- move_grid[x_coors[i], 
                                                        y_coors[i]] + 1
      }
    }
    last <- c(x_coors[len], y_coors[len])
    return(last)
  }

   
  # simulate_movement: ***This is a simulatemovement function within the larger simulatemovement function? What is this part specifically doing?
  # Choose a starting coordinate from the percent_forest array. For each step, ...?
  simulate_movement <- function() {
    start_index <- sample(1:length(x_forested), 1)
    start_x <- x_forested[start_index]
    start_y <- y_forested[start_index]
    energy <- 0
    energy_vector <- c()
    season <- 1
    time <- 1
    move_prob <- calc_move_prob(season, time)
  
    for (i in 1:steps) {
      #update season every 90 days
      if(i %% 1080 == 0) {
        season <- next_season(season)
      }
      
      #update time of day every 6 hours
      if(i %% 3 == 0) {
        time <- next_time_of_day(time)
        move_prob <- calc_move_prob(season, time)
      }
      
      if (sample(c(TRUE, FALSE), prob = c(move_prob, (1 - move_prob)))[1]) {
        direction <- sample(1:4, 1)
        dist <- as.integer(rexp(1,rate = 6.672) * max_dist) + 1
        path <- next_path(start_x, start_y, direction, dist)
        while (is.null(path)) {
          direction <- sample(1:4, 1)
          dist <- as.integer(rexp(1,rate = 6.672) * max_dist) + 1
          path <- next_path(start_x, start_y, direction, dist)
        }
        energy <- energy - calc_energy_loss(dist)
        energy <- energy + calc_energy_gain(path)
        end_index <- walk(path)
        start_x <- end_index[1]
        start_y <- end_index[2]
      } else {
        # energy lost at basal metabolic rate
        energy <- energy - 1418.6
      }
      energy_vector[i] <- energy
    }
    plot(1:steps, energy_vector)
  }
  
  # calculate probability that peccary moves based on season and time
  calc_move_prob <- function(season, time) {
    if(season == 1) {
      return(switch(time, 0.15, 0.33, 0.35, 0.17))
    } else if(season == 2 || season == 4) {
      return(switch(time, .15, .42, .24, .16))
    } else {
      return(switch(time, .3, .22, .12, .333))
    }
  }
  
  # calculate the next season 1, 2, 3, 4 = winter, spring, summer, fall
  next_season <- function(curr_season) {
    return(if(curr_season == 4) 1 else curr_season + 1)
  }
  
  # calculate the next time of day 1, 2, 3, 4 = morning, afternoon, evening, night
  next_time_of_day <- function(curr_time) {
    return(if(curr_time == 4) 1 else curr_time + 1)
  }
  
  # calculate the energy gained by walking certain path
  calc_energy_gain <- function(path) {
    energy <- 0
    
    for(i in seq(from=1, to=length(path), by=2)) {
      if(forest_id_grid[path[i], path[i + 1]] != 0) {
        energy <- energy + (9.28 * 665 * 4.8)
      }
    }
    return(energy)
  }
  
  # calculate the energy lost for walking a distance
  calc_energy_loss <- function(distance) {
    return((5.8 * (1435)^(0.75) * 2) + (2.6 * (1435)^(0.6) * (distance * 4.8)))
  }
  
  euc_distance <- function(p1, p2) sqrt(sum((p1 - p2)^2))
  
  # calculate the average minimum distance between each forest
  avg_dist_forests <- function() {
    forests <- sort(unique(as.vector(forest_id_grid)))[-1]
    patch_num <- length(forests)
    total_dist <- 0
    count <- 0
    if(patch_num == 1) {
      return(0)
    }
    for(i in 1:(patch_num - 1)) {
      for(j in (i+1):patch_num) {
        forest_i <- which(forest_id_grid == i, arr.ind=TRUE)
        forest_j <- which(forest_id_grid == j, arr.ind=TRUE)
        
        # find min distance between forest_i and forest_j
        min_distance <- 999999999.0
        for(n in nrow(forest_i)) {
          for(m in nrow(forest_j)) {
            curr_distance <- euc_distance(forest_i[n,], forest_j[m,])
            if(curr_distance < min_distance) {
              min_distance <- curr_distance
            }
          }
        }
        total_dist <- (total_dist + min_distance)
        count <- count + 1
      }
    }
    min_avg_dist <- total_dist / count
  }
  
  
  
   # avg_dist_forests: calculates mean distance between forests
   avg_dist_forests_old <- function() {
     forests <- sort(unique(as.vector(forest_id_grid)), decreasing = FALSE)
     patch_num <- length(forests) - 1
     
     if(patch_num == 0 || patch_num == 1) {
       return(0)
     }
     
     
     # what is this doing ??
     # renumber patches in forest_id_grid
     ord <- 0:patch_num
     for (i in 1:length(forests)) {
       forest_id_grid[forest_id_grid == forests[i]] <<- ord[i]
     }
     
     patch_vecs <- matrix(rep(list(), patch_num * 2), nrow = patch_num, ncol = 2)
     
     # for every forested patch, add to corresponding list 
     for (i in 1:length(x_forested)) {
       num <- forest_id_grid[x_forested[i], y_forested[i]]
       patch_vecs[[num]] <- c(patch_vecs[[num]], x_forested[i])
       patch_vecs[[num + patch_num]] <- c(patch_vecs[[num + patch_num]], 
                                        y_forested[i])
     }
     
     plot(x_forested, y_forested)
     
     patch_conf <- matrix(rep(list(), patch_num), nrow = patch_num, ncol = 1)
     
     # draw ellipse for each patch
     for (i in 1:patch_num) {
       patch_vecs
       patch_vecs[[i + patch_num]]
       patch_conf[[i]] <-  dataEllipse(patch_vecs[[i]], 
                                       patch_vecs[[i + patch_num]], levels=c(0.8), 
                                       center.pch=19, center.cex=1.5, 
                                       plot.points=FALSE)
     }
     
     # calc distance min distance between patch ellipses
     
     if (patch_num == 1) {
       return(0)
     } else {
       dist_holder <- vector()
       for (i in 1:patch_num) {
         for (j in 1:patch_num) {
           if (i != j && i < j) {
             min_dist <- min(rdist(patch_conf[[i]], patch_conf[[j]])) 
             dist_holder <- c(dist_holder, min_dist)
           }
         }
       }
       return(mean(dist_holder))
     }
  }

  # START MODEL
  
  # generate matrices for landscape and movement
  move_grid <- matrix(NA, nrow = x_length, ncol = y_length)
  forest_id_grid <- matrix(0L, nrow = x_length, ncol = y_length)
  
  # generate grids
  x_forested <- vector()
  y_forested <- vector()
  gen_grids()
  
  # grow forests
  area <- x_length * y_length
  if (percent_forest > 100 || percent_forest < (count_forest / area)) {
    print("percent percent_forest invalid")
    break
  }
  grow_forests()
  
  # save & output results to file_name
  file_name <- paste("Uniform", toString(count_forest), 
                     toString(percent_forest), toString(steps), iter, sep="_")
  
  # create/save the 'before' map visual 
  grid_1 <- replace(move_grid, is.na(move_grid), -10)
  img <- image(1:x_length, 1:y_length, grid_1, col =  brewer.pal(3, "OrRd")) 
  file_name_jpg_map <- paste(file_name, "move_grid", "before", ".jpeg", sep = "")
  dev.copy(jpeg, file_name_jpg_map)
  dev.off()
  
  crossed <- 0
  simulate_movement()
  avg_dist <- avg_dist_forests()
  
  # create/save the 'post' map visual 
  grid_1 <- replace(move_grid, is.na(move_grid), -10)
  img <- image(1:x_length, 1:y_length, grid_1, col =  brewer.pal(9, "OrRd")) 
  file_name_jpg_map <- paste(file_name, "move_grid", "post", ".jpeg", sep = "")
  dev.copy(jpeg, file_name_jpg_map)
  dev.off()
  
  # create/save histogram recording the frequency distribution of hit cells
  hist(move_grid, freq=TRUE, xlab = "Number of times treaded", col = 
         brewer.pal(10, "Spectral"), breaks = 20,  xlim = c(0,120), 
       ylim = c(0,4000))
  file_name_jpg_hist <- paste(file_name, "hist", ".jpeg", sep = "")
  dev.copy(jpeg, file_name_jpg_hist)
  dev.off()
  
  # create/save frequency table of number of cell hits and their frequency of 
  # occurence --> *** same data as histogram uses, correct?
  max_tread <- max(move_grid, na.rm =TRUE)
  nums <- c(0:max_tread)
  freq_all <- count(as.vector(move_grid))
  freq_0 <- freq_all[1,2]
  frequencies <- c(freq_0, tabulate(as.vector(move_grid)))
  freq <- setNames(frequencies, nums)
  expected_count_forest <- as.integer(percent_forest/100 * area)
  percents <- frequencies/as.integer(expected_count_forest)
  freq = rbind(freq, percents)
  file_name_csv <- paste(file_name, "freq", ".csv", sep = "")
  write.csv(freq, file = file_name_csv)
  
  return(c(freq[2,1], crossed, avg_dist)) 
}

