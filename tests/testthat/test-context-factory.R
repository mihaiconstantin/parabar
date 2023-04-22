# Test `ContextFactory` class.

test_that("'ContextFactory' produces the correct instance types", {
    # Create a context factory.
   context_factory <- ContextFactory$new()

    # Expect a regular context.
    expect_equal(
        Helper$get_class_name(context_factory$get("regular")),
        "Context"
    )

    # Expect a progress tracking context.
    expect_equal(
        Helper$get_class_name(context_factory$get("progress")),
        "ProgressTrackingContext"
    )

    # Expect error for unsupported context types.
    expect_error(
        context_factory$get("unsupported"),
        as_text(Exception$feature_not_developed())
    )
})
