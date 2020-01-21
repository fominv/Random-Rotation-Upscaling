 <font color="red">**NOTE:**</font> This repository may be out of date. It will not be changed however, as it is linked to the corresponding paper. For an updated repository visit [here](https://gitea.fomin.xyz/vfomin/Random_Rotation_Upscaling)!
 
 ***

# Random Rotation Upscaling

This repository contains files necessary to perform the simulation study on Random Rotation Upscaling in my master thesis.

### How to use this repository?

Install the dependencies commented in `simulation_study.R` and run the script. To obtain the same data set as presented in the thesis run `construct_data_set.R` afterwards. Optionally, the full data set obtained from the high performance computing cluster Leonhard is provided in the file `data_full_simulation.Rdata`.

### How to run a quick test to check if the code really works?

Uncomment lines 15-17 in `simulation_study.R`. The quick test takes around 10 minutes to complete.
