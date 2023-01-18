#' @include Bar.R

# Blueprint for creating a modern bar.
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
        # Release the constructor (i.e., `R` caveat).
        initialize = NULL,

        # Create.
        create = function(total, initial, ...) {
            private$.create(total, initial, ...)
        },

        # Update.
        update = function(current) {
            private$.update(current)
        },

        # Terminate.
        terminate = function() {
            private$.terminate()
        }
    )
)
