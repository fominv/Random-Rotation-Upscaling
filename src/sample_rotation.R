# Save this script as sample_rotation.R!

library(keras)
library(Matrix)

sample_rotation <- function(n,sigma=1){
    # Sample a rotation matrix.

    # Define data structures.
    signums <-  list()
    H <-  list()

    for (i in n:2){
        # Define unit vector.
        e <- c(1,rep(0,i-1))

        # Sample from multivariate normal distribution.
        alpha <- rnorm(i, mean=0, sd=sigma)
        sign <- sign(alpha[1])

        # Compute Householder Transformation of a.
        v <- sign * sqrt(sum(alpha^2)) * e + alpha
        H_hat <- diag(i) - 2 * v %*% t(v) / sum(v^2)

        # Save signums.
        signums[[i]] <- sign((H_hat %*% alpha)[1])

        # Due to optimized multiplication save H_hat.
        H[[i]] <- H_hat
    }

    # Compute missing 1 dimensional householder transformation.
    signums[[1]] <- sign(rnorm(1,mean=0,sd=sigma))
    H[[1]] <- as.matrix(-1)

    # Sampled last diagonal element in contrast to original paper!
    D <- bdiag(rev(signums))

    # Modified multiplication to speed up computation time.
    mod_mult <- function(H_2, H_1){
        result <- H_2 %*% bdiag(1, H_1)
        return(result)
    }

    # Compute singular value decomposition.
    c(D,U,V) %<-% svd(D %*% Reduce(f = mod_mult, rev(H), right = TRUE))

    # Define rotation matrix.
    R <- as.matrix(U %*% bdiag(diag(n-1), det(U %*% t(V))) %*% t(V))

    return(R)
}

rotate <- function(points, rotation=NULL){
    # Rotate points or rbinded matrices of points.

    # Return originial point if no rotation is given.
    if(is.null(rotation)){return(point)}

    # Define rotation function regarding one point.
    rotate_point <- function(point){
        return(rotation %*% point)
    }

    # Transform to one dimenstionl matrix if input is only a sequence.
    if(is.null(dim(points))){
        points <- matrix(data = points, nrow=1)
    }

    # Transpose before return to output the same orientation of samples and dimensions.
    return(t(apply(points, 1,rotate_point)))
}
