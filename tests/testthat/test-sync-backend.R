# Test `SyncBackend` class.

test_that("'SyncBackend' creates and manages clusters correctly", {
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
    backend <- SyncBackend$new()

    # Start the cluster on the backend.
    backend$start(specification)

    # Expect the cluster to be an object of `parallel` class.
    expect_true(is(backend$cluster, "cluster"))

    # Expect that the cluster is of correct size.
    expect_equal(length(backend$cluster), specification$cores)

    # Expect that the cluster is of correct type.
    switch(cluster_type,
        "psock" = expect_true(all(tolower(summary(backend$cluster)[, 2]) == "socknode")),
        "fork" = expect_true(all(tolower(summary(backend$cluster)[, 2]) == "forknode"))
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


test_that("'SyncBackend' performs operations on the cluster correctly", {
    # Create a specification.
    specification <- Specification$new()

    # Set the number of cores.
    specification$set_cores(cores = 2)

    # Determine the cluster type automatically.
    specification$set_type(type = NULL)

    # Create a synchronous backend object.
    backend <- SyncBackend$new()

    # Start the cluster on the backend.
    backend$start(specification)

    # Expect the backend to not support progress tracking.
    expect_false(backend$supports_progress)

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
    expect_equal(backend$get_output(), data + add)

    # Expect that subsequent calls to `get_output` return `NULL`.
    expect_null(backend$get_output())

    # Expect that the cluster is empty after performing operations on it.
    expect_true(all(sapply(backend$peek(), length) == 0))

    # Stop the backend.
    backend$stop()
})
