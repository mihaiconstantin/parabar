#' @include Exception.R Backend.R Specification.R TaskState.R

# Backend for running `parallel::parSapply` asynchronously.
AsyncBackend <- R6::R6Class("AsyncBackend",
    inherit = Backend,

    private = list(
        # The progress tracking capabilities of the backend implementation.
        .supports_progress = TRUE,

        # Create a parallel cluster in the `R` session.
        .make_cluster = function(specification) {
           # Create cluster in the `.GlobalEnv` in the separate session.
            private$.cluster$run(function(cores, type) {
                # Make the actual cluster.
                cluster <<- parallel::makeCluster(spec = cores, type = type)
            }, args = list(
                specification$cores, specification$type
            ))
        },

        # Start a cluster in a separate `R` session.
        .start = function(specification) {
            # If a cluster is already active.
            if (private$.active) {
                # Throw error.
                Exception$cluster_active()
            }

            # Create a permanent separate `R` session.
            private$.cluster <- callr::r_session$new()

            # Create cluster in session based on specification.
            private$.make_cluster(specification)

            # Sanitize the cluster.
            private$.clear()

            # Toggle the active flag.
            private$.toggle_active_state()
        },

        # Stop the cluster in the session.
        .stop = function() {
            # If there is no cluster active.
            if (!private$.active) {
                # Throw.
                Exception$cluster_not_active()
            }

            # Stop the cluster existing in the separate `R` session.
            private$.cluster$run(function() {
                # Stop the cluster.
                parallel::stopCluster(cluster)
            })

            # Terminate the separate `R` session.
            private$.cluster$close()

            # Rest the cluster field.
            private$.cluster <- NULL

            # Toggle the active flag.
            private$.toggle_active_state()
        },

        # Sanitize the cluster in the session.
        .clear = function() {
            # Run the clear command in the session.
            private$.cluster$run(function() {
                # Evaluate the expression on the cluster.
                parallel::clusterEvalQ(cluster, rm(list = ls(all.names = TRUE)))
            })

            # Remain silent.
            invisible()
        },

        # Inspect what is on the cluster, not the session.
        .peek = function() {
            # Run the command on the cluster in the session.
            private$.cluster$run(function() {
                # Check what is on the cluster.
                parallel::clusterEvalQ(cluster, ls(all.names = TRUE))
            })
        },

        # Export variables on the cluster in the session.
        .export = function(variables, environment) {
            # Create new environment only with the variables that are being exported.
            new_environment <- new.env()

            # Assign the variables to be exported in the new environment.
            for (variable in variables) {
               # Assign the variables.
               assign(variable, get(variable, environment), new_environment)
            }

            # Export to the cluster via the session.
            private$.cluster$run(function(variables, environment) {
                # The actual export command.
                parallel::clusterExport(cluster, variables, environment)
            }, args = list(variables, new_environment))

            # Remain silent.
            invisible()
        },

        # Evaluate an expression on the cluster in the session.
        .evaluate = function(expression) {
           # Perform the evaluation on the cluster via the `R` session.
            private$.cluster$run(function(expression) {
                # Evaluate the expression.
                parallel::clusterCall(cluster, eval, expression)
            }, args = list(expression))
        },

        # Run tasks on the cluster in the session asynchronously.
        .sapply = function(x, fun, ...) {
            # Capture the `...`.
            dots <- list(...)

            # Perform the evaluation from the `R` session.
            private$.cluster$call(function(x, fun, dots) {
                # Run the task.
                output <- do.call(parallel::parSapply, c(list(cluster, x, fun), dots))

                # Return to the session.
                return(output)
            }, args = list(x, fun, dots))
        },

        # Clear the current output on the backend.
        .clear_output = function() {
            # Clear output.
            private$.output <- NULL
        },

        # Set the output based on the session read.
        .set_output = function() {
            # Store the relevant results from the output.
            private$.output <- private$.cluster$read()$result
        },

        # Get the current task state (i.e., what is happening in the session).
        .get_task_state = function() {
            # If the backend does not have an active cluster (i.e., session in this case).
            if (!private$.active) {
                # Throw.
                Exception$cluster_not_active()
            }

            # Create task state object holding the current state.
            task_state <- TaskState$new(private$.cluster)

            return(task_state)
        },

        # Throw an exception if the backend is not ready to be used.
        .throw_if_backend_is_busy = function() {
            # Get task state.
            task_state <- private$.get_task_state()

            # If a task is running.
            if (task_state$task_is_running) {
                # Throw error.
                Exception$async_task_running()
            }

            # If a task is completed with unread results.
            if (task_state$task_is_completed) {
                # Throw error.
                Exception$async_task_completed()
            }
        },

        # Wait for the task to finish and fetch the results.
        .wait_to_fetch_results = function() {
            # Get task state.
            task_state <- private$.get_task_state()

            # If no task has started (i.e., not deployed) on the backend.
            if (task_state$task_not_started) {
                # Throw error.
                Exception$async_task_not_started()
            }

            # If a task is currently running, wait for its completion.
            if (task_state$task_is_running) {
                # Wait for task to finish.
                private$.cluster$poll_process(-1)

                # Read the session and set the output.
                private$.set_output()

            # Otherwise, a completed task awaits results to be read.
            } else {
                # Fetch and set the results right away.
                private$.set_output()
            }
        },

        # Attempt to fetch the results if the task finished.
        .fetch_results = function() {
            # Get task state.
            task_state <- private$.get_task_state()

            # If no task has started (i.e., not deployed) on the backend.
            if (task_state$task_not_started) {
                # Throw error.
                Exception$async_task_not_started()
            }

            # If a task is still running on the backend.
            if (task_state$task_is_running) {
                # Throw error.
                Exception$async_task_running()
            }

            # Otherwise, read the results of a completed task.
            private$.set_output()
        }
    ),

    public = list(
       # Enable object constructor (i.e., `R` caveat).
        initialize = function() { invisible() },

        # Destructor.
        finalize = function() {
            # If a cluster is active, stop before deleting the instance.
            if (private$.active) {
                # Stop the cluster.
                private$.stop()
            }
        },

        # Create a cluster.
        start = function(specification) {
            private$.start(specification)
        },

        # Stop the currently active cluster.
        stop = function() {
            private$.stop()
        },

        # Clean the cluster.
        clear = function() {
            private$.clear()
        },

        # Inspect the cluster.
        peek = function() {
            private$.peek()
        },

        # Export variables on the cluster.
        export = function(variables, environment) {
            # If no environment is provided.
            if (missing(environment)) {
                # Use the caller's environment where the variables are defined.
                environment <- parent.frame()
            }

            # Export and return the output.
            private$.export(variables, environment)
        },

        # Evaluate an expression on the cluster.
        evaluate = function(expression) {
            private$.evaluate(substitute(expression))
        },

        # Run tasks on the backend.
        sapply = function(x, fun, ...) {
            # Throw if backend is busy.
            private$.throw_if_backend_is_busy()

            # Deploy the task asynchronously.
            private$.sapply(x, fun, ...)
        },

        # Return the task results.
        get_output = function(wait = FALSE) {
            # Reset the output on exit.
            on.exit({
                # Clear.
                private$.clear_output()
            })

            # If the user wants to wait for the results.
            if (wait) {
                # Wait to fetch the results.
                private$.wait_to_fetch_results()
            } else {
                # Otherwise, try to fetch the results now (i.e., without waiting).
                private$.fetch_results()
            }

            # Return the simplified output.
            return(private$.output)
        }
    ),

    active = list(
        # Check the task state.
        task_state = function() {
            # Get a task state instance with the state.
            task_state <- private$.get_task_state()

            # Return a simplified state.
            return(list(
                task_not_started = task_state$task_not_started,
                task_is_running = task_state$task_is_running,
                task_is_completed = task_state$task_is_completed
            ))
        }
    )
)
