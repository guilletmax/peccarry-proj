<div id="top"></div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## Overview

### 1. Model Purpose ###
We developed a spatially-explicit, discrete agent-based model evaluating changes in large mammal habitat-use patterns as a function of habitat loss and fragmentation, here simplified to be represented by percentage of the landscape with forest cover, the number of forest fragments, and the distance between forest fragments (a measure of connectivity). The purpose of the model is to determine how different fragmentation and loss scenarios result in differential use of the landscape by large mammals, primarily by examining how the proportion of forested cells used by model agents changes in response to our habitat loss and fragmentation scenarios. This model was designed with white-lipped peccaries (Tayassu pecari) in mind, but may be parameterized with empirical movement data from other species, in order to identify thresholds of forest loss and fragmentation beyond which landscape connectivity breaks down for the species in question.

### 2. Entities, state variables, and scales ###
The landscape of the model is a grid of 167 x 167 cells (this is specified as an input), with each cell representing 30 m x 30 m. Each cell is either forested or matrix, and the number of times each forested cell is visited is stored. 
The model includes one type of agent, a single peccary herd, which moves across the landscape. The herd’s location is tracked in x and y in a cartesian coordinate system across the landscape. The peccary herd may be either in a short-range or long-range foraging state, which determines whether its step-lengths are drawn from the head or the tail of its step-length distributions. 
Time in the model moves in increments of timesteps represents three-hour periods. The model runs until the specified number of timesteps is reached. Our model includes two seasons, the wet season and the dry season. The season changes every six months, and the parameters controlling the peccary herd’s movement are dependent on the season.

### 3. Process overview and scheduling ###
1.	Time is updated
The current month is updated every 240 timesteps. Every six months pass, the season switches between wet and dry.
2.	Patches update depletion level
Every 30 timesteps, every forested patch which is fully or partially depleted regains 25% of its resources.
3.	Peccary herd chooses a step-length and turn angle
Depending on the season and their current foraging state, the peccary herd chooses a step-length from a certain distribution. The herd also chooses a turn angle from a circular uniform distribution. The model determines whether the patch that the chosen direction and step-length leads to is a viable choice. If not, the herd remains in place until the next timestep.
a.	‘Stuck’ sub-routine
After 10 timesteps in which the peccary herd fails to move, the model enters the stuck state, in which time stops moving forward until a viable step-length and turn angle combination is chosen. The number of attempts it takes to choose a viable step-length and turn angle is recorded.
4.	Peccary herd updates foraging state
Based on the average depletion level of all the patches it passed through in step 2, the peccary herd’s foraging state is updated. 
5.	Patches in path update number of times visited and depletion level
Every forested cell a peccary herd crossed through in the previous step has one visitation added to its total number of visitations. Every forested cell the herd crossed through also loses 25% of its resources.

## Design

### 4. Design concepts ###
_Basic principles_: This model couples the fragmentation threshold hypothesis with empirical movement data to better understand the impact of fragmentation on animal habitat-use patterns. Parameters for animal movement and rules governing movement as utilized in this model can be found in Jorge et al. (2019).
 _Emergence_: The spatial configuration and distribution of habitat-use intensity (measured in the model as visitation frequency) emerges as a function of the specified percent forest cover, the number of forest fragments on the landscape, and the distance between fragments. 
_Adaptation_: Agents decide whether to shift between the short-range and long-range movement states depending on the average resource level of the patches surrounding them. 
_Prediction_: When deciding whether or not to enter the matrix, agents make a prediction as to whether continuing in the same direction in subsequent steps would result in them exiting the matrix without exceeding the maximum matrix crossing distance. If not, they do not enter the matrix.
_Sensing_: Agents can discern between a forested cell and a matrix cell. Agents preferentially stay in the forest and cross the matrix only under certain conditions (e.g. if the random step length and angle result in a distance below the maximum threshold for crossing and a stochastic process that prompts peccaries to cross the matrix). 
_Stochasticity_: The configuration of the initial landscape and the decisions on turn angle and step length are randomized.
_Observation_: For each iteration of the model, a .csv file and an accompanying frequency histogram illustrate the distribution of ‘tread counts’ (i.e. visit count per cell) for each forest cell on the landscape. In addition, the model generates a picture of the grid before a peccary herd has walked on it as well as the grid showing areas that are used more or less frequently after the peccary herd has walked over the landscape for the specified amount of time. At the end of a set of simulations, for which the number of runs at each level of forest cover is specified, the model generates .csv files recording the following values for each iteration: (i) the amount forest cells in the landscape that were never visited, (ii) the number of times animals successfully cross the matrix, (iii) the time-steps spent in the short-range vs. long-range foraging states, (iv) the total distance the animals travel over the course of the simulation, (v) the frequency and duration of ‘stuck’ bouts, and (vi) the maximum distance between forest fragments on the landscape.

## Details

