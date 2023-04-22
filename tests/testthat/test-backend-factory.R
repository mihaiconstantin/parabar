# Test `BackendFactory` class.

test_that("'BackendFactory' produces the correct instance types", {
    # Create a backend factory.
    backend_factory <- BackendFactory$new()

    # Expect a synchronous backend.
    expect_equal(
        Helper$get_class_name(backend_factory$get("sync")),
        "SyncBackend"
    )

    # Expect an asynchronous backend.
    expect_equal(
        Helper$get_class_name(backend_factory$get("async")),
        "AsyncBackend"
    )

    # Expect error for unsupported backend types.
    expect_error(
        backend_factory$get("unsupported"),
        as_text(Exception$feature_not_developed())
    )
})
