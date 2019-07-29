# Save this script as sample_data.R!

source("./sample_grid.R")
source("./sample_rotation.R")

split_by_frac <- function(matrix, fractions){
    # Split matrices row wise according to fractions.

    # Values in fractions should sum up to one.
    if(sum(fractions) != 1){
        stop("Error: fractions need to sum up to one!")
    }

    # Check if all fractions provided
    if(length(fractions) != 3){
        stop("Error: You need to provide train, test and validation proportions.")
    }

    # Check if proportions in [0,1].
    if({fractions[1] < 0 || fractions[2] < 0 || fractions[2] < 0 ||
        fractions[1] > 1 || fractions[2] > 1 || fractions[2] > 1}){
        stop("Error: Proportions must be in [0,1].")
    }

    # Check if resulting subrows when rounded are > 1.
    if({ceiling(dim(matrix)[1] * fractions[1]) < 2 ||
        ceiling(dim(matrix)[1] * fractions[2]) < 2 ||
        ceiling(dim(matrix)[1] * fractions[3]) < 2}){
        stop("Error: You need a higher sample size or bigger fractions.")
    }

    result <- list()
    index_low <- 1
    index_high <- 0

    # Divide matrix into submatrices.
    for(i in 1:length(fractions)){
        index_high <- index_high + ceiling(dim(matrix)[1] * fractions[i])
        result[[i]] <- matrix[index_low:index_high,]
        index_low <- index_high + 1
    }

    return(result)
}

sample_samples <- function(dimension,
                        size,
                        train_prop,
                        test_prop,
                        val_prop){
    # Sample data in [-1,1]^dimension
    data <- matrix(nrow = size, ncol = dimension)

    for(i in 1:size){
      data[i,] <- sapply(rep(1,dimension), runif, min=-1, max=1)
    }

    # Split the result by fractions.
    return(split_by_frac(data, c(train_prop, test_prop, val_prop)))
}

sample_data <- function(dimension,
                        size,
                        layout,
                        train_prop,
                        test_prop,
                        val_prop){
    # Sample data according to split numbers defined in layout.

    # Sample data.
    samples <- sample_samples(dimension, size, train_prop, test_prop, val_prop)

    # Sample the grid and binary labels.
    grid <- sample_grid(layout)
    labels <- sample_binary_labels(layout)

    # Assign labels to train/test/val data.
    sample_labels <- list(numeric(dim(samples[[1]])[1]),
                          numeric(dim(samples[[2]])[1]),
                          numeric(dim(samples[[3]])[1]))

    for(i in 1:3){
        for(j in 1:dim(samples[[i]])[1]){
            partition <- assign_partition(grid, samples[[i]][j,])
            sample_labels[[i]][j] <- labels[[partition]]
        }
    }

    # Construct nested data list.
    data <- list(train = list(data = samples[[1]], labels = sample_labels[[1]]),
                 test = list(data = samples[[2]], labels = sample_labels[[2]]),
                 val = list(data = samples[[3]], labels = sample_labels[[3]]))

  return(data)
}

sample_data_capped <- function(dimension,
                               size,
                               cap,
                               train_prop,
                               test_prop,
                               val_prop){
    # Sample data but instead of providing a split layout, we provide a cap.

    # Sample a layout.
    splits <- c(1, sample(1:cap+1, dimension - 1, replace = TRUE), cap+1)
    splits <- sort(splits)
    layout <- diff(splits) + 1

    return(sample_data(dimension,
                       size,
                       layout,
                       train_prop,
                       test_prop,
                       val_prop))
}
