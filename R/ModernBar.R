#' @include Bar.R

#' @title
#' ModernBar
#'
#' @description
#' This is a concrete implementation of the abstract class [`parabar::Bar`]
#' using the [`progress::progress_bar`] as engine for the progress bar.
#'
#' @examples
#' # Create a modern bar instance.
#' bar <- ModernBar$new()
#'
#' # Specify the number of ticks to be performed.
#' total <- 100
#'
#' # Create the progress bar.
#' bar$create(total = total, initial = 0)
#'
#' # Use the progress bar.
#' for (i in 1:total) {
#'     # Sleep a bit.
#'     Sys.sleep(0.02)
#'
#'     # Update the progress bar.
#'     bar$update(i)
#' }
#'
#' # Terminate the progress bar.
#' bar$terminate()
#'
#' @seealso
#' [`parabar::Bar`], [`parabar::BasicBar`], and [`parabar::BarFactory`].
#'
#' @export
ModernBar <- R6::R6Class("ModernBar",
    inherit = Bar,

    private = list(
        .total = NULL,

        # Create bar.
        .create = function(total, initial, ...) {
            # Store the total ticks to be performed.
            private$.total <- total

            # Create and store the bar object.
            private$.bar <- do.call(
                progress::progress_bar$new,
                utils::modifyList(
                    list(total = private$.total), list(...)
                )
            )

            # Perform the initial tick.
            private$.bar$tick(initial)

            # Stay silent.
            invisible()
        },

        # Update bar.
        .update = function(current) {
            # Perform the update.
            private$.bar$update(current / private$.total)

            # Stay silent.
            invisible()
        },

        # Terminate the bar.
        .terminate = function() {
            # Close the bar.
            private$.bar$terminate()

            # Stay silent.
            invisible()
        }
    ),

    public = list(
        #' @description
        #' Create a new [`parabar::ModernBar`] object.
        #'
        #' @return
        #' An object of class [`parabar::ModernBar`].
        initialize = function() {},

        #' @description
        #' Create a progress bar.
        #'
        #' @param total The total number of times the progress bar should tick.
        #'
        #' @param initial The starting point of the progress bar.
        #'
        #' @param ... Additional arguments for the bar creation passed to
        #' [`progress::progress_bar$new()`][`progress::progress_bar`].
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
        #' Update the progress bar by calling
        #' [`progress::progress_bar$update()`][`progress::progress_bar`].
        #'
        #' @param current The position the progress bar should be at (e.g., 30
        #' out of 100), usually the index in a loop.
        update = function(current) {
            private$.update(current)
        },

        #' @description
        #' Terminate the progress bar by calling
        #' [`progress::progress_bar$terminate()`][`progress::progress_bar`].
        terminate = function() {
            private$.terminate()
        }
    )
)
