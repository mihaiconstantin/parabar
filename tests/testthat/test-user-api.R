# Test user API functions.

test_that("'set_default_options' sets default options correctly", {
    # Remove any default options existing in the session.
    options(parabar = NULL)

    # Expect that the parabar options are not set.
    expect_null(getOption("parabar"))

    # Set the default options.
    set_default_options()

    # Get the parabar options
    session_options <- getOption("parabar")

    # Expect that the session options are an instance of the `Options` class.
    expect_equal(Helper$get_class_name(session_options), "Options")

    # Create an options instance.
    options <- Options$new()

    # Expect the session options to match the default options instance.
    expect_equal(session_options$progress_track, options$progress_track)
    expect_equal(session_options$progress_timeout, options$progress_timeout)
    expect_equal(session_options$progress_bar_type, options$progress_bar_type)
    expect_equal(session_options$progress_bar_config, options$progress_bar_config)
    expect_equal(session_options$stop_forceful, options$stop_forceful)

    # Expect the progress log path to differ since it is randomly generated.
    expect_false(session_options$progress_log_path == options$progress_log_path)

    # Pick a custom path for the progress log.
    log_path_custom <- "custom_path.log"

    # Fix the log paths on both the session options and the local instance.
    session_options$progress_log_path <- log_path_custom
    options$progress_log_path <- log_path_custom

    # Expect the paths for the progress log to match.
    expect_equal(session_options$progress_log_path, options$progress_log_path)

    # Restore the defaults.
    set_default_options()

    # Expect that the new session options do not match the old session options.
    expect_false(session_options$progress_log_path == getOption("parabar")$progress_log_path)
})


test_that("'get_option' retrieves option values correctly", {
    # Ensure the default options are set.
    set_default_options()

    # Create an options instance.
    options <- Options$new()

    # Expect the values retrieved to match the default field values.
    expect_equal(get_option("progress_track"), options$progress_track)
    expect_equal(get_option("progress_timeout"), options$progress_timeout)
    expect_equal(get_option("progress_bar_type"), options$progress_bar_type)
    expect_equal(get_option("progress_bar_config"), options$progress_bar_config)
    expect_equal(get_option("stop_forceful"), options$stop_forceful)

    # Expect the progress log path to differ since it is randomly generated.
    expect_false(get_option("progress_log_path") == options$progress_log_path)

    # Pick an unknown `parabar` package option.
    unknown <- "unknown_parabar_option"

    # Expect retrieving an unknown option to throw an error.
    expect_error(
        get_option(unknown),
        as_text(Exception$unknown_package_option(unknown))
    )
})


test_that("'set_option' sets option values correctly", {
    # Ensure the default options are set.
    set_default_options()

    # Set known options and expect that values are correctly set.
    set_option("progress_track", FALSE)
    expect_equal(get_option("progress_track"), FALSE)

    set_option("progress_timeout", 0.002)
    expect_equal(get_option("progress_timeout"), 0.002)

    set_option("progress_bar_type", "basic")
    expect_equal(get_option("progress_bar_type"), "basic")

    set_option("progress_bar_config", list(test = "test"))
    expect_equal(get_option("progress_bar_config"), list(test = "test"))

    set_option("stop_forceful", TRUE)
    expect_equal(get_option("stop_forceful"), TRUE)

    # Pick an unknown `parabar` package option.
    unknown <- "unknown_parabar_option"

    # Expect an error for attempting to set unknown options.
    expect_error(
        set_option(unknown, "unknown"),
        as_text(Exception$unknown_package_option(unknown))
    )

    # Restore default options.
    set_default_options()
})


test_that("`configure_bar` sets progress bar configurations correctly", {
    # Ensure the default options are set.
    set_default_options()

    # Set bar type and expect it to be correctly set.
    configure_bar(type = "modern")
    expect_equal(get_option("progress_bar_type"), "modern")

    # Set bar configuration and expect it to be correctly set.
    configure_bar(type = "modern", format = "[:bar] :percent")
    expect_equal(get_option("progress_bar_config")$modern$format, "[:bar] :percent")

    # Set bar type and expect it to be correctly set.
    configure_bar(type = "basic")
    expect_equal(get_option("progress_bar_type"), "basic")

    # Set bar configuration and expect it to be correctly set.
    configure_bar(type = "basic", style = 3)
    expect_equal(get_option("progress_bar_config")$basic$style, 3)

    # Expect an error for attempting to configure unsupported bar types.
    expect_error(
        configure_bar(type = "unsupported"),
        as_text(Exception$feature_not_developed())
    )

    # Restore default options
    set_default_options()
})


