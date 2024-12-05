# Test static function of the `Helper` class.

test_that("'Helper$propagate_interrupt' sends interrupt signals correctly", {
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

    # Start the backend.
    backend$start(specification)

    # Get the worker process `IDs`.
    worker_pids <- Helper$get_worker_pids(backend)

    # Get worker handles.
    worker_handles <- lapply(worker_pids, ps::ps_handle)

    # Keep just the cluster busy.
    backend$cluster$call(function() {
        # Sleep for quite a bit.
        Sys.sleep(10)
    })

    # Propagate an interrupt signal to the cluster and the workers.
    Helper$propagate_interrupt(backend, worker_pids)

    # Expect the cluster to throw an error.
    expect_error(backend$get_output(wait = TRUE), "callr subprocess interrupted")

    # Expect that the cluster is idle.
    expect_true(backend$session_state$session_is_idle)

    # Expect the workers to be free.
    expect_equal(unlist(evaluate(backend, "Worker free.")), rep("Worker free.", 2))

    # Keep both the session and the workers busy.
    backend$sapply(1:10, function(x) {
        # Sleep for quite a bit.
        Sys.sleep(1)
    })

    # Propagate an interrupt signal to the cluster and the workers.
    Helper$propagate_interrupt(backend, worker_pids)

    # Expect the cluster to throw an error.
    expect_error(backend$get_output(wait = TRUE), "callr subprocess interrupted")

    # Expect that the cluster is idle.
    expect_true(backend$session_state$session_is_idle)

    # Expect the workers to be free.
    expect_equal(unlist(evaluate(backend, "Worker free.")), rep("Worker free.", 2))

    # Expect that the session is alive.
    expect_true(backend$session_state$session_is_idle)

    # Expect that the workers are still alive.
    expect_true(ps::ps_is_running(worker_handles[[1]]))
    expect_true(ps::ps_is_running(worker_handles[[2]]))

    # Stop the backend.
    backend$stop()

    # Perform a full garbage collection (i.e., unsure if this is necessary).
    gc(full = TRUE)

    # Add a short delay before checking whether the workers are still alive.
    Sys.sleep(0.1)

    # Expect that the workers are not alive.
    expect_false(ps::ps_is_running(worker_handles[[1]]))
    expect_false(ps::ps_is_running(worker_handles[[2]]))
})
