# Helpers for testing.

#region General test helpers.

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


# Check if the body of a decorated tasks contains a specific pattern.
body_contains <- function(task, pattern, position = 2) {
    # Get the body of the decorated task at a specific position.
    extraction <- as.list(body(task))[position]

    # Check if the body at position contains the pattern.
    contains <- grepl(pattern, extraction)

    return(contains)
}

#endregion


#region Tests sets applicable to all backends types.

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

    # Expect an error when calling the `lapply` method.
    expect_error(service$lapply(), as_text(Exception$method_not_implemented()))

    # Expect an error when calling the `apply` method.
    expect_error(service$apply(), as_text(Exception$method_not_implemented()))

    # Expect an error when calling the `get_output` method.
    expect_error(service$get_output(), as_text(Exception$method_not_implemented()))
}


# Set of tests for exporting to the backend (i.e,. regardless of type).
tests_set_for_backend_exporting <- function(service) {
    # Create a variable in a different environment.
    env <- new.env()
    env$test_variable <- rnorm(1)

    # Export the variable from the specific environment to the backend.
    service$export("test_variable", env)

    # Expect that the variable is on the backend.
    expect_true(all(service$peek() == "test_variable"))

    # Expect the cluster to hold the correct value for the exported variable.
    expect_true(all(service$evaluate(test_variable) == env$test_variable))

    # Assign a variable to the current environment.
    assign("test_variable", rnorm(1), envir = environment())

    # Export the variable using the current environment (i.e., parent of `export`).
    service$export("test_variable")

    # Expect that the variable is on the backend.
    expect_true(all(service$peek() == "test_variable"))

    # Expect the cluster to hold the correct value for the exported variable.
    expect_true(all(service$evaluate(test_variable) == get("test_variable", envir = environment())))
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

#endregion


#region Tests sets for synchronous backends.

# Set of tests for the synchronous backend task execution via a specified operation.
tests_set_for_synchronous_backend_task_execution <- function(operation, service, expected_output) {
    # Run the task in parallel via the requested operation (e.g., `sapply`).
    eval(operation)

    # Expect the that output is correct.
    expect_equal(service$get_output(), expected_output)

    # Expect that subsequent calls to `get_output` return `NULL`.
    expect_null(service$get_output())

    # Remain silent.
    invisible(NULL)
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

    # Tests for exporting to the backend.
    tests_set_for_backend_exporting(service)

    # Clear the backend.
    service$clear()

    # Expect that clearing the cluster leaves it empty.
    expect_true(all(sapply(service$peek(), length) == 0))

    # Select task arguments.
    x <- sample(1:100, 100)
    y <- sample(1:100, 1)
    z <- sample(1:100, 1)
    sleep = sample(c(0, 0.001, 0.002), 1)

    # Created the expect output.
    expected_output <- task(x, y, z)

    # Define the `sapply` operation.
    operation <- bquote(service$sapply(.(x), .(task), y = .(y), z = .(z), sleep = .(sleep)))

    # Tests for the `sapply` operation.
    tests_set_for_synchronous_backend_task_execution(operation, service, expected_output)

    # Expect that errors in the task executed via `sapply` are propagated.
    expect_error(
        service$sapply(1:10, function(x) stop("Task error.")),
        "Task error."
    )

    # Created the expect output.
    expected_output <- as.list(expected_output)

    # Define the `lapply` operation.
    operation <- bquote(service$lapply(.(x), .(task), y = .(y), z = .(z), sleep = .(sleep)))

    # Tests for the `lapply` operation.
    tests_set_for_synchronous_backend_task_execution(operation, service, expected_output)

    # Expect that errors in the task executed via `lapply` are propagated.
    expect_error(
        service$lapply(1:10, function(x) stop("Task error.")),
        "Task error."
    )

    # Redefine `x` as a matrix for the `apply` operation.
    x <- matrix(rnorm(100^2), nrow = 100, ncol = 100)

    # Compute the expected output for the `apply` operation applied over rows.
    expected_output <- base::apply(x, 1, task, y = y, z = z)

    # Define the `apply` operation over rows.
    operation <- bquote(service$apply(.(x), 1, .(task), y = .(y), z = .(z), sleep = .(sleep)))

    # Tests for the `apply` operation over rows.
    tests_set_for_synchronous_backend_task_execution(operation, service, expected_output)

    # Compute the expected output for the `apply` operation applied over columns.
    expected_output <- base::apply(x, 2, task, y = y, z = z)

    # Define the `apply` operation over columns.
    operation <- bquote(service$apply(.(x), 2, .(task), y = .(y), z = .(z), sleep = .(sleep)))

    # Tests for the `apply` operation over columns.
    tests_set_for_synchronous_backend_task_execution(operation, service, expected_output)

    # Redefine a smaller `x` matrix for the `apply` operation applied element-wise.
    x <- matrix(rnorm(10^2), nrow = 10, ncol = 10)

    # Compute the expected output for the `apply` operation applied element-wise.
    expected_output <- base::apply(x, c(1, 2), task, y = y, z = z)

    # Define the `apply` operation element-wise.
    operation <- bquote(service$apply(.(x), c(1, 2), .(task), y = .(y), z = .(z), sleep = .(sleep)))

    # Tests for the `apply` operation element-wise.
    tests_set_for_synchronous_backend_task_execution(operation, service, expected_output)

    # Expect error when margins higher than the array dimensions are provided.
    expect_error(
        service$apply(x, 3, task, y = y, z = z),
        as_text(Exception$array_margins_not_compatible(3, dim(x))),
        fixed = TRUE
    )

    # Expect error when duplicate margins are provided.
    expect_error(
        service$apply(x, c(1, 1), task, y = y, z = z),
        as_text(Exception$array_margins_not_compatible(c(1, 1), dim(x))),
        fixed = TRUE
    )

    # Expect errors when the margins are not compatible with the array dimensions.
    expect_error(
        service$apply(x, c(1, 2, 3, 1), task, y = y, z = z),
        as_text(Exception$array_margins_not_compatible(c(1, 2, 3, 1), dim(x))),
        fixed = TRUE
    )

    # Expect that errors in the task executed via `apply` are propagated.
    expect_error(
        service$apply(matrix(1:100, 10, 10), 1, function(x) stop("Task error.")),
        "Task error."
    )

    # Expect that the cluster is empty after performing operations on it.
    expect_true(all(sapply(service$peek(), length) == 0))

    # Remain silent.
    invisible(NULL)
}

#endregion


#region Tests sets for asynchronous backends.

# Set of tests for the asynchronous backend task execution via a specified operation.
tests_set_for_asynchronous_backend_task_execution <- function(operation, service, expected_output) {
    # Run the task in parallel.
    eval(operation)

    # Expect the that output is correct.
    expect_equal(service$get_output(wait = TRUE), expected_output)

    # Expect that subsequent calls to `get_output` will throw an error.
    expect_error(service$get_output(), as_text(Exception$async_task_not_started()))

    # Run the task in parallel, with a bit of overhead.
    eval(operation)

    # Expect that trying to run a task while another is running fails.
    expect_error(eval(operation), as_text(Exception$async_task_running()))

    # Expect the that output is correct.
    expect_equal(service$get_output(wait = TRUE), expected_output)

    # Run the task in parallel, with a bit of overhead.
    eval(operation)

    # Expect that trying to get the output of a task that is still running fails.
    expect_error(service$get_output(), as_text(Exception$async_task_running()))

    # Block the main thread until the task is finished.
    while(task_is_running(service)) {
        # Sleep a bit.
        Sys.sleep(0.001)
    }

    # Expect that trying to run a task without reading the previous output fails.
    expect_error(eval(operation), as_text(Exception$async_task_completed()))

    # Expect the that output is correct.
    expect_equal(service$get_output(), expected_output)
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

    # Tests for the `export` operation.
    tests_set_for_backend_exporting(service)

    # Clear the backend.
    service$clear()

    # Expect that clearing the cluster leaves it empty.
    expect_true(all(sapply(service$peek(), length) == 0))

    # Expect error waiting to fetch the output when no task is running.
    expect_error(service$get_output(wait = TRUE), as_text(Exception$async_task_not_started()))

    # Select task arguments.
    x <- sample(1:100, 100)
    y <- sample(1:100, 1)
    z <- sample(1:100, 1)
    sleep = sample(c(0, 0.001, 0.002), 1)

    # Compute the expected output for the `sapply` operation.
    expected_output <- task(x, y, z)

    # Define the `sapply` operation.
    operation <- bquote(service$sapply(.(x), .(task), y = .(y), z = .(z), sleep = .(sleep)))

    # Tests for the `sapply` operation.
    tests_set_for_asynchronous_backend_task_execution(operation, service, expected_output)

    # Expect that errors in the task executed via `sapply` are propagated.
    expect_error(
        {
            service$sapply(1:10, function(x) stop("Task error."))
            service$get_output(wait = TRUE)
        },
        "Task error."
    )

    # Compute the expected output for the `lapply` operation.
    expected_output <- as.list(expected_output)

    # Define the `lapply` operation.
    operation <- bquote(service$lapply(.(x), .(task), y = .(y), z = .(z), sleep = .(sleep)))

    # Tests for the `lapply` operation.
    tests_set_for_asynchronous_backend_task_execution(operation, service, expected_output)

    # Expect that errors in the task executed via `lapply` are propagated.
    expect_error(
        {
            service$lapply(1:10, function(x) stop("Task error."))
            service$get_output(wait = TRUE)
        },
        "Task error."
    )

    # Redefine `x` as a matrix for the `apply` operation.
    x <- matrix(rnorm(100^2), nrow = 100, ncol = 100)

    # Compute the expected output for the `apply` operation applied over rows.
    expected_output <- base::apply(x, 1, task, y = y, z = z)

    # Define the `apply` operation over rows.
    operation <- bquote(service$apply(.(x), 1, .(task), y = .(y), z = .(z), sleep = .(sleep)))

    # Tests for the `apply` operation over rows.
    tests_set_for_asynchronous_backend_task_execution(operation, service, expected_output)

    # Compute the expected output for the `apply` operation applied over columns.
    expected_output <- base::apply(x, 2, task, y = y, z = z)

    # Define the `apply` operation over columns.
    operation <- bquote(service$apply(.(x), 2, .(task), y = .(y), z = .(z), sleep = .(sleep)))

    # Tests for the `apply` operation over columns.
    tests_set_for_asynchronous_backend_task_execution(operation, service, expected_output)

    # Redefine a smaller `x` matrix for the `apply` operation applied element-wise.
    x <- matrix(rnorm(10^2), nrow = 10, ncol = 10)

    # Compute the expected output for the `apply` operation applied element-wise.
    expected_output <- base::apply(x, c(1, 2), task, y = y, z = z)

    # Define the `apply` operation element-wise.
    operation <- bquote(service$apply(.(x), c(1, 2), .(task), y = .(y), z = .(z), sleep = .(sleep)))

    # Tests for the `apply` operation element-wise.
    tests_set_for_asynchronous_backend_task_execution(operation, service, expected_output)

    # Expect error when margins higher than the array dimensions are provided.
    expect_error(
        service$apply(x, 3, task, y = y, z = z),
        as_text(Exception$array_margins_not_compatible(3, dim(x))),
        fixed = TRUE
    )

    # Expect error when duplicate margins are provided.
    expect_error(
        service$apply(x, c(1, 1), task, y = y, z = z),
        as_text(Exception$array_margins_not_compatible(c(1, 1), dim(x))),
        fixed = TRUE
    )

    # Expect errors when the margins are not compatible with the array dimensions.
    expect_error(
        service$apply(x, c(1, 2, 3, 1), task, y = y, z = z),
        as_text(Exception$array_margins_not_compatible(c(1, 2, 3, 1), dim(x))),
        fixed = TRUE
    )

    # Expect that errors in the task executed via `apply` are propagated.
    expect_error(
        {
            service$apply(matrix(1:100, 10, 10), 1, function(x) stop("Task error."))
            service$get_output(wait = TRUE)
        },
        "Task error."
    )

    # Expect that the cluster is empty after performing operations on it.
    expect_true(all(sapply(service$peek(), length) == 0))

    # Remain silent.
    invisible(NULL)
}

#endregion


#region Tests sets for progress tracking.

# Set of tests for executing tasks in a progress tracking context with output.
tests_set_for_task_execution_with_progress_tracking <- function(operation, context, expected_output) {
    # Clear the progress output on exit.
    on.exit({
        # Clear the output.
        context$progress_bar_output <- NULL
    })

    # Create a bar factory.
    bar_factory <- BarFactory$new()

    # Get a basic bar instance.
    bar <- bar_factory$get("basic")

    # Register the bar with the context object.
    context$set_bar(bar)

    # Configure the bar.
    context$configure_bar(
        style = 3
    )

    # Run the task in parallel.
    eval(operation)

    # Expect that the task output is correct.
    expect_equal(context$get_output(wait = TRUE), expected_output)

    # Expect the progress bar was shown correctly.
    expect_true(any(grepl("=\\| 100%", context$progress_bar_output)))

    # Get a modern bar instance.
    bar <- bar_factory$get("modern")

    # Register the bar with the same context object.
    context$set_bar(bar)

    # Configure the bar.
    context$configure_bar(
        show_after = 0,
        format = ":bar| :percent",
        clear = FALSE,
        force = TRUE
    )

    # Run the task in parallel.
    eval(operation)

    # Expect that the task output is correct.
    expect_equal(context$get_output(wait = TRUE), expected_output)

    # Expect the progress bar was shown correctly.
    expect_true(any(grepl("=\\| 100%", context$progress_bar_output)))
}

# Set of tests for progress tracking context.
tests_set_for_progress_tracking_context <- function(context, task) {
    # Check the type.
    Helper$check_object_type(context, "ProgressTrackingContextTester")

    # Select task arguments.
    x <- sample(1:100, 100)
    y <- sample(1:100, 1)
    z <- sample(1:100, 1)
    sleep = sample(c(0, 0.001, 0.002), 1)

    # Create the expected output for the `sapply` operation.
    expected_output <- task(x, y, z)

    # Create the `sapply` operation.
    operation <- bquote(context$sapply(.(x), .(task), y = .(y), z = .(z), sleep = .(sleep)))

    # Tests for the `sapply` operation in a progress tracking context.
    tests_set_for_task_execution_with_progress_tracking(operation, context, expected_output)

    # Create the expected output for the `lapply` operation.
    expected_output <- as.list(expected_output)

    # Create the `lapply` operation.
    operation <- bquote(context$lapply(.(x), .(task), y = .(y), z = .(z), sleep = .(sleep)))

    # Tests for the `lapply` operation in a progress tracking context.
    tests_set_for_task_execution_with_progress_tracking(operation, context, expected_output)

    # Redefine `x` as a matrix for the `apply` operation.
    x <- matrix(rnorm(100^2), nrow = 100, ncol = 100)

    # Compute the expected output for the `apply` operation applied over rows.
    expected_output <- base::apply(x, 1, task, y = y, z = z)

    # Define the `apply` operation over rows.
    operation <- bquote(context$apply(.(x), 1, .(task), y = .(y), z = .(z), sleep = .(sleep)))

    # Tests for the `apply` operation over rows in a progress tracking context.
    tests_set_for_task_execution_with_progress_tracking(operation, context, expected_output)

    # Compute the expected output for the `apply` operation applied over columns.
    expected_output <- base::apply(x, 2, task, y = y, z = z)

    # Define the `apply` operation over columns.
    operation <- bquote(context$apply(.(x), 2, .(task), y = .(y), z = .(z), sleep = .(sleep)))

    # Tests for the `apply` operation over columns in a progress tracking context.
    tests_set_for_task_execution_with_progress_tracking(operation, context, expected_output)

    # Redefine a smaller `x` matrix for the `apply` operation applied element-wise.
    x <- matrix(rnorm(10^2), nrow = 10, ncol = 10)

    # Compute the expected output for the `apply` operation applied element-wise.
    expected_output <- base::apply(x, c(1, 2), task, y = y, z = z)

    # Define the `apply` operation element-wise.
    operation <- bquote(context$apply(.(x), c(1, 2), .(task), y = .(y), z = .(z), sleep = .(sleep)))

    # Tests for the `apply` operation over all elements in a progress tracking context.
    tests_set_for_task_execution_with_progress_tracking(operation, context, expected_output)
}

#endregion


#region Tests sets for the user API.

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


# Set of tests for task execution via the user API.
tests_set_for_user_api_task_execution <- function(parallel, sequential, expected_output) {
    # Clean-up.
    on.exit({
        # Set default values for package options.
        set_default_options()
    })

    # Select a cluster type.
    cluster_type <- pick_cluster_type(Specification$new()$types)

    # Disable progress tracking.
    set_option("progress_track", FALSE)

    # Create a synchronous backend.
    backend <- start_backend(
        cores = 2,
        cluster_type = cluster_type,
        backend_type = "sync"
    )

    # Expect the output of the task ran in parallel to be correct.
    expect_equal(eval(parallel), expected_output)

    # Enable progress tracking.
    set_option("progress_track", TRUE)

    # Expect warning for requesting progress tracking with incompatible backend.
    expect_warning(
        eval(parallel),
        as_text(Warning$progress_not_supported_for_backend(backend))
    )

    # Stop the synchronous backend.
    stop_backend(backend)

    # Create an asynchronous backend.
    backend <- start_backend(
        cores = 2,
        cluster_type = cluster_type,
        backend_type = "async"
    )

    # Expect the output to be correct.
    expect_equal(eval(parallel), expected_output)

    # Disable progress tracking.
    set_option("progress_track", FALSE)

    # Expect the output to be correct.
    expect_equal(eval(parallel), expected_output)

    # Stop the asynchronous backend.
    stop_backend(backend)

    # Expect the task to produce correct output when ran sequentially.
    expect_equal(eval(sequential), expected_output)
}


# Set of tests for progress tracking via the user API.
tests_set_for_user_api_progress_tracking <- function(operation) {
    # Pick a cluster type.
    cluster_type <- pick_cluster_type(Specification$new()$types)

    # Create an asynchronous backend.
    backend <- start_backend(
        cores = 2,
        cluster_type = cluster_type,
        backend_type = "async"
    )

    # Clean-up on exit.
    on.exit({
        # Stop the backend.
        stop_backend(backend)

        # Restore the default options.
        set_default_options()
    })

    # Configure modern bar.
    configure_bar(
        type = "modern",
        force = TRUE,
        clear = FALSE
    )

    # Redirect output.
    sink("/dev/null", type = "output")

    # Run the task and capture the progress bar output.
    output <- capture.output({ eval(operation) }, type = "message")

    # Remove output redirection.
    sink(NULL)

    # Expect the progress bar to be shown correctly.
    expect_true(grepl("tasks \\[100%\\]", paste0(output, collapse = ""), perl = TRUE))

    # Configure the basic bar.
    configure_bar(
        type = "basic",
        style = 3
    )

    # Run the task and capture the progress bar output.
    output <- capture.output({ eval(operation) }, type = "output")

    # Expect the progress bar to be shown correctly.
    expect_true(grepl("=\\| 100%", paste0(output, collapse = ""), perl = TRUE))

    # Disable progress tracking.
    set_option("progress_track", FALSE)

    # Run the task and capture the output without the progress bar.
    output <- capture.output({ eval(operation) }, type = "output")

    # Expect the progress bar to be missing from the output.
    expect_false(grepl("=\\| 100%", paste0(output, collapse = ""), perl = TRUE))
}

#endregion


#region Helper `R6` classes for testing.

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

    private = list(
        # Wrapper for executing task operations with progress output capturing.
        .execute_and_capture_progress = function(operation) {
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
            eval(operation)

            # Store the progress bar output on the instance.
            self$progress_bar_output <- output
        }
    ),

    public = list(
        # The progress bar output used for testing.
        progress_bar_output = NULL,

        # Implementation for the `sapply` method capturing the progress output.
        sapply = function(x, fun, ...) {
            # Define the operation.
            operation <- bquote(
                do.call(
                    super$sapply, c(list(.(x), .(fun)), .(list(...)))
                )
            )

            # Execute the task via the operation and capture the progress output.
            private$.execute_and_capture_progress(operation)
        },

        # Implementation for the `lapply` method capturing the progress output.
        lapply = function(x, fun, ...) {
            # Define the operation.
            operation <- bquote(
                do.call(
                    super$lapply, c(list(.(x), .(fun)), .(list(...)))
                )
            )

            # Execute the task via the operation and capture the progress output.
            private$.execute_and_capture_progress(operation)
        },

        # Implementation for the `apply` method capturing the progress output.
        apply = function(x, margin, fun, ...) {
            # Define the operation.
            operation <- bquote(
                do.call(
                    super$apply, c(list(.(x), .(margin), .(fun)), .(list(...)))
                )
            )

            # Execute the task via the operation and capture the progress output.
            private$.execute_and_capture_progress(operation)
        },

        # Wrapper to expose `.make_log` for testing.
        make_log = function() {
            private$.make_log()
        },

        # Wrapper to expose the `.decorate` for testing.
        decorate = function(task, log) {
            private$.decorate(task, log)
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

#endregion
