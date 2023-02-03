#' @include Exception.R Backend.R Specification.R

# Blueprint for creating a backend that runs operations on a cluster synchronously.
SyncBackend <- R6::R6Class("SyncBackend",
    inherit = Backend,

    private = list(
        # Start a cluster.
        .start = function(specification) {
            # If a cluster is already active.
            if (private$.active) {
                # Throw error.
                Exception$cluster_active()
            }

            # Create cluster based on specification.
            private$.cluster <- parallel::makeCluster(specification$cores, specification$type)

            # Sanitize the cluster.
            private$.clear()

            # Toggle the active flag.
            private$.toggle_active_state()
        },

        # Stop the cluster.
        .stop = function() {
            # If there is no cluster active.
            if (!private$.active) {
                # Throw.
                Exception$cluster_not_active()
            }

            # Stop the cluster.
            parallel::stopCluster(private$.cluster)

            # Rest the cluster field.
            private$.cluster <- NULL

            # Toggle the active flag.
            private$.toggle_active_state()
        },

        # Sanitize the cluster.
        .clear = function() {
            # Evaluate the cleaning expression on the cluster.
            parallel::clusterEvalQ(private$.cluster, rm(list = ls(all.names = TRUE)))

            # Remain silent.
            invisible()
        },

        # Inspect what is on the cluster.
        .peek = function() {
            # Check what is on the cluster.
            parallel::clusterEvalQ(private$.cluster, ls(all.names = TRUE))
        },

        # Export variables on the cluster.
        .export = function(variables, environment) {
            # Export to the cluster.
            parallel::clusterExport(private$.cluster, variables, environment)

            # Remain silent.
            invisible()
        },

        # Evaluate an expression on the cluster.
        .evaluate = function(expression) {
            # Evaluate the expression.
            parallel::clusterCall(private$.cluster, eval, expression)
        },

        # A wrapper around `parallel:parSapply` to run tasks on the cluster.
        .sapply = function(x, fun, ...) {
            # Run the task and return the results.
            parallel::parSapply(private$.cluster, X = x, FUN = fun, ...)
        },

        # Clear the current output on the backend.
        .clear_output = function() {
            # Clear output.
            private$.output <- NULL
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
            # Evaluate the expression.
            private$.evaluate(substitute(expression))
        },

        # Run tasks on the backend.
        sapply = function(x, fun, ...) {
            private$.output = private$.sapply(x, fun, ...)
        },

        # Return the task results.
        get_output = function() {
            # Reset the output on exit.
            on.exit({
                # Clear.
                private$.clear_output()
            })

            return(private$.output)
        }
    )
)
