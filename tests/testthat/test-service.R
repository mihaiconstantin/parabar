# Test `Service` interface.

test_that("'Service' interface cannot be instantiated", {
    # Create a mock object that has the `Service` class.
    assign("object", "Mock Service", envir = environment())

    # Assign a class to the mock service object.
    class(object) <- "Service"

    # Expect an error upon instantiation.
    expect_error(
        Service$new(),
        as_text(Exception$abstract_class_not_instantiable(object))
    )
})


test_that("'Service' interface methods throw errors", {
    # Create an improper service implementation.
    service <- ServiceImplementation$new()

    # Expect unimplemented service methods to throw errors.
    tests_set_for_unimplemented_service_methods(service)
})
