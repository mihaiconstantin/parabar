# Test automatic finalizers for `SyncBackend` and `AsyncBackend` objects.

test_that("'SyncBackend' finalizer executes without throwing", {
    # Start a synchronous backend.
    backend <- start_backend(cores = 2, backend_type = "sync")

    # Run a task on the backend.
    backend$sapply(1:100, function(x) x)

    # Remove the backend.
    rm(backend)

    # Trigger the garbage collection.
    gc(verbose = FALSE)

    # Check that no `backend` variable is present.
    expect_false(exists("backend"))
})


test_that("'AsyncBackend' finalizer executes without throwing", {
    # Define a simple task with non-trivial computation time.
    task <- function(x) {
        # Sleep a bit.
        Sys.sleep(0.001)

        # Return the value.
        return(x)
    }

    # Ensure forceful stop is disabled.
    set_option("stop_forceful", FALSE)

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
    backend$sapply(1:100, function(x) x)

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
    backend$sapply(1:100, function(x) x)

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
