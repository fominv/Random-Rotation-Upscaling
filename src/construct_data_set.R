# Save this script as construct_data_set.R!

load("./simulation_output.Rdata")

# Define data frame.
data <- data.frame(matrix(NA,
                          ncol = 5,
                          nrow = length(seeds) * length(dimensions) * length(cap)))

colnames(data) <- c("Accuracy", "Index", "Type", "Dimension", "Splits")

# Fill data frame.
data_index <- 1
for(c in 1:length(cap)){
    for(name in c("GB", "NN")){
        for(sample in 1:length(seeds)){
            for(dim in 1:length(dimensions)){
                dummy <- simulation_output[[c]][[name]]

                data[data_index, "Accuracy"] <- dummy$max_accuracy[[dim]][sample]
                data[data_index, "Index"] <- dummy$max_index[[dim]][sample]
                data[data_index, "Type"] <- name
                data[data_index, "Dimension"] <- dimensions[dim]
                data[data_index, "Splits"] <- cap[c]

                data_index <- data_index + 1
            }
        }
    }
}

save(data, file = "./data.Rdata")