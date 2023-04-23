# Test `ProgressTrackingContext` class.

test_that("'ProgressTrackingContext' sets the backend correctly", {
    # Create a backend factory.
    backend_factory <- BackendFactory$new()

    # Create a progress tracking context object.
    context <- ProgressTrackingContext$new()

    # Expect the context to start with no backend.
    expect_null(context$backend)

    # Get a synchronous backend instance.
    backend <- backend_factory$get("sync")

    # Expect error when registering an incompatible backend.
    expect_error(
        context$set_backend(backend),
        as_text(Exception$type_not_assignable(Helper$get_class_name(backend), "AsyncBackend"))
    )

    # Get an asynchronous backend instance.
    backend <- backend_factory$get("async")

    # Register the backend with the same context object.
    context$set_backend(backend)

    # Expect the registered backend to be of correct type.
    expect_equal(
        Helper$get_class_name(context$backend),
        Helper$get_class_name(backend)
    )
})


test_that("'ProgressTrackingContext' sets progress bars correctly", {
    # Create a bar factory.
    bar_factory <- BarFactory$new()

    # Create a progress tracking context object.
    context <- ProgressTrackingContext$new()

    # Expect the context to start with no bar.
    expect_null(context$bar)

    # Get a basic bar instance.
    bar <- bar_factory$get("basic")

    # Register the bar with the context object.
    context$set_bar(bar)

    # Expect the registered bar to be of correct type.
    expect_equal(
        Helper$get_class_name(context$bar),
        Helper$get_class_name(bar)
    )

    # Get a modern bar instance.
    bar <- bar_factory$get("modern")

    # Register the bar with the same context object.
    context$set_bar(bar)

    # Expect the registered backend to be of correct type.
    expect_equal(
        Helper$get_class_name(context$bar),
        Helper$get_class_name(bar)
    )
})


test_that("'ProgressTrackingContext' configures the progress bar correctly", {
    # Create a progress tracking context object.
    context <- ProgressTrackingContextTester$new()

    # Expect the context to start without a bar configuration.
    expect_equal(context$bar_config, list())

    # Prepare bar configuration.
    bar_config <- list(
        show_after = 0,
        format = "[:bar] :percent"
    )

    # Configure the bar.
    do.call(context$configure_bar, bar_config)

    # Expect the bar configuration to be set correctly.
    expect_equal(context$bar_config, bar_config)
})


test_that("'ProgressTrackingContext' executes the task in parallel correctly", {
    # Select task arguments for the `sapply` operation.
    x <- sample(1:100, 100)
    y <- sample(1:100, 1)
    z <- sample(1:100, 1)
    sleep = sample(c(0, 0.001, 0.002), 1)

    # Compute the correct output.
    expected_output <- test_task(x, y, z)

    # Create a specification.
    specification <- Specification$new()

    # Set the number of cores.
    specification$set_cores(cores = 2)

    # Determine the cluster type.
    cluster_type <- pick_cluster_type(specification$types)

    # Set the cluster type.
    specification$set_type(type = cluster_type)

    # Create a synchronous backend object.
    backend <- AsyncBackend$new()

    # Create a progress tracking context object.
    context <- ProgressTrackingContextTester$new()

    # Register the backend with the context object.
    context$set_backend(backend)

    # Start the backend.
    context$start(specification)

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
    context$sapply(x, test_task, y = y, z = z, sleep = sleep)

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
    context$sapply(x, test_task, y = y, z = z, sleep = sleep)

    # Expect that the task output is correct.
    expect_equal(context$get_output(wait = TRUE), expected_output)

    # Expect the progress bar was shown correctly.
    expect_true(any(grepl("=\\| 100%", context$progress_bar_output)))

    # Stop the backend.
    context$stop()
})
