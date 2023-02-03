#' @include Exception.R Service.R

# Blueprint for creating a backend that implements the `Service` interface.
Backend <- R6::R6Class("Backend",
    inherit = Service,

    private = list(
        # The engine used to dispatch the tasks.
        .cluster = NULL,

        # The progress tracking capabilities of the backend implementation.
        .supports_progress = FALSE,

        # The results of running the task on the backend.
        .output = NULL,

        # Whether the backend contains an active cluster.
        .active = FALSE,

        # Toggle active flag.
        .toggle_active_state = function() {
            # The to the opposite state.
            private$.active <- !private$.active
        }
    ),

    public = list(
        # Constructor.
        initialize = function() {
            Exception$abstract_class_not_instantiable(self)
        }
    ),

    active = list(
        # Get the cluster object.
        cluster = function() { return(private$.cluster) },

        # Indicate whether the backend implementation supports progress tracking.
        supports_progress = function() { return(private$.supports_progress) },

        # Get the active state of the cluster.
        active = function() { return(private$.active) }
    )
)
