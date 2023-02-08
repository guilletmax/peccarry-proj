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

**functions**

_gen_grids_
- This method generates the move_grid and forest_grid. The move_grid is initialized to an array of NA values. The forest_grid is created by generating random points for the center of each forest. Each forest grows until the maximum forest cover threshold is reached. 0s represent zells where the matrix exists, and numbers represent cells where the indicated forest exists.

_simulate_movement_
- This method simulates the peccary movement. It places the peccaries in a random forested cell. It tracks the date, time, depletion_level, depleted_counter, non_depleted_counter, stuck_counter, crossed_matrix_counter, and total_distance. For every step (3 hours), the peccary attempts to move. A random direction (up, left, right, down) and a random distance following the functions specified in _calculate_walk_distance_ is chosen. If the peccary is able to move in this path (it stays in bounds and lands in a forested cell or within MAX_CROSSING_DISTANCE of a forested cell) it walks. If not, it will attempt to generate new random path. If it makes as many attempted as the STUCK_TIMER, the peccary will not move and the timestep advances.

_next_path_
- This method generates the functions next movement path, based on a given starting point, direction, and distance. It also verifies that the path stays in bounds, and that there is a forest within the MAX_CROSSING_DISTANCE.

__forest_in_sight_
- This method checks that the endpoint for a given path will keep the peccary within the MAX_CROSSING_DISTANCE of a forest if it lands in the matrix. 

_walk_
- This method moves the peccary on the given path. It tracks whether or not the peccary crossed the matrix and updates the move_grid, depletion_sum, energy_grid, and crossed_matrix_counter.

_get_coor__
- This helper method gets new coordinates given a starting point, direction, and distance.

_update_forest_id_
- TBD don't know if we need this, legacy code

_grow_forests_
- This method grows the forests until the maximum forest cover threshold is achieved.

_get_path_
- This method returns the list of cells that follow a path, based on a starting point, a direction, and a distance.

_calculate_walk_distance_
- This method generates a distance for the peccaries to walk. It varies based on whether or not the peccary's energy is depleted and what time of the year it is. Based on (probably need to include the information here, but might be better for Michaela to explain the data we are using and the equations generated)

_calculate_season_
- This helper function calculates whether it is wet or dry season based on the month.

_restore_cell_energy_
- This method increases the energy stored at a cell by 25/100.

_next_month_
- This helper function calculates the next month based on the current month.

_euc_distance_
- This helper function calculates the euclidian distance between two points.

_avg_dist_forests_
- This method calculates the average minimum distance between each forest on the map. (would like to review this)

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

This is an example of how you may give instructions on setting up your project locally.
To get a local copy up and running follow these simple example steps.

### Prerequisites

This is an example of how to list things you need to use the software and how to install them.
* npm
  ```sh
  npm install npm@latest -g
  ```

### Installation

1. Get a free API Key at [https://example.com](https://example.com)
2. Clone the repo
   ```sh
   git clone https://github.com/github_username/repo_name.git
   ```
3. Install NPM packages
   ```sh
   npm install
   ```
4. Enter your API in `config.js`
   ```js
   const API_KEY = 'ENTER YOUR API';
   ```

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

asdf

<p align="right">(<a href="#top">back to top</a>)</p>
