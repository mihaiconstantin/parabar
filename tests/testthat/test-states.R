# Test `SessionState` and `TaskState` classes.

test_that("'SessionState' correctly reports the state given the backend operations", {
    # Create a specification.
    specification <- Specification$new()

    # Set the number of cores.
    specification$set_cores(cores = 2)

    # Pick a cluster type.
    cluster_type <- pick_cluster_type(specification$types)

    # Let the specification determine the cluster type.
    specification$set_type(type = cluster_type)

    # Create an asynchronous backend object.
    backend <- AsyncBackend$new()

    # Start the cluster on the backend.
    backend$start(specification)

    # Expect the session to have been started (i.e., due to the wait timeout).
    expect_false(backend$session_state$session_is_starting)

    # Expect the session to be idle (i.e., it starts with a wait timeout).
    expect_true(backend$session_state$session_is_idle)

    # Run a task on the backend.
    backend$sapply(1:100, function(x) {
        # Sleep a bit.
        Sys.sleep(0.005)

        # Return the value.
        return(x)
    })

    # Expect the session to be busy (i.e., it is running a task).
    expect_true(backend$session_state$session_is_busy)

    # Wait to read the results into the main session.
    results <- backend$get_output(wait = TRUE)

    # Expect the session to be idle (i.e., it has finished with read results).
    expect_true(backend$session_state$session_is_idle)

    # Manually close the session.
    backend$cluster$close()

    # Expect the session to be finished (i.e., it has been closed).
    expect_true(backend$session_state$session_is_finished)

    # Stop the backend.
    backend$stop()
})


test_that("'TaskState' correctly reports the state given the backend operations", {
    # Create a specification.
    specification <- Specification$new()

    # Set the number of cores.
    specification$set_cores(cores = 2)

    # Pick a cluster type.
    cluster_type <- pick_cluster_type(specification$types)

    # Let the specification determine the cluster type.
    specification$set_type(type = cluster_type)

    # Create an asynchronous backend object.
    backend <- AsyncBackend$new()

    # Start the cluster on the backend.
    backend$start(specification)

    # Expect the task to not have started.
    expect_true(backend$task_state$task_not_started)

    # Run a task on the backend.
    backend$sapply(1:100, function(x) {
        # Sleep a bit.
        Sys.sleep(0.005)

        # Return the value.
        return(x)
    })

    # Expect the task to be running.
    expect_true(backend$task_state$task_is_running)

    # Block the main session until the task is completed.
    block_until_async_task_finished(backend)

    # Expect the task to be completed (i.e., with unread results).
    expect_true(backend$task_state$task_is_completed)

    # Read the results into the main session.
    results <- backend$get_output()

    # Expect the task to not have started.
    expect_true(backend$task_state$task_not_started)

    # Stop the backend.
    backend$stop()
})
