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


# Set of tests for synchronous backend operations.
tests_set_for_synchronous_backend_operations <- function(service, specification, task) {
    # Start the cluster on the backend.
    service$start(specification)

    # Always stop on exit.
    on.exit({
        # Stop the backend.
        service$stop()
    })

    # Expect that the cluster is empty upon creation.
    expect_true(all(sapply(service$peek(), length) == 0))

    # Create a variable in a new environment.
    env <- new.env()
    env$test_variable <- rnorm(1)

    # Export the variable from the environment to the backend.
    service$export("test_variable", env)

    # Expect that the variable is on the backend.
    expect_true(all(service$peek() == "test_variable"))

    # Expect the cluster to hold the correct value for the exported variable.
    expect_true(all(service$evaluate(test_variable) == env$test_variable))

    # Clear the backend.
    service$clear()

    # Expect that clearing the cluster leaves it empty.
    expect_true(all(sapply(service$peek(), length) == 0))

    # Select task arguments for the `sapply` operation.
    x <- sample(1:100, 100)
    y <- sample(1:100, 1)
    z <- sample(1:100, 1)
    sleep = sample(c(0, 0.001, 0.002), 1)

    # Run the task in parallel.
    service$sapply(x, task, y = y, z = z, sleep = sleep)

    # Expect the that output is correct.
    expect_equal(service$get_output(), task(x, y, z))

    # Expect that subsequent calls to `get_output` return `NULL`.
    expect_null(service$get_output())

    # Expect that the cluster is empty after performing operations on it.
    expect_true(all(sapply(service$peek(), length) == 0))

    # Remain silent.
    invisible(NULL)
}


# Set of tests for synchronous backend operations.
tests_set_for_asynchronous_backend_operations <- function(service, specification, task) {
    # Start the cluster on the backend.
    service$start(specification)

    # Always stop on exit.
    on.exit({
        # Stop the backend.
        service$stop()
    })

    # Expect that the cluster is empty upon creation.
    expect_true(all(sapply(service$peek(), length) == 0))

    # Create a variable in a new environment.
    env <- new.env()
    env$test_variable <- rnorm(1)

    # Export the variable from the environment to the backend.
    service$export("test_variable", env)

    # Expect that the variable is on the backend.
    expect_true(all(service$peek() == "test_variable"))

    # Expect the cluster to hold the correct value for the exported variable.
    expect_true(all(service$evaluate(test_variable) == env$test_variable))

    # Expect that clearing the cluster leaves it empty.
    service$clear()
    expect_true(all(sapply(service$peek(), length) == 0))

    # Select task arguments for the `sapply` operation.
    x <- sample(1:100, 100)
    y <- sample(1:100, 1)
    z <- sample(1:100, 1)
    sleep = sample(c(0, 0.001, 0.002), 1)

    # Compute the correct output.
    expected_output <- task(x, y, z)

    # Run the task in parallel.
    service$sapply(x, task, y = y, z = z)

    # Expect the that output is correct.
    expect_equal(service$get_output(wait = TRUE), expected_output)

    # Expect that subsequent calls to `get_output` will throw an error.
    expect_error(service$get_output(), as_text(Exception$async_task_not_started()))

    # Run the task in parallel, with a bit of overhead.
    service$sapply(x, task, y = y, z = z, sleep = sleep)

    # Expect that trying to run a task while another is running fails.
    expect_error(service$sapply(x, task, y = y, z = z), as_text(Exception$async_task_running()))

    # Expect the that output is correct.
    expect_equal(service$get_output(wait = TRUE), expected_output)

    # Run the task in parallel.
    service$sapply(x, task, y = y, z = z, sleep = sleep)

    # Expect that trying to get the output of a task that is still running fails.
    expect_error(service$get_output(), as_text(Exception$async_task_running()))

    # Block the main thread until the task is finished.
    while(task_is_running(service)) {
        # Sleep a bit.
        Sys.sleep(0.001)
    }

    # Expect that trying to run a task without reading the previous output fails.
    expect_error(service$sapply(data, task, add = add), as_text(Exception$async_task_completed()))

    # Expect the that output is correct.
    expect_equal(service$get_output(), expected_output)

    # Expect that the cluster is empty after performing operations on it.
    expect_true(all(sapply(service$peek(), length) == 0))

    # Remain silent.
    invisible(NULL)
}


