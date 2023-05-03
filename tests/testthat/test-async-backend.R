# Test `AsyncBackend` class.

test_that("'AsyncBackend' creates and manages clusters correctly", {
    # Create a specification.
    specification <- Specification$new()

    # Set the number of cores.
    specification$set_cores(cores = 2)

    # Pick a cluster type.
    cluster_type <- pick_cluster_type(specification$types)

    # Let the specification determine the cluster type.
    specification$set_type(type = cluster_type)

    # Create a synchronous backend object.
    backend <- AsyncBackend$new()

    # Expect the backend to support progress tracking.
    expect_true(backend$supports_progress)

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

    # Test backend states.
    tests_set_for_backend_states(backend, specification)

    # Expect error attempting to get the cluster state for an inactive backend.
    expect_error(backend$task_state, as_text(Exception$cluster_not_active()))
})


test_that("'AsyncBackend' performs operations on the cluster correctly", {
    # Create a specification.
    specification <- Specification$new()

    # Set the number of cores.
    specification$set_cores(cores = 2)

    # Determine the cluster type.
    cluster_type <- pick_cluster_type(specification$types)

    # Determine the cluster type automatically.
    specification$set_type(type = cluster_type)

    # Create a synchronous backend object.
    backend <- AsyncBackend$new()

    # Perform tests for asynchronous backend operations.
    tests_set_for_asynchronous_backend_operations(backend, specification, test_task)
})
