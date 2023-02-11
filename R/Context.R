#' @include Backend.R

# Blueprint for creating a vanilla context manager for consuming backend APIs.
Context <- R6::R6Class("Context",
    private = list(
        # The backend used by the context manager.
        .backend = NULL
    ),

    public = list(
        # Set the backend.
        set_backend = function(backend) {
            private$.backend <- backend
        },

        # Start a backend.
        start = function(specification) {
            # Consume the backend API.
            private$.backend$start(specification)
        },

        # Stop the backend.
        stop = function() {
            # Consume the backend API.
            private$.backend$stop()
        },

        # Clear the backend.
        clear = function() {
            # Consume the backend API.
            private$.backend$clear()
        },

        # Inspect the backend.
        peek = function() {
            # Consume the backend API.
            private$.backend$peek()
        },

        # Export variables on the backend.
        export = function(variables, environment) {
            # Consume the backend API.
            # TODO: Check that this works as expected (i.e., the environment).
            private$.backend$export(variables, environment)
        },

        # Evaluate an expression on the backend.
        evaluate = function(expression) {
            # Consume the backend API.
            private$.backend$evaluate(expression)
        },

        # Run tasks on the backend.
        sapply = function(x, fun, ...) {
            # Consume the backend API.
            private$.backend$sapply(x = x, fun = fun, ...)
        },

        # Return the task results.
        get_output = function(...) {
            # Consume the backend API.
            private$.backend$get_output(...)
        }
    ),

    active = list(
        # Get the currently set backend.
        backend = function() { return(private$.backend) }
    )
)