# Set of tests for starting and stopping backends.
tests_set_for_backend_states <- function(backend, specification) {
    # Expect an error if an attempt is made to start a cluster while one is already active.
    expect_error(backend$start(specification), as_text(Exception$cluster_active()))

    # Stop the backend.
    backend$stop()

    # Expect that stopping the cluster marks it as inactive.
    expect_false(backend$active)

    # Expect the cluster field has been cleared.
    expect_null(backend$cluster)

    # Start a new cluster on the same backend instance.
    backend$start(specification)

    # Expect the cluster is active.
    expect_true(backend$active)

    # Stop the cluster.
    backend$stop()

    # Expect that trying to stop a cluster that is not active throws an error.
    expect_error(backend$stop(), as_text(Exception$cluster_not_active()))
}


# Set of tests for unimplemented service methods.
tests_set_for_unimplemented_service_methods <- function(service) {
    # Expect an error when calling the `start` method.
    expect_error(service$start(), as_text(Exception$method_not_implemented()))

    # Expect an error when calling the `stop` method.
    expect_error(service$stop(), as_text(Exception$method_not_implemented()))

    # Expect an error when calling the `clear` method.
    expect_error(service$clear(), as_text(Exception$method_not_implemented()))

    # Expect an error when calling the `peek` method.
    expect_error(service$peek(), as_text(Exception$method_not_implemented()))

    # Expect an error when calling the `export` method.
    expect_error(service$export(), as_text(Exception$method_not_implemented()))

    # Expect an error when calling the `evaluate` method.
    expect_error(service$evaluate(), as_text(Exception$method_not_implemented()))

    # Expect an error when calling the `sapply` method.
    expect_error(service$sapply(), as_text(Exception$method_not_implemented()))

    # Expect an error when calling the `get_output` method.
    expect_error(service$get_output(), as_text(Exception$method_not_implemented()))
}


# Set of tests for creating backends via the user API.
tests_set_for_backend_creation_via_user_api <- function(cluster_type, backend_type) {
    # Create a backend.
    backend <- start_backend(
        cores = 2,
        cluster_type = cluster_type,
        backend_type = backend_type
    )

    # Expect the backend to be active.
    expect_true(backend$active)

    # Expect the backend to be of the correct type.
    expect_equal(
        Helper$get_class_name(backend),
        Helper$get_class_name(BackendFactory$new()$get(backend_type))
    )

    # Stop the backend
    stop_backend(backend)

    # Expect the backend to be inactive.
    expect_false(backend$active)
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


# Helper for testing method implementations of `Service` interface.
ServiceImplementation <- R6::R6Class("ServiceImplementation",
    inherit = Service,

    public = list(
        # Allow instantiation.
        initialize = function() {}
    )
)


# Helper for testing method implementations of `Backend` class.
BackendImplementation <- R6::R6Class("BackendImplementation",
    inherit = Backend,

    public = list(
        # Allow instantiation.
        initialize = function() {}
    )
)


# Helper for testing the `ProgressTrackingContext` class.
ProgressTrackingContextTester <- R6::R6Class("ProgressTrackingContextTester",
    inherit = ProgressTrackingContext,

    public = list(
        # The progress bar output used for testing.
        progress_bar_output = NULL,

        # Implementation for the `sapply` method preserving the log file.
        sapply = function(x, fun, ...) {
            # Create a text connection.
            connection <- textConnection("output", open = "w", local = TRUE)

            # Capture the output.
            sink(connection, type = "output")
            sink(connection, type = "message")

            # Close the connection and reset the sink on exit.
            on.exit({
                # Reset the sink.
                sink(NULL, type = "message")
                sink(NULL, type = "output")

                # Close the connection.
                close(connection)
            })

            # Execute the task.
            super$sapply(x, fun, ...)

            # Store the progress bar output on the instance.
            self$progress_bar_output <- output
        }
    ),

    active = list(
        # Expose the bar configuration.
        bar_config = function() { return(private$.bar_config) }
    )
)


# Helper for testing method implementations of `Bar` class.
BarImplementation <- R6::R6Class("BarImplementation",
    inherit = Bar,

    public = list(
        # Allow instantiation.
        initialize = function() {}
    )
)
