#' @include Exception.R BackendService.R

#' @title
#' Backend
#'
#' @description
#' This is an abstract class that serves as a base class for all concrete
#' backend implementations. It defines the common properties that all concrete
#' backends require.
#'
#' @details
#' This class cannot be instantiated. It needs to be extended by concrete
#' subclasses that implement the pure virtual methods. Instances of concrete
#' backend implementations can be conveniently obtained using the
#' [`parabar::BackendFactory`] class.
#'
#' @seealso
#' [`parabar::BackendService`], [`parabar::SyncBackend`],
#' [`parabar::AsyncBackend`], [`parabar::BackendFactory`], and
#' [`parabar::Context`].
#'
#' @export
Backend <- R6::R6Class("Backend",
    inherit = BackendService,

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
        #' Instantiating this class will throw an error.
        initialize = function() {
            Exception$abstract_class_not_instantiable(self)
        }
    ),

    active = list(
        #' @field cluster The cluster object used by the backend. For
        #' [`parabar::SyncBackend`] objects, this is a cluster object created by
        #' [parallel::makeCluster()]. For [`parabar::AsyncBackend`] objects,
        #' this is a permanent `R` session created by [`callr::r_session`] that
        #' contains the [parallel::makeCluster()] cluster object.
        cluster = function() { return(private$.cluster) },

        #' @field supports_progress A boolean value indicating whether the
        #' backend implementation supports progress tracking.
        supports_progress = function() { return(private$.supports_progress) },

        #' @field active A boolean value indicating whether the backend
        #' implementation has an active cluster.
        active = function() { return(private$.active) }
    )
)