test_that("'start_backend' handles different backend and cluster types on Unix correctly", {
    # Skip test on Windows.
    skip_on_os("windows")

    # Expect that the backed is created correctly for different configurations.
    tests_set_for_backend_creation_via_user_api("psock", "sync")
    tests_set_for_backend_creation_via_user_api("fork", "sync")
    tests_set_for_backend_creation_via_user_api("psock", "async")
    tests_set_for_backend_creation_via_user_api("fork", "async")

    # Expect a warning if an incorrect cluster type is requested.
    expect_warning(
        tests_set_for_backend_creation_via_user_api("unknown", "sync"),
        as_text(Warning$requested_cluster_type_not_supported(Specification$new()$types))
    )

    # Expect an error if an incorrect backend type is requested.
    expect_error(
        start_backend(cores = 2, cluster_type = "psock", backend_type = "unknown"),
        as_text(Exception$feature_not_developed())
    )
})


test_that("'start_backend' handles different backend and cluster types on Windows correctly", {
    # Skip test on Unix and the like.
    skip_on_os(c("mac", "linux", "solaris"))

    # Expect that the backed is created correctly for different configurations.
    tests_set_for_backend_creation_via_user_api("psock", "sync")
    tests_set_for_backend_creation_via_user_api("psock", "async")

    # Expect warnings when `FORK` clusters are requested on Windows.
    expect_warning(
        tests_set_for_backend_creation_via_user_api("fork", "sync"),
        as_text(Warning$requested_cluster_type_not_compatible(Specification$new()$types))
    )

    expect_warning(
        tests_set_for_backend_creation_via_user_api("fork", "async"),
        as_text(Warning$requested_cluster_type_not_compatible(Specification$new()$types))
    )

    # Expect a warning if an incorrect cluster type is requested.
    expect_warning(
        tests_set_for_backend_creation_via_user_api("unknown", "sync"),
        as_text(Warning$requested_cluster_type_not_supported(Specification$new()$types))
    )

    # Expect an error if an incorrect backend type is requested.
    expect_error(
        start_backend(cores = 2, cluster_type = "psock", backend_type = "unknown"),
        as_text(Exception$feature_not_developed())
    )
})


test_that("user API functions handle incompatible input correctly", {
    # Create an obviously incorrect backend.
    backend <- "backend"

    # Expect an error passing this backend to the user API functions.
    expect_error(
        stop_backend(backend),
        as_text(Exception$type_not_assignable(class(backend), "Backend"))
    )

    expect_error(
        clear(backend),
        as_text(Exception$type_not_assignable(class(backend), "Backend"))
    )

    expect_error(
        peek(backend),
        as_text(Exception$type_not_assignable(class(backend), "Backend"))
    )

    expect_error(
        export(backend),
        as_text(Exception$type_not_assignable(class(backend), "Backend"))
    )

    expect_error(
        evaluate(backend),
        as_text(Exception$type_not_assignable(class(backend), "Backend"))
    )

    expect_error(
        par_sapply(backend, NULL, NULL),
        as_text(Exception$type_not_assignable(class(backend), "Backend"))
    )

    expect_error(
        par_lapply(backend, NULL, NULL),
        as_text(Exception$type_not_assignable(class(backend), "Backend"))
    )

    expect_error(
        par_apply(backend, NULL, NULL, NULL),
        as_text(Exception$type_not_assignable(class(backend), "Backend"))
    )
})


