# Random Rotation Upscaling

This repository contains files necessary to perform the simulation study on Random Rotation Upscaling in the master thesis *The Effect of Random Rotation Upscaling on Neural Networks and Gradient Boosted Trees*, which can be found [here](/The_Effect_of_Random_Rotation_Upscaling_on_Neural_Networks_and_Gradient_Boosted_Trees-Vladimir_Fomin.pdf?raw=true).

### How to use this repository?

Install the dependencies commented in `src/simulation_study.R` and run the script. To obtain the same data set as presented in the thesis run `src/construct_data_set.R` afterwards. Optionally, the full data set obtained from the high performance computing cluster Leonhard is provided in the file `data_full_simulation.Rdata`.

### How to run a quick test to check if the code really works?

Uncomment lines 15-17 in `src/simulation_study.R`. The quick test takes around 10 minutes to complete.
