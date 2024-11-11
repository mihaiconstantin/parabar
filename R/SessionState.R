#' @title
#' SessionState
#'
#' @description
#' This class holds the state of a background [`session`][`callr::r_session`]
#' used by an asynchronous backend (i.e., [`parabar::AsyncBackend`]). See the
#' **Details** section for more information.
#'
#' @details
#' The session state is useful to check if an asynchronous backend is ready for
#' certain operations. A session can only be in one of the following four states
#' at a time:
#' - `session_is_starting`: When `TRUE`, it indicates that the session is
#'   starting.
#' - `session_is_idle`: When `TRUE`, it indicates that the session is idle and
#'   ready to execute operations.
#' - `session_is_busy`: When `TRUE`, it indicates that the session is busy
#'   (i.e., see the [`parabar::TaskState`] class for more information about a
#'   task's state).
#' - `session_is_finished`: When `TRUE`, it indicates that the session is closed
#'   and no longer available for operations.
#'
#' @examples
#' # Handy function to print the session states all at once.
#' check_state <- function(session) {
#'     # Create a session object and determine its state.
#'     session_state <- SessionState$new(session)
#'
#'     # Print the state.
#'     cat(
#'         "Session is starting: ", session_state$session_is_starting, "\n",
#'         "Session is idle: ", session_state$session_is_idle, "\n",
#'         "Session is busy: ", session_state$session_is_busy, "\n",
#'         "Session is finished: ", session_state$session_is_finished, "\n",
#'         sep = ""
#'     )
#' }
#'
#' # Create a specification object.
#' specification <- Specification$new()
#'
#' # Set the number of cores.
#' specification$set_cores(cores = 2)
#'
#' # Set the cluster type.
#' specification$set_type(type = "psock")
#'
#' # Create an asynchronous backend object.
#' backend <- AsyncBackend$new()
#'
#' # Start the cluster on the backend.
#' backend$start(specification)
#'
#' # Check that the session is idle.
#' check_state(backend$cluster)
#'
#' {
#'     # Run a task in parallel (i.e., approx. 0.25 seconds).
#'     backend$sapply(
#'         x = 1:10,
#'         fun = function(x) {
#'             # Sleep a bit.
#'             Sys.sleep(0.05)
#'
#'             # Compute something.
#'             output <- x + 1
#'
#'             # Return the result.
#'             return(output)
#'         }
#'     )
#'
#'     # And immediately check that the session is busy.
#'     check_state(backend$cluster)
#' }
#'
#' # Get the output and wait for the task to complete.
#' output <- backend$get_output(wait = TRUE)
#'
#' # Check that the session is idle again.
#' check_state(backend$cluster)
#'
#' # Manually close the session.
#' backend$cluster$close()
#'
#' # Check that the session is finished.
#' check_state(backend$cluster)
#'
#' # Stop the backend.
#' backend$stop()
#'
#' @seealso
#' [`parabar::TaskState`], [`parabar::AsyncBackend`] and
#' [`parabar::ProgressTrackingContext`].
#'
#' @export
SessionState <- R6::R6Class("SessionState",
    private = list(
        # Session state fields.
        .session_is_starting = NULL,
        .session_is_idle = NULL,
        .session_is_busy = NULL,
        .session_is_finished = NULL,

        # Set the session state.
        .set_state = function(session) {
            # Get the session state.
            state <- session$get_state()

            # Set the session state.
            private$.session_is_starting <- state == "starting"
            private$.session_is_idle <- state == "idle"
            private$.session_is_busy <- state == "busy"
            private$.session_is_finished <- state == "finished"
        }
    ),

    public = list(
        #' @description
        #' Create a new [`parabar::SessionState`] object and determine the state
        #' of a given background [`session`][`callr::r_session`].
        #'
        #' @param session A [`callr::r_session`] object.
        #'
        #' @return
        #' An object of class [`parabar::SessionState`].
        initialize = function(session) {
            # Set the session state.
            private$.set_state(session)
        }
    ),

    active = list(
        #' @field session_is_starting A logical value indicating whether the
        #' session is starting.
        session_is_starting = function() {
            return(private$.session_is_starting)
        },

        #' @field session_is_idle A logical value indicating whether the session
        #' is idle and ready to execute operations.
        session_is_idle = function() {
            return(private$.session_is_idle)
        },

        #' @field session_is_busy A logical value indicating whether the session
        #' is busy.
        session_is_busy = function() {
            return(private$.session_is_busy)
        },

        #' @field session_is_finished A logical value indicating whether the
        #' session is closed and no longer available for operations.
        session_is_finished = function() {
            return(private$.session_is_finished)
        }
    )
)
