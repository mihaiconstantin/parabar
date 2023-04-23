# Test `Backend` class.

test_that("'Backend' class cannot be instantiated", {
    # Create a mock object that has the `Service` class.
    assign("object", "Mock Backend", envir = environment())

    # Assign a class to the mock service object.
    class(object) <- "Backend"

    # Expect an error upon instantiation.
    expect_error(
        Backend$new(),
        as_text(Exception$abstract_class_not_instantiable(object))
    )
})


test_that("'Backend' abstract class methods throw errors", {
    # Create an improper backend implementation.
    backend <- BackendImplementation$new()

    # Expect unimplemented service methods to throw errors.
    tests_set_for_unimplemented_service_methods(backend)
})


test_that("'Backend' abstract class fields have correct default values", {
    # Create an improper backend implementation.
    backend <- BackendImplementation$new()

    # Expect the correct default value for the `cluster` field.
    expect_null(backend$cluster)

    # Expect the correct default value for the `supports_progress` field.
    expect_false(backend$supports_progress)

    # Expect the correct default value for the `active` field.
    expect_false(backend$active)
})
