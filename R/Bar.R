#' @include Exception.R

Bar <- R6::R6Class("Bar",
    private = list(
        .bar = NULL
    ),

    public = list(
        initialize = function() {
            Exception$abstract_class_not_instantiable(self)
        },

        # Abstract method for creating a progress bar.
        create = function(total, initial, ...) {
            Exception$method_not_implemented()
        },

        # Abstract method for updating a progress bar.
        update = function(current) {
            Exception$method_not_implemented()
        },

        # Abstract method for terminating a progress bar.
        terminate = function() {
            Exception$method_not_implemented()
        }
    ),

    active = list(
        # Get the bar engine.
        engine = function() { return(private$.bar) }
    )
)
