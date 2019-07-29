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

# Initialize Neural Network.
nn_model <- init_nn_model(dimensions[i])

# Fit the model.
nn_model %>% fit(data[[i]]$train$data,
                 data[[i]]$train$labels,
                 epochs = 2000,
                 batch_size = 500,
                 validation_data = list(data[[i]]$val$data,
                                        data[[i]]$val$labels),
                 verbose = 0,
                 callbacks = list(callback_early_stopping(
                     monitor = "val_acc",
                     min_delta = 0.01, 
                     patience = 50, 
                     verbose = 1)))


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
args$early_stopping_rounds <- 50
args$xgb_model <- NULL

# Define missing model parameters.
args$data <- xgb.DMatrix(data = data[[i]]$train$data,
                         label = data[[i]]$train$labels)

val <- xgb.DMatrix(data = data[[i]]$val$data,
                   label = data[[i]]$val$labels)

args$watchlist <- list(train=args$data, test=val)

# Fit the model.
gb_model <- do.call(xgb.train, args)