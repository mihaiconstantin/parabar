# Test `BarFactory` class.

test_that("'BarFactory' produces the correct instance types", {
    # Create a bar factory.
   bar_factory <- BarFactory$new()

    # Expect a basic bar.
    expect_equal(
        Helper$get_class_name(bar_factory$get("basic")),
        "BasicBar"
    )

    # Expect a modern bar.
    expect_equal(
        Helper$get_class_name(bar_factory$get("modern")),
        "ModernBar"
    )

    # Expect error for unsupported bar types.
    expect_error(
        bar_factory$get("unsupported"),
        as_text(Exception$feature_not_developed())
    )
})
