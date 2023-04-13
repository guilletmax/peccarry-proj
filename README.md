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
## About The Project

### Model Purpose ###
We developed a spatially-explicit, discrete agent-based model evaluating changes in large mammal habitat-use patterns as a function of habitat loss and fragmentation, here simplified to be percent of forest cover, the number of forested fragments, and the distance between forest fragments (a measure of connectivity). The purpose of the model is to determine how different fragmentation and loss scenarios result in differential use of the landscape by large mammals. This model was programmed in R version 4.2.2.

### Empirical peccary movement data ###
TODO- think this needs to be refreshed with the new movement data we are using.
Model parameters that govern agent movement were derived from empirical movement data of white-lipped peccaries. Between 2013 and 2015, 12 white-lipped peccaries were captured and fitted with GPS collars in the southern Cerrado of central Brazil (Jorge et al. 2019). GPS locations were recorded every 3 to 6 hours through satellite transmission (Iridium). To quantify movement from GPS relocations, data were processed using adehabitatHR and adehabitatLS packages in R (Calenge 2006) to determine step length and relative turn angle (Bradham et al. unpublished). Step length is the straight-line distance between two GPS locations, while relative turn angle is the numerical change in angle between the continued trajectory direction from relocation one and the new trajectory direction from relocation two (Calenge 2006). Using Fitdistrplus package in R (Delignette-Muller and Dutang 2015) and associated AIC values, we established the empirical distributions that best fit the distribution of step lengths. The step lengths of all peccaries evaluated could be explained best by an exponential distribution. As the
rate parameter of the associated exponential distribution varied per peccary, we took the median value for use in the model. Relative angles were also fitted to distributions using R and all peccary step angles could be explained through a circular uniform distribution.

### Energy Habitat Data ###
TODO- summarize where the data came from for measuring growth rates of forests

### Variables
#### Inputs
1. percent forest cover
2. number of fragments
3. max distance between isolated forest units
#### Outputs
1. stuck rates
2. proportion of forest used
3. crossing
4. time in depleted state
#### Model Parameters
TBD

### Entitities, State Variables, and Scales ###
The landscape of the model is a grid of X by X cells, with each cell representing 30 m x 30 m. Each cell is either forested or matrix, and the number of times each forested cell is visited is stored. The model includes one type of agent, a single peccary herd, which moves across the landscape. The herds location is tracked in x and y in a cartesian coordinate system. Each time step represents a three-hour period. The model runs until the specified number of time is reached.

### Process Overview and Scheduling ###
Basic principles: This model couples the fragmentation threshold hypothesis with empirical movement data to better understand the impact of fragmentation on animal habitat-use patterns. Parameters for animal movement and rules governing movement as utilized in this model can be found in Jorge et al. (2019).
Emergence: The spatial orientation and distribution of habitat-use intensity (measured in the model as visitation frequency) emerges as a function of the specified percent forest cover, the number of forest fragments on the landscape, and the distance between fragments.
Sensing: Agents can discern between a forested cell and a matrix cell. Agents preferentially stay in the forest and cross the matrix only under certain conditions (e.g. if the random step length and angle result in a distance below the maximum threshold for crossing and a stochastic process that prompts peccaries to cross the matrix).
Stochasticity: The configuration of the initial landscape and the decision whether or not to
cross the matrix to arrive at another forested fragment are randomized.
Observation: For each fragmentation scenario and iteration, a csv file and an accompanying frequency histogram illustrate the distribution of visitation amount (i.e. visit count per cell). A csv file and an accompanying box plot show the percent of unvisited forested cells for each percent forest cover scenario. Finally, a csv file records the average distance between fragments and a scatterplot illustrates the number of unvisited forested cells as it relates to the distance between isolated forest fragments. In addition, the model generates a picture of the grid before a peccary herd has walked on it as well as the grid showing areas that are used more or less frequently after the peccary herd has walked over the landscape for the specified amount of time.

