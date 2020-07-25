# Save this script as sample_grid.R!

sample_grid <- function(layout){
    # Samples a grid according to layout sequence. Layout sets number of splits
    # regarding each dimension.

    # Sample the splits.
    grid <- lapply(layout-1, runif, min=-1,max=1)
    grid <- lapply(grid, sort)

    # Clear numeric(0) if no split was given to a dimension.
    for(i in 1:length(layout)){
        if(length(grid[[i]]) == 0){
            grid[[i]] <- NA
        }
    }

    return(grid)
}

assign_partition <- function(grid, point){
    # Assigns the corresponding partition region in a grid given a point in the
    # form of a sequence.

    # Define dimension and initialize data structure.
    n <- length(grid)
    partition_region <- numeric(n)

    for(i in 1:n){
    # Find the split point.
    which <- which(grid[[i]] < point[i])

    # Define the index of the split.
    if (length(which) == 0){
        index <- 1                        # 1 as numbering should start with 1.
    }else{
        index <- tail(which, n=1) + 1     # +1 as numbering should start with 1.
    }
    partition_region[i] <- index
    }

    return(partition_region)
}

sample_binary_labels <- function(layout){
    # Sample binary labels for each partition region. Expects a sequence.
    
    # Stop condition for recursion
    if(length(layout) == 0){
        return(sample(c(0,1),1))
    }

    # Define data structures.
    tree <- list()
    number_of_children <- layout[1]

    for(i in 1:number_of_children){
        # Recursive call to go to next dimension.
        tree[[i]] <- sample_binary_labels(layout[-1])
    }

    return(tree)
}
