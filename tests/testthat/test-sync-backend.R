# Test `SyncBackend` class.

test_that("'SyncBackend' creates and manages clusters correctly", {
    # Create a specification.
    specification <- Specification$new()

    # Set the number of cores.
    specification$set_cores(cores = 2)

    # Pick a cluster type.
    cluster_type <- pick_cluster_type(specification$types)

    # Set the cluster type.
    specification$set_type(type = cluster_type)

    # Create a synchronous backend object.
    backend <- SyncBackend$new()

    # Expect the backend to not support progress tracking.
    expect_false(backend$supports_progress)

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

    # Test backend states.
    tests_set_for_backend_states(backend, specification)
})


test_that("'SyncBackend' performs operations on the cluster correctly", {
    # Create a specification.
    specification <- Specification$new()

    # Set the number of cores.
    specification$set_cores(cores = 2)

    # Determine the cluster type.
    cluster_type <- pick_cluster_type(specification$types)

    # Set the cluster type.
    specification$set_type(type = cluster_type)

    # Create a synchronous backend object.
    backend <- SyncBackend$new()

    # Perform tests for synchronous backend operations.
    tests_set_for_synchronous_backend_operations(backend, specification, test_task)
})
