# Test `BackendService` interface.

test_that("'BackendService' interface cannot be instantiated", {
    # Create a mock object that has the `BackendService` class.
    assign("object", "Mock Backend Service", envir = environment())

    # Assign a class to the mock service object.
    class(object) <- "BackendService"

    # Expect an error upon instantiation.
    expect_error(
        BackendService$new(),
        as_text(Exception$abstract_class_not_instantiable(object))
    )
})


test_that("'BackendService' interface methods throw errors", {
    # Create an improper backend service implementation.
    service <- BackendServiceImplementation$new()

    # Expect unimplemented backend service methods to throw errors.
    tests_set_for_unimplemented_service_methods(service)
})