### 5. Initialization ###
The model is initialized by first creating a landscape, a grid with the specified dimensions where all cells have the same state variable. Then, the model randomly selects a “seed” number between 1 and 4 depending on the fragmentation scenario. For one-fragment scenarios, the model randomly selects one cell on the landscape to be the seed cell. For two-fragment scenarios, the model randomly selects two cells on the landscape to be seed cells, and for three- and four-fragment scenarios, the model randomly selects three or four cells, respectively, as seed cells. Each seed cell converts their state variable to “forested”. Then, seed cells convert the state variables of adjacent cells (up, down, left, or right – to the exclusion of diagonally connected cells) to ‘forested’ until the desired percent forest cover is reached for the entire landscape (i.e. the whole grid). Each forested seed cell and connected forested cells now form a forest fragment. Forest fragments are not uniform in size. Initialization continues by randomly placing one agent, a peccary herd, on a forested cell. From this location, the herd will choose a distance and an angle to inform movement to another cell location. The step length that the herd will take to move is chosen from an Exponential distribution with rate parameter of 6.67, while turn angles are chosen from a circular uniform distribution, in the form of eight equally likely angles: 45° 90°, 135°, 180°, 225°, 270°, 315°, and 360°. The state variable for number of visits for each forested landscape cell is initially set to 0, while the state variable for matrix cells is permanently set to ‘NA’. The peccary herd is initially in the short-range foraging state. 

### 6. Input data ###
_Model Parameters_
1.	x_length, x size of grid
2.	y_length, y size of grid
3.	count_forest, number of forest seeds
4.	years, number of years for model to run
5.	max_iter, number of iterations at each forest cover percentage
6.	depletion_level_cutoff, constant that determines the cutoff for a depleted peccary state
7.	stuck_timer, number of consecutive iterations in a depleted state to establish a stuck state
8.	max_crossing_distance, maximum amount of distance a peccary must be from another forested cell in order to travel

### 7. Submodels ###
Functions
1.	gen_grids: Generates the move_grid and forest_grid. The move_grid is initialized to an array of NA values. The forest_grid is created by generating random points for the center of each forest. Each forest grows until the maximum forest cover threshold is reached. 0s represent zells where the matrix exists, and numbers represent cells where the indicated forest exists.
2.	simulate_movement: Simulates the peccary movement. It places the peccaries in a random forested cell. It tracks the date, time, depletion_level, depleted_counter, non_depleted_counter, stuck_counter, crossed_matrix_counter, and total_distance. For every step (3 hours), the peccary attempts to move. A random direction and a random distance following the functions specified in calculate_walk_distance is chosen. If the peccary is able to move in this path (it stays in bounds and lands in a forested cell or within MAX_CROSSING_DISTANCE of a forested cell) it walks. If not, it will attempt to generate new random path. If it makes as many attempted as the STUCK_TIMER, the peccary will not move and the timestep advances.
3.	next_path: Generates the functions next movement path, based on a given starting point, direction, and distance. It also verifies that the path stays in bounds, and that there is a forest within the MAX_CROSSING_DISTANCE.
4.	_forest_in_sight: 5Checks that the endpoint for a given path will keep the peccary within the MAX_CROSSING_DISTANCE of a forest if it lands in the matrix.
5.	walk: Moves the peccary on the given path. It tracks whether or not the peccary crossed the matrix and updates the move_grid, depletion_sum, energy_grid, and crossed_matrix_counter.
6.	get_diag_dist: Calculates the distance peccaries move in the case that they choose a turn angle of 45°, 135°, 225°, or 315°.
7.	get_coor_: Gets new coordinates given a starting point, direction, and distance.
8.	update_forest_id: Sets neighboring forest cells to the same value for forest_id.
9.	grow_forests: Grows the forests until the maximum forest cover threshold is achieved.
10.	merge_forests: Merges the forests so connected forests share the same id.
11.	merge_direction: A helper function for merge_forests which checks cells in the given direction to merge the forests.
12.	get_path: Returns the list of cells that follow a path, based on a starting point, a direction, and a distance.
13.	calculate_walk_distance: Generates a distance for the peccaries to walk. It varies based on the peccary herd’s foraging state and what time of the year it is. Distances are drawn from either the head (short-range foraging state) or tail (long-range foraging state) of two generalized Pareto distributions, fit to GPS collar data collected for white-lipped peccaries in either the wet or dry season.
14.	 calculate_season: Calculates whether it is wet or dry season based on the month.
15.	 restore_cell_energy: Increases the energy stored at a cell by 25/100.
16.	 next_month: Calculates the next month based on the current month.
17.	 euc_distance: Calculates the euclidean distance between two points.
18.	 avg_dist_forests: Calculates the average minimum distance between each forest on the map.
19.	max_dist_bw_forests: Calculates the maximum distance between two forests on the map.


<p align="right">(<a href="#top">back to top</a>)</p>
