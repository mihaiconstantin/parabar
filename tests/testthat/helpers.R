# Helpers for testing.

# Helper for extracting the message associated with errors and warnings.
as_text <- function(expression) {
    # Capture message.
    message <- tryCatch(expression,
        # Capture warning message.
        warning = function(w) w$message,

        # Capture error message.
        error = function(e) e$message
    )

    return(message)
}


# Select a cluster type, with some variability.
pick_cluster_type <- function(types) {
    # Decide what type of cluster to create.
    if (.Platform$OS.type == "unix") {
        # Randomly pick a cluster type.
        cluster_type <- sample(types, 1)
    } else {
        # Fix the cluster type to "psock" on Windows.
        cluster_type <- "psock"
    }

    return(cluster_type)
}


# Select backend type.
pick_backend_type <- function() {
    # Randomly pick a backend type.
    backend_type <- sample(c("sync", "async"), 1)

    return(backend_type)
}


# Define the test task to use.
test_task <- function(x, y, z, sleep = 0) {
    # Sleep a bit or not.
    Sys.sleep(sleep)

    # Compute something.
    output <- (x + y) / z

    # Return the result.
    return(output)
}


# Check if a task is running on an asynchronous backend, or context.
task_is_running <- function(backend) {
    # If a context is passed.
    if (Helper$get_class_name(backend) == "Context") {
        # Get the status via the context.
        status <- backend$backend$task_state$task_is_running
    } else {
        # Get the status from the backend directly.
        status <- backend$task_state$task_is_running
    }

    return(status)
}


# Helper for testing private methods of `Specification` class.
SpecificationTester <- R6::R6Class("SpecificationTester",
    inherit = Specification,

    private = list(
        # Overwrite the private `.get_available_cores()` method.
        .get_available_cores = function() {
            return(self$available_cores)
        }
    ),

    public = list(
        available_cores = NULL
    ),

    active = list(
        # Expose the private `.determine_usable_cores` method.
        usable_cores = function() {
            # Compute and return the number of the usable cores.
            return(private$.determine_usable_cores(self$available_cores))
        }
    )
)
