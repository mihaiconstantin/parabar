# Test `Bar` class.

test_that("'Bar' class cannot be instantiated", {
    # Create a mock object that has the `Service` class.
    assign("object", "Mock Bar", envir = environment())

    # Assign a class to the mock service object.
    class(object) <- "Bar"

    # Expect an error upon instantiation.
    expect_error(Bar$new(), as_text(Exception$abstract_class_not_instantiable(object)))
})


test_that("'Bar' abstract class methods throw errors", {
    # Create an improper bar implementation.
    bar <- BarImplementation$new()

    # Expect an error when calling the `create` method.
    expect_error(bar$create(), as_text(Exception$method_not_implemented()))

    # Expect an error when calling the `update` method.
    expect_error(bar$update(), as_text(Exception$method_not_implemented()))

    # Expect an error when calling the `terminate` method.
    expect_error(bar$terminate(), as_text(Exception$method_not_implemented()))
})


test_that("'Bar' abstract class fields have correct default values", {
    # Create an improper bar implementation.
    bar <- BarImplementation$new()

    # Expect the correct default value for the `engine` field.
    expect_null(bar$engine)
})
