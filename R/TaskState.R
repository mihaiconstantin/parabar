#' @title
#' TaskState
#'
#' @description
#' This class holds the state of a task deployed to an asynchronous backend
#' (i.e., [`parabar::AsyncBackend`]). See the **Details** section for more
#' information.
#'
#' @details
#' The task state is useful to check if an asynchronous backend is free to
#' execute other operations. A task can only be in one of the following three
#' states at a time:
#' - `task_not_started`: When `TRUE`, it indicates whether the backend is free
#'   to execute another operation.
#' - `task_is_running`: When `TRUE`, it indicates that there is a task running
#'  on the backend.
#' - `task_is_completed`: When `TRUE`, it indicates that the task has been
#'  completed, but the backend is still busy because the task output has not
#'  been retrieved.
#'
#' The task state is determined based on the state of the background
#' [`session`][`callr::r_session`] (i.e., see the `get_state` method for
#' [`callr::r_session`]) and the state of the task execution inferred from
#' polling the process (i.e., see the `poll_process` method for
#' [`callr::r_session`]) as follows:
#'
#' | Session State | Execution State | Not Started | Is Running | Is Completed |
#' | :-----------: | :-------------: | :---------: | :--------: | :----------: |
#' |    `idle`     |    `timeout`    |   `TRUE`    |  `FALSE`   |   `FALSE`    |
#' |    `busy`     |    `timeout`    |   `FALSE`   |   `TRUE`   |   `FALSE`    |
#' |    `busy`     |     `ready`     |   `FALSE`   |  `FALSE`   |    `TRUE`    |
#'
#' @examples
#' # Handy function to print the task states all at once.
#' check_state <- function(session) {
#'     # Create a task state object and determine the state.
#'     task_state <- TaskState$new(session)
#'
#'     # Print the state.
#'     cat(
#'         "Task not started: ", task_state$task_not_started, "\n",
#'         "Task is running: ", task_state$task_is_running, "\n",
#'         "Task is completed: ", task_state$task_is_completed, "\n",
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
#' # Check that the task has not been started (i.e., the backend is free).
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
#'     # And immediately check the state to see that the task is running.
#'     check_state(backend$cluster)
#' }
#'
#' # Sleep for a bit to wait for the task to complete.
#' Sys.sleep(1)
#'
#' # Check that the task is completed (i.e., the output needs to be retrieved).
#' check_state(backend$cluster)
#'
#' # Get the output.
#' output <- backend$get_output(wait = TRUE)
#'
#' # Check that the task has not been started (i.e., the backend is free again).
#' check_state(backend$cluster)
#'
#' # Stop the backend.
#' backend$stop()
#'
#' @seealso
#' [`parabar::SessionState`], [`parabar::AsyncBackend`] and
#' [`parabar::ProgressTrackingContext`].
#'
#' @export
TaskState <- R6::R6Class("TaskState",
    private = list(
        # Task state fields.
        .task_not_started = NULL,
        .task_is_running = NULL,
        .task_is_completed = NULL,

        # Set the task state.
        .set_state = function(cluster) {
            # Session state.
            session_state <- cluster$get_state()

            # Task execution state.
            execution_state <- cluster$poll_process(0)

            # Compute all states.
            # The session is free and no task is running.
            private$.task_not_started <- (session_state == "idle" && execution_state == "timeout")

            # The session is busy and a task is running.
            private$.task_is_running <- (session_state == "busy" && execution_state == "timeout")

            # The session is busy and a task has completed (i.e., results need to be read).
            private$.task_is_completed <- (session_state == "busy" && execution_state == "ready")
        }
    ),

    public = list(
        #' @description
        #' Create a new [`parabar::TaskState`] object and determine the state of
        #' a task on a given background [`session`][`callr::r_session`].
        #'
        #' @param session A [`callr::r_session`] object.
        #'
        #' @return
        #' An object of class [`parabar::TaskState`].
        initialize = function(session) {
            # Set the task state.
            private$.set_state(session)
        }
    ),

    active = list(
        #' @field task_not_started A logical value indicating whether the task
        #' has been started. It is used to determine if the backend is free to
        #' execute another operation.
        task_not_started = function() {
            return(private$.task_not_started)
        },

        #' @field task_is_running A logical value indicating whether the task is
        #' running.
        task_is_running = function() {
            return(private$.task_is_running)
        },

        #' @field task_is_completed A logical value indicating whether the task
        #' has been completed and the output needs to be retrieved.
        task_is_completed = function() {
            return(private$.task_is_completed)
        }
    )
)
