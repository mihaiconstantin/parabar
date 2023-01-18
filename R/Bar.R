#' @include constants.R

Bar <- R6::R6Class("Bar",
    private = list(
        .bar = NULL
    ),

    public = list(
        initialize = function() {
            stop(.__ERRORS__$abstract_class)
        },

        # Abstract method for creating a progress bar.
        create = function(total, initial, ...) {
            stop(.__ERRORS__$not_implemented)
        },

        # Abstract method for updating a progress bar.
        update = function(current) {
            stop(.__ERRORS__$not_implemented)
        },

        # Abstract method for terminating a progress bar.
        terminate = function() {
            stop(.__ERRORS__$not_implemented)
        }
    )
)
