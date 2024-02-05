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


test_that("'ProgressTrackingContext' sets the progress bar correctly", {
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


test_that("'ProgressTrackingContext' creates log files correctly", {
    # Reset default package options on exit.
    on.exit({
        # Set defaults.
        set_default_options()
    })

    # Create a progress tracking context object.
    context <- ProgressTrackingContextTester$new()

    # Create a log file with a randomly generated path.
    path <- context$make_log()

    # Expect that the file exist at the used path.
    expect_true(file.exists(path))

    # Remove the file.
    file.remove(path)

    # Pick a specific log path.
    log_path <- tempfile(pattern = "progress_log")

    # Fix the log path.
    set_option("progress_log_path", log_path)

    # Create a log file with the fixed log path.
    path <- context$make_log()

    # Expect that the correct log path was used.
    expect_equal(log_path, path)

    # Expect that the log file was created at the fixed path.
    expect_true(file.exists(path))

    # Remove the file.
    file.remove(path)

    # Pick an absurd path for the log file.
    log_path_absurd <- "/absurd/log/file/path"

    # Fix the log path to the absurd value.
    set_option("progress_log_path", log_path_absurd)

    # Expect error when failing to create the log file.
    expect_error(
        context$make_log(),
        as_text(Exception$temporary_file_creation_failed(log_path_absurd))
    )

    # Expect that the log file was not created at the absurd path.
    expect_false(file.exists(log_path_absurd))
})


test_that("'ProgressTrackingContext' decorates tasks with progress tracking correctly", {
    # Create a progress tracking context object.
    context <- ProgressTrackingContextTester$new()

    # Pick a specific log path.
    log <- "/some/parabar/log/path"

    # Decorate a function with compound expression body (i.e., `{`).
    decorated_task <- context$decorate(task = function(x) { x + 1 }, log = log)

    # Expect correct decoration for compound expressions.
    expect_true(body_contains(decorated_task, pattern = log, position = 2))

    # Decorate an inline function.
    decorated_task <- context$decorate(task = function(x) x + 1, log = log)

    # Expect correct decoration for inline functions.
    expect_true(body_contains(decorated_task, pattern = log, position = 2))

    # Decorate a `base` method that uses method dispatching.
    decorated_task <- context$decorate(task = base::mean, log = log)

    # Expect correct decoration for `base` methods.
    expect_true(body_contains(decorated_task, pattern = log, position = 2))

    # Expect the decoration to fail for primitive functions.
    expect_error(
        context$decorate(task = sum, log = log),
        as_text(Exception$primitive_as_task_not_allowed())
    )

    # Decorate a wrapped primitive function.
    decorated_task <- context$decorate(task = function(x) sum(x), log = log)

    # Expect correct decoration for wrapped primitive functions.
    expect_true(body_contains(decorated_task, pattern = log, position = 2))
})


test_that("'ProgressTrackingContext' executes the task in parallel correctly", {
    # Create a specification.
    specification <- Specification$new()

    # Set the number of cores.
    specification$set_cores(cores = 2)

    # Determine the cluster type.
    cluster_type <- pick_cluster_type(specification$types)

    # Set the cluster type.
    specification$set_type(type = cluster_type)

    # Create an asynchronous backend object.
    backend <- AsyncBackend$new()

    # Create a progress tracking context object.
    context <- ProgressTrackingContextTester$new()

    # Register the backend with the context object.
    context$set_backend(backend)

    # Start the backend.
    context$start(specification)

    # Expect correctly executed tasks and logged progress.
    tests_set_for_progress_tracking_context(context, test_task)

    # Stop the backend.
    context$stop()
})


test_that("'ProgressTrackingContext' interrupts progress tracking on task error correctly", {
    # Create a specification.
    specification <- Specification$new()

    # Set the number of cores.
    specification$set_cores(cores = 2)

    # Determine the cluster type.
    cluster_type <- pick_cluster_type(specification$types)

    # Set the cluster type.
    specification$set_type(type = cluster_type)

    # Create an asynchronous backend object.
    backend <- AsyncBackend$new()

    # Create a progress tracking context object.
    context <- ProgressTrackingContextTester$new()

    # Register the backend with the context object.
    context$set_backend(backend)

    # Start the backend.
    context$start(specification)

    # Expect correctly interrupted progress bars.
    tests_set_for_progress_tracking_context_with_error(context)

    # Stop the backend.
    context$stop()
})
