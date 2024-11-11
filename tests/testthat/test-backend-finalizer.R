# Test automatic finalizers for `SyncBackend` and `AsyncBackend` objects.

test_that("'SyncBackend' finalizer executes without throwing", {
    # Define a simple task.
    task <- function(x) {
        # Sleep a bit.
        Sys.sleep(0.0025)

        # Return the value.
        return(x)
    }

    # Start a synchronous backend.
    backend <- start_backend(cores = 2, backend_type = "sync")

    # Run a task on the backend.
    backend$sapply(1:100, task)

    # Remove the backend.
    rm(backend)

    # Trigger the garbage collection.
    gc(verbose = FALSE)

    # Check that no `backend` variable is present.
    expect_false(exists("backend"))
})


test_that("'AsyncBackend' finalizer executes without throwing", {
    # Define a simple task.
    task <- function(x) {
        # Sleep a bit.
        Sys.sleep(0.0025)

        # Return the value.
        return(x)
    }

    # Create text connection.
    connection <- textConnection("log", open = "w")

    # Ensure forceful stop is disabled.
    set_option("stop_forceful", FALSE)

    # Define warning pattern to match.
    pattern <- "Caught error in 'AsyncBackend' finalizer"

    # #region Test finalizer with a running task.

    # Start an asynchronous backend.
    backend <- start_backend(cores = 2, backend_type = "async")

    # Run a task on the backend.
    backend$sapply(1:100, task)

    # Remove the backend.
    rm(backend)

    # Trigger the garbage collection.
    gc(verbose = FALSE)

    # #endregion

    # #region Test finalizer with unread results.

    # Start an asynchronous backend.
    backend <- start_backend(cores = 2, backend_type = "async")

    # Run a task on the backend.
    backend$sapply(1:100, task)

    # Block the main session until the task is completed.
    block_until_async_task_finished(backend)

    # Remove the backend.
    rm(backend)

    # Trigger the garbage collection.
    gc(verbose = FALSE)

    # #endregion

   # Enable forceful stop.
    set_option("stop_forceful", TRUE)

    # #region Test finalizer with forceful stop while task is running.

    # Start an asynchronous backend.
    backend <- start_backend(cores = 2, backend_type = "async")

    # Run a task on the backend.
    backend$sapply(1:100, task)

    # Remove the backend.
    rm(backend)

    # Trigger the garbage collection.
    gc(verbose = FALSE)

    # #endregion

    # #region Test finalizer with forceful stop while task has unread results.

    # Start an asynchronous backend.
    backend <- start_backend(cores = 2, backend_type = "async")

    # Run a task on the backend.
    backend$sapply(1:100, task)

    # Block the main session until the task is completed.
    block_until_async_task_finished(backend)

    # Remove the backend.
    rm(backend)

    # Trigger the garbage collection.
    gc(verbose = FALSE)

    # #endregion

    # Check that no `backend` variable is present.
    expect_false(exists("backend"))

    # Restore options defaults.
    set_default_options()
})