### Initialization ###
The model is initialized by first creating a landscape, a grid with the specified dimensions where all cells have the same state variable. Then, the model randomly selects a “seed” number between 1 and 4 depending on the fragmentation scenario. For one-fragment scenarios, the model randomly selects one cell on the landscape to be the seed cell. For two-fragment scenarios, the model randomly selects two cells on the landscape to be seed cells, and for three- and four-fragment scenarios, the model randomly selects three or four cells, respectively, as seed cells. Each seed cell converts their state variable to “forested”. Then, seed cells convert the state variables of adjacent cells (up, down, left, or right – to the exclusion of diagonally connected cells) to ‘forested’ until the desired percent forest cover is reached for the entire landscape (i.e. the whole grid). Each forested seed cell and connected forested cells now form a forest fragment. Forest fragments are not uniform in size. Initialization continues by randomly placing one agent on a forested cell. From this location, the agent will choose a distance and an angle (90˚, 180 ˚, 270 ˚, 360˚) to inform movement to another cell location. The step length that the agent will take to move is chosen from an Exponential distribution with rate parameter of 6.67, while turn angles are chosen from a circular uniform distribution, in the form of four equally likely angles: 90˚, 180 ˚, 270 ˚, 360˚. The state variable for number of visits for each forested landscape cell is initially set to 0, while the state variable for matrix cells is permanently set to ‘NA’.

### functions ###

_gen_grids_
- Generates the move_grid and forest_grid. The move_grid is initialized to an array of NA values. The forest_grid is created by generating random points for the center of each forest. Each forest grows until the maximum forest cover threshold is reached. 0s represent zells where the matrix exists, and numbers represent cells where the indicated forest exists.

_simulate_movement_
- Simulates the peccary movement. It places the peccaries in a random forested cell. It tracks the date, time, depletion_level, depleted_counter, non_depleted_counter, stuck_counter, crossed_matrix_counter, and total_distance. For every step (3 hours), the peccary attempts to move. A random direction (up, left, right, down) and a random distance following the functions specified in _calculate_walk_distance_ is chosen. If the peccary is able to move in this path (it stays in bounds and lands in a forested cell or within MAX_CROSSING_DISTANCE of a forested cell) it walks. If not, it will attempt to generate new random path. If it makes as many attempted as the STUCK_TIMER, the peccary will not move and the timestep advances.

_next_path_
- Generates the functions next movement path, based on a given starting point, direction, and distance. It also verifies that the path stays in bounds, and that there is a forest within the MAX_CROSSING_DISTANCE.

__forest_in_sight_
- Checks that the endpoint for a given path will keep the peccary within the MAX_CROSSING_DISTANCE of a forest if it lands in the matrix. 

_walk_
- Moves the peccary on the given path. It tracks whether or not the peccary crossed the matrix and updates the move_grid, depletion_sum, energy_grid, and crossed_matrix_counter.

_get_coor__
- Gets new coordinates given a starting point, direction, and distance.

_update_forest_id_
- TBD don't know if we need this, legacy code

_grow_forests_
- Grows the forests until the maximum forest cover threshold is achieved.

_get_path_
- Returns the list of cells that follow a path, based on a starting point, a direction, and a distance.

_calculate_walk_distance_
- Generates a distance for the peccaries to walk. It varies based on whether or not the peccary's energy is depleted and what time of the year it is. Based on (probably need to include the information here, but might be better for Michaela to explain the data we are using and the equations generated)

_calculate_season_
- Calculates whether it is wet or dry season based on the month.

_restore_cell_energy_
- Increases the energy stored at a cell by 25/100.

_next_month_
- Calculates the next month based on the current month.

_euc_distance_
- Calculates the euclidian distance between two points.

_avg_dist_forests_
- Calculates the average minimum distance between each forest on the map. (would like to review this)

<p align="right">(<a href="#top">back to top</a>)</p>
