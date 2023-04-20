# Test `AsyncBackend` class.

test_that("'AsyncBackend' creates and manages clusters correctly", {
    # Create a specification.
    specification <- Specification$new()

    # Set the number of cores.
    specification$set_cores(cores = 2)

    # Decide what type of cluster to create.
    if (.Platform$OS.type == "unix") {
        # Randomly pick a cluster type.
        cluster_type <- sample(specification$types, 1)
    } else {
        # Fix the cluster type to "psock" on Windows.
        cluster_type <- "psock"
    }

    # Let the specification determine the cluster type.
    specification$set_type(type = cluster_type)

    # Create a synchronous backend object.
    backend <- AsyncBackend$new()

    # Start the cluster on the backend.
    backend$start(specification)

    # Expect the cluster to be an object of `callr` class.
    expect_true(is(backend$cluster, "r_session"))

    # Expect that the cluster is of correct size.
    expect_equal(backend$cluster$run(function() length(cluster)), specification$cores)

    # Expect that the cluster is of correct type.
    switch(cluster_type,
        "psock" = expect_true(all(tolower(backend$cluster$run(function() summary(cluster))[, 2]) == "socknode")),
        "fork" = expect_true(all(tolower(backend$cluster$run(function() summary(cluster))[, 2]) == "forknode"))
    )

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
})


test_that("'AsyncBackend' performs operations on the cluster correctly", {
    # Create a specification.
    specification <- Specification$new()

    # Set the number of cores.
    specification$set_cores(cores = 2)

    # Determine the cluster type automatically.
    specification$set_type(type = NULL)

    # Create a synchronous backend object.
    backend <- AsyncBackend$new()

    # Start the cluster on the backend.
    backend$start(specification)

    # Expect the backend to support progress tracking.
    expect_true(backend$supports_progress)

    # Expect that the cluster is empty upon creation.
    expect_true(all(sapply(backend$peek(), length) == 0))

    # Create a variable in a new environment.
    env <- new.env()
    env$test_variable <- rnorm(1)

    # Export the variable from the environment to the backend.
    backend$export("test_variable", env)

    # Expect that the variable is on the backend.
    expect_true(all(backend$peek() == "test_variable"))

    # Expect the cluster to hold the correct value for the exported variable.
    expect_true(all(backend$evaluate(test_variable) == env$test_variable))

    # Expect that clearing the cluster leaves it empty.
    backend$clear()
    expect_true(all(sapply(backend$peek(), length) == 0))

    # Create test data for the cluster `sapply` operation.
    data <- sample(1:100, 100)

    # Create a task function for the cluster `sapply` operation.
    task <- function(x, add) x + add

    # Specify a random value for the task function argument.
    add <- sample(1:100, 1)

    # Run the task in parallel.
    backend$sapply(data, task, add = add)

    # Expect the that output is correct.
    expect_equal(backend$get_output(wait = TRUE), data + add)

    # Expect that subsequent calls to `get_output` will throw an error.
    expect_error(backend$get_output(), as_text(Exception$async_task_not_started()))

    # Define a task that will take a bit to compute.
    task <- function(x, add) {
        # Sleep a bit.
        Sys.sleep(0.002)

        # Compute something.
        output <- x + add

        # Return the result.
        return(output)
    }

    # Run the task in parallel.
    backend$sapply(data, task, add = add)

    # Expect that trying to run a task while another is running fails.
    expect_error(backend$sapply(data, task, add = add), as_text(Exception$async_task_running()))

    # Expect the that output is correct.
    expect_equal(backend$get_output(wait = TRUE), data + add)

    # Run the task in parallel.
    backend$sapply(data, task, add = add)

    # Expect that trying to get the output of a task that is still running fails.
    expect_error(backend$get_output(), as_text(Exception$async_task_running()))

    # Block the main thread until the task is finished.
    while(backend$task_state$task_is_running) {
        # Sleep a bit.
        Sys.sleep(0.002)
    }

    # Expect that trying to run a task without reading the previous output fails.
    expect_error(backend$sapply(data, task, add = add), as_text(Exception$async_task_completed()))

    # Expect the that output is correct.
    expect_equal(backend$get_output(), data + add)

    # Expect that the cluster is empty after performing operations on it.
    expect_true(all(sapply(backend$peek(), length) == 0))

    # Stop the backend.
    backend$stop()
})