test_that("user API functions handle basic backend operations correctly", {
    # Select a cluster type.
    cluster_type <- pick_cluster_type(Specification$new()$types)

    # Select a backend type.
    backend_type <- pick_backend_type()

    # Create a backend.
    backend <- start_backend(
        cores = 2,
        cluster_type = cluster_type,
        backend_type = backend_type
    )

    # Expect the backend to be active.
    expect_true(backend$active)

    # Create a dummy variable.
    variable <- "dummy"

    # Export the variable to the backend.
    export(backend, "variable", environment())

    # Check that the variable has the correct name on the backend.
    expect_true(all(peek(backend) == "variable"))

    # Check that the variable has the correct value on the backend.
    expect_true(all(evaluate(backend, variable) == variable))

    # Clear the backend.
    clear(backend)

    # Expect the backend environment to be empty after clearing.
    expect_true(all(sapply(peek(backend), length) == 0))

    # Stop the backend.
    stop_backend(backend)

    # Expect the backend to be inactive after stopping.
    expect_false(backend$active)

    # Expect an error trying to stop an already stopped backend.
    expect_error(
        stop_backend(backend),
        as_text(Exception$cluster_not_active())
    )
})


test_that("user API functions run tasks in parallel correctly", {
    # Select task arguments.
    x <- sample(1:100, 100)
    y <- sample(1:100, 1)
    z <- sample(1:100, 1)
    sleep = sample(c(0, 0.001, 0.002), 1)

    # Compute the expected output for the `par_sapply` user API function.
    expected_output <- test_task(x, y, z)

    # Define the `par_sapply` parallel operation.
    parallel_sapply <- bquote(
        par_sapply(backend, x = .(x), fun = test_task, .(y), .(z), sleep = .(sleep))
    )

    # Define the `par_sapply` sequential operation.
    sequential_sapply <- bquote(
        par_sapply(backend = NULL, x = .(x), fun = test_task, .(y), .(z))
    )

    # Expect the `par_sapply` to run the task in parallel correctly.
    tests_set_for_user_api_task_execution(parallel_sapply, sequential_sapply, expected_output)

    # Compute the expected output for the `par_lapply` user API function.
    expected_output <- as.list(expected_output)

    # Define the `par_lapply` parallel operation.
    parallel_lapply <- bquote(
        par_lapply(backend, x = .(x), fun = test_task, .(y), .(z), sleep = .(sleep))
    )

    # Define the `par_lapply` sequential operation.
    sequential_lapply <- bquote(
        par_lapply(backend = NULL, x = .(x), fun = test_task, .(y), .(z))
    )

    # Expect the `par_lapply` to run the task in parallel correctly.
    tests_set_for_user_api_task_execution(parallel_lapply, sequential_lapply, expected_output)

    # Redefine `x` as a matrix for the `apply` operation.
    x <- matrix(rnorm(100^2), nrow = 100, ncol = 100)

    # Select a random margin for the matrix.
    margin <- sample(1:2, 1)

    # Compute the expected output for the `par_apply` user API function.
    expected_output <- base::apply(x, margin, test_task, y = y, z = z)

    # Define the `par_apply` parallel operation.
    parallel_apply <- bquote(
        par_apply(backend, x = .(x), margin = .(margin), fun = test_task, .(y), .(z), sleep = .(sleep))
    )

    # Define the `par_apply` sequential operation.
    sequential_apply <- bquote(
        par_apply(backend = NULL, x = .(x), margin = .(margin), fun = test_task, .(y), .(z))
    )

    # Expect the `par_apply` to run the task in parallel correctly.
    tests_set_for_user_api_task_execution(parallel_apply, sequential_apply, expected_output)
})


test_that("user API functions track progress correctly", {
    # Run the test only in interactive contexts.
    if (interactive()) {
        # Expect progress tracking is displayed correctly via `par_sapply`.
        tests_set_for_user_api_progress_tracking(bquote(
            par_sapply(backend, x = 1:100, fun = test_task, 1, 2)
        ))

        # Expect progress tracking is displayed correctly via `par_lapply`.
        tests_set_for_user_api_progress_tracking(bquote(
            par_lapply(backend, x = 1:100, fun = test_task, 1, 2)
        ))

        # Create a matrix for the `apply` operation.
        x <- matrix(rnorm(50^2), nrow = 50, ncol = 50)

        # Select a random margin for the matrix.
        margin <- sample(1:2, sample(1:2, 1))

        # Expect progress tracking is displayed correctly via `par_apply`.
        tests_set_for_user_api_progress_tracking(bquote(
            par_apply(backend, x = .(x), margin = .(margin), fun = test_task, 1, 2)
        ))

    } else {
        skip("Test only runs in interactive contexts.")
    }
})
