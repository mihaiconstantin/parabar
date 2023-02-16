#' @include Bar.R

#' @title
#' BasicBar
#'
#' @description
#' This is a concrete implementation of the abstract class [`parabar::Bar`]
#' using the [`utils::txtProgressBar()`] as engine for the progress bar.
#'
#' @seealso
#' [`parabar::Bar`], [`parabar::ModernBar`]
#'
#' @export
BasicBar <- R6::R6Class("BasicBar",
    inherit = Bar,

    private = list(
        # Create bar.
        .create = function(total, initial, ...) {
            # Create and store the bar object.
            private$.bar <- do.call(
                utils::txtProgressBar,
                utils::modifyList(
                    list(min = 0, max = total, initial = initial), list(...)
                )
            )
        },

        # Update bar.
        .update = function(current) {
            # Perform the update.
            utils::setTxtProgressBar(private$.bar, current)
        },

        # Terminate the bar.
        .terminate = function() {
            # Close the bar.
            close(private$.bar)
        }
    ),

    public = list(
        #' @description
        #' Create a new [`parabar::BasicBar`] object.
        #'
        #' @return
        #' An object of class [`parabar::BasicBar`].
        initialize = function() {},

        #' @description
        #' Create a progress bar.
        #'
        #' @param total The total number of times the progress bar should tick.
        #'
        #' @param initial The starting point of the progress bar.
        #'
        #' @param ... Additional arguments for the bar creation passed to
        #' [`utils::txtProgressBar()`].
        #'
        #' @return
        #' This method returns void. The resulting bar is stored in the private
        #' field `.bar`, accessible via the active binding `engine`. Both the
        #' private field and the active binding are defined in the super class
        #' [`parabar::Bar`].
        create = function(total, initial, ...) {
            private$.create(total, initial, ...)
        },

        #' @description
        #' Update the progress bar by calling [`utils::setTxtProgressBar()`].
        #'
        #' @param current The position the progress bar should be at (e.g., 30
        #' out of 100), usually the index in a loop.
        update = function(current) {
            private$.update(current)
        },

        #' @description
        #' Terminate the progress bar by calling [`utils::close()`] on the
        #' private field `.bar`.
        terminate = function() {
            private$.terminate()
        }
    )
)
