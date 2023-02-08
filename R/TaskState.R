# Hold the state of task ran asynchronously through background session call.
TaskState <- R6::R6Class("TaskState",
    private = list(
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
            private$.task_not_started = (session_state == "idle" && execution_state == "timeout")

            # The session is busy and a task is running.
            private$.task_is_running = (session_state == "busy" && execution_state == "timeout")

            # The session is busy and a task has completed (i.e., results need to be read).
            private$.task_is_completed = (session_state == "busy" && execution_state == "ready")
        }
    ),

    public = list(
        # Constructor.
        initialize = function(session) {
            # Set the task state.
            private$.set_state(session)
        }
    ),

    active = list(
        task_not_started = function() { return(private$.task_not_started) },
        task_is_running = function() { return(private$.task_is_running) },
        task_is_completed = function() { return(private$.task_is_completed) }
    )
)
