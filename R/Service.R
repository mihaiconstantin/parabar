#' @include Exception.R

# Interface for services providing by a backend implementation.
Service <- R6::R6Class("Service",
    public = list(
        # Constructor.
        initialize = function() {
            Exception$abstract_class_not_instantiable(self)
        },

        # Abstract method for starting a backend.
        start = function(specification) {
            Exception$method_not_implemented()
        },

        # Abstract method for stopping a backend.
        stop = function() {
            Exception$method_not_implemented()
        },

        # Abstract method for cleansing the backend.
        clear = function() {
            Exception$method_not_implemented()
        },

        # Abstract method for inspecting the backend.
        peek = function() {
            Exception$method_not_implemented()
        },

        # Abstract method for exporting variables on the backend.
        export = function(variables, environment) {
            Exception$method_not_implemented()
        },

        # Abstract method for evaluating an expression on the backend.
        evaluate = function(expression) {
            Exception$method_not_implemented()
        },

        # Abstract method for running tasks on the backend.
        sapply = function(x, fun, ...) {
            Exception$method_not_implemented()
        },

        # Abstract method for returning the task results.
        get_output = function() {
            Exception$method_not_implemented()
        }
    )
)
