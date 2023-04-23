# Test `Options` class.

test_that("'Options' class fields work correctly", {
    # Create an instance of the Options class.
    options <- Options$new()

    # Expect that the public fields have the correct defaults.
    expect_true(options$progress_track)
    expect_equal(options$progress_timeout, 0.001)
    expect_equal(options$progress_bar_type, "modern")

    # Expect the correct default config for the modern progress bar.
    expect_equal(
        options$progress_bar_config$modern,
        list(
            show_after = 0,
            format = " > completed :current out of :total tasks [:percent] [:elapsed]"
        )
    )

    # Expect the correct default config for the basic progress bar.
    expect_equal(
        options$progress_bar_config$basic,
        list()
    )

    # Create temporary paths for the progress log.
    log_path_1 <- options$progress_log_path
    log_path_2 <- options$progress_log_path

    # Expect the temporary paths to be different.
    expect_false(log_path_1 == log_path_2)

    # Set a custom path for the progress log.
    log_path_custom <- "custom_path.log"

    # Set the path on the options instance.
    options$progress_log_path <- log_path_custom

    # Expect that the log path is not fixed to the custom one.
    expect_equal(options$progress_log_path, log_path_custom)

    # Expect that subsequent calls to the log path yield the fixed path.
    expect_equal(options$progress_log_path, log_path_custom)

    # Reset the progress_log_path to default (i.e., enabling temporary paths).
    options$progress_log_path <- NULL

    # Generate a temporary log path.
    log_path_3 <- options$progress_log_path

    # Expect the log path is a temporary one again.
    expect_false(log_path_3 == log_path_custom)
})
