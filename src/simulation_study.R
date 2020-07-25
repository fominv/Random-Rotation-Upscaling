# Save this script as simulation_study.R!

library(keras)
library(xgboost)

source("./sample_data.R")
source("./seeds.R")

# Define dimensions, cap and seeds.
dimensions <- c(10,50,100,250,500)
cap <- 5:16
seeds <- get_seeds()

# Test Run dimensions, cap and seeds. Uncomment to the test the code!
#dimensions <- c(10,50)
#cap <- 10:11
#seeds <- get_seeds()[c(1,2)]

# Define sample parameters.
size = 12500
train_prop = 0.8
val_prop = 0.1
test_prop = 0.1

# Define relevant data structures.
simulation_output <- list()

gb_result <- list(test = list(), 
                  accuracy = list(), 
                  max_accuracy = list(), 
                  max_index = list())
nn_result <- list(test = list(), 
                  accuracy = list(), 
                  max_accuracy = list(), 
                  max_index = list())

for(i in 1:length(dimensions)){
    gb_result$test[[i]] <- list()
    gb_result$accuracy[[i]] <- list()
    gb_result$max_accuracy[[i]] <- numeric(length(seeds))
    gb_result$max_index[[i]] <- numeric(length(seeds))
    nn_result$test[[i]] <- list()
    nn_result$accuracy[[i]] <- list()
    nn_result$max_accuracy[[i]] <- numeric(length(seeds))
    nn_result$max_index[[i]] <- numeric(length(seeds))
}

# Define accuracy of test data for xgboost.
calculate_accuracy <- function(model, new_data){
    prediction <- predict(model, new_data$data)
    prediction <- as.numeric(prediction > 0.5)
    error <- mean(prediction != new_data$label)
    return(1-error)
}

# Define xgboost model parameters.
boosting_rounds <- 2000

args <- list()

args$max.depth <- 8
args$eta <- 0.1
args$nthread <- 2
args$nrounds <- boosting_rounds
args$subsample <- 0.8
args$verbose <- 0
args$objective <- "binary:logistic"

# For gpu support uncomment
# args$tree_method <- "gpu_hist"

args$early_stopping_rounds <- 50
args$xgb_model <- NULL

# Function to initialize the keras model.
init_nn_model <- function(dimension){
    model <- keras_model_sequential() %>%
        layer_dense(units = 500, activation = "sigmoid", 
                    input_shape = c(dimension)) %>%
        layer_dense(units = 250, activation = "relu") %>%
        layer_dense(units = 100, activation = "relu") %>%
        layer_dense(units = 50, activation = "relu") %>%
        layer_dense(units = 1, activation = "sigmoid")

    model %>% compile(
        optimizer = "rmsprop",
        loss = "binary_crossentropy",
        metrics = c("accuracy")
    )

    return(model)
}

# Define additional keras parameters.
epochs = 2000
batch_size = 500

# Loop of over all configurations.
for(c in cap){
for(j in 1:length(seeds)){
    # Set the appropriate seed.
    use_session_with_seed(seeds[j],
                          disable_gpu = FALSE,
                          disable_parallel_cpu = FALSE)

    # Sample the data and rotated data.
    data <- list()

    # dimensions[[1]] data.
    c(train, test, val) %<-% sample_data_capped(dimensions[1], size, c,
                                                train_prop, test_prop, val_prop)

    data[[1]] <- list(train = train, test = test, val = val)

    # Prepare rotated data.
    data_index <- 2
    for(dim in dimensions[-1]){
        train$data <- cbind(
            data[[1]]$train$data, 
            matrix(0, nrow = dim(data[[1]]$train$data)[1], 
                   ncol = dim - dimensions[1]))
        test$data <- cbind(
            data[[1]]$test$data, 
            matrix(0, nrow = dim(data[[1]]$test$data)[1], 
                   ncol = dim - dimensions[1]))
        val$data <- cbind(
            data[[1]]$val$data, 
            matrix(0, nrow = dim(data[[1]]$val$data)[1], 
                   ncol = dim - dimensions[1]))

        ### Sample the rotation.
        rotation <- sample_rotation(dim)

        train$data <- t(apply(train$data, 1,rotate, rotation=rotation))
        test$data <- t(apply(test$data, 1,rotate, rotation=rotation))
        val$data <- t(apply(val$data, 1,rotate, rotation=rotation))

        data[[data_index]] <- list(train = train, test = test, val = val)
        data_index <- data_index + 1
    }

    # Train xgboost and keras.
    # Loop over the different dimensions.
    for(i in 1:length(data)){
        # XGboost.
        # Define missing model parameters.
        args$data <- xgb.DMatrix(data = data[[i]]$train$data,
                                 label = data[[i]]$train$labels)

        val <- xgb.DMatrix(data = data[[i]]$val$data,
                           label = data[[i]]$val$labels)

        args$watchlist <- list(train=args$data, test=val)

        # Fit the model.
        gb_model <- do.call(xgb.train, args)

        # Exctract relevant data.
        gb_result$accuracy[[i]][[j]] <- 1 - gb_model$evaluation_log$test_error
        gb_result$test[[i]][[j]] <- calculate_accuracy(gb_model, test)

        gb_result$max_accuracy[[i]][j] <- max(
            1 - gb_model$evaluation_log$test_error)
        gb_result$max_index[[i]][j] <- which.max(
            1 - gb_model$evaluation_log$test_error)

        # Keras.
        # Initialize Neural Network.
        nn_model <- init_nn_model(dimensions[i])

        # Fit the model.
        nn_model %>% fit(data[[i]]$train$data,
                         data[[i]]$train$labels,
                         epochs = epochs,
                         batch_size = batch_size,
                         validation_data = list(data[[i]]$val$data,
                                                data[[i]]$val$labels),
                         verbose = 0,
                         callbacks = list(callback_early_stopping(
                             monitor = "val_acc",
                             min_delta = 0.01, 
                             patience = 50, 
                             verbose = 1)))

        # Exctract relevant data.
        nn_result$accuracy[[i]][[j]] <- nn_model$history$history$val_acc
        nn_result$test[[i]][[j]] <- evaluate(nn_model, 
                                             data[[i]]$test$data, 
                                             data[[i]]$test$labels)

        nn_result$max_accuracy[[i]][j] <- max(
            as.numeric(nn_model$history$history$val_acc))
        nn_result$max_index[[i]][j] <- which.max(
            as.numeric(nn_model$history$history$val_acc))
    }
}

# Combine all results into final output.
simulation_output[[c - cap[1] + 1]] <- list(NN = nn_result, GB = gb_result)
}

# Save relevant variables for further processing.
save(list = c("simulation_output",
              "seeds",
              "cap",
              "dimensions"),
     file = "./simulation_output.Rdata")
