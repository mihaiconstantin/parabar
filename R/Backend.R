#' @include Exception.R Service.R

#' @title
#' Backend
#'
#' @description
#' This is an abstract class that serves as a base class for all concrete
#' backend implementations. It defines the common properties that all concrete
#' backends require.
#'
#' @seealso
#' [`parabar::Service`], [`parabar::SyncBackend`], [`parabar::AsyncBackend`]
#'
#' @export
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
        #' @description
        #' Create a new [`parabar::Backend`] object.
        #'
        #' @return
        #' Instantiating this call will throw an error.
        initialize = function() {
            Exception$abstract_class_not_instantiable(self)
        }
    ),

    active = list(
        #' @field cluster The cluster object used by the backend.
        cluster = function() { return(private$.cluster) },

        #' @field supports_progress A boolean value indicating whether the
        #' backend implementation supports progress tracking.
        supports_progress = function() { return(private$.supports_progress) },

        #' @field active A boolean value indicating whether the backend
        #' implementation has an active cluster.
        active = function() { return(private$.active) }
    )
)
