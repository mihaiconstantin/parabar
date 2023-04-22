# Test `Context` class.

test_that("'Context' sets the backend correctly", {
    # Create a backend factory.
    backend_factory <- BackendFactory$new()

    # Create a base context object.
    context <- Context$new()

    # Expect the context to start with no backend.
    expect_null(context$backend)

    # Get a synchronous backend instance.
    backend <- backend_factory$get("sync")

    # Register the backend with the context.
    context$set_backend(backend)

    # Expect the registered backend to be of correct type.
    expect_equal(
        Helper$get_class_name(context$backend),
        Helper$get_class_name(backend)
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


test_that("'Context' performs operations on the cluster correctly", {
    # Create a specification.
    specification <- Specification$new()

    # Set the number of cores.
    specification$set_cores(cores = 2)

    # Select a cluster type.
    cluster_type <- pick_cluster_type(specification$types)

    # Ser the cluster type.
    specification$set_type(type = cluster_type)

    # Create a backend factory.
    backend_factory <- BackendFactory$new()

    # Create a base context object.
    context <- Context$new()

    # Get a synchronous backend instance.
    backend <- backend_factory$get("sync")

    # Register the synchronous backend with the context.
    context$set_backend(backend)

    # Perform tests for synchronous backend operations.
    tests_set_for_synchronous_backend_operations(context, specification, test_task)

    # Get an asynchronous backend instance.
    backend <- backend_factory$get("async")

    # Register the asynchronous backend with the context.
    context$set_backend(backend)

    # Perform tests for synchronous backend operations.
    tests_set_for_asynchronous_backend_operations(context, specification, test_task)
})
