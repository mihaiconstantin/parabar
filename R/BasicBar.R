#' @include Bar.R

# Blueprint for creating a basic bar.
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
