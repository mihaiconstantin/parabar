#' @include Context.R Bar.R

#' @title
#' ProgressTrackingContext
#'
#' @description
#' This class represents a progress tracking context for interacting with
#' [`parabar::Backend`] implementations via the [`parabar::Service`] interface.
#'
#' @details
#' This class extends the base [`parabar::Context`] class and overrides the
#' [`sapply`][`parabar::Context`] parent method to decorate the backend instance
#' with additional functionality. Specifically, this class creates a temporary
#' file to log the progress of backend tasks, and then creates a progress bar to
#' display the progress of the backend tasks.
#'
#' The progress bar is updated after each backend task execution. The timeout
#' between subsequent checks of the temporary log file is controlled by the
#' [`parabar::Options`] class and defaults to `0.001`. This value can be
#' adjusted via the [`parabar::Options`] instance present in the session
#' [`base::.Options`] list (i.e., see [parabar::set_option()]). For example, to
#' set the timeout to `0.1` we can run `set_option("progress_timeout", 0.1)`.
#'
#' This class is a good example of how to extend the base [`parabar::Context`]
#' class to decorate the backend instance with additional functionality.
#'
#' @examples
#' # Define a task to run in parallel.
#' task <- function(x, y) {
#'     # Sleep a bit.
#'     Sys.sleep(0.15)
#'
#'     # Return the result of a computation.
#'     return(x + y)
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
#' # Create a backend factory.
#' backend_factory <- BackendFactory$new()
#'
#' # Get a backend instance that does not support progress tracking.
#' backend <- backend_factory$get("sync")
#'
#' # Create a progress tracking context object.
#' context <- ProgressTrackingContext$new()
#'
#' # Attempt to set the incompatible backend instance.
#' try(context$set_backend(backend))
#'
#' # Get a backend instance that does support progress tracking.
#' backend <- backend_factory$get("async")
#'
#' # Register the backend with the context.
#' context$set_backend(backend)
#'
#' # From now all, all backend operations are intercepted by the context.
#'
#' # Start the backend.
#' context$start(specification)
#'
#' # Create a bar factory.
#' bar_factory <- BarFactory$new()
#'
#' # Get a modern bar instance.
#' bar <- bar_factory$get("modern")
#'
#' # Register the bar with the context.
#' context$set_bar(bar)
#'
#' # Configure the bar.
#' context$configure_bar(
#'     show_after = 0,
#'     format = " > completed :current out of :total tasks [:percent] [:elapsed]"
#' )
#'
#' # Run a task in parallel (i.e., approx. 1.9 seconds).
#' context$sapply(x = 1:25, fun = task, y = 10)
#'
#' # Get the task output.
#' backend$get_output(wait = TRUE)
#'
#' # Change the bar type.
#' bar <- bar_factory$get("basic")
#'
#' # Register the bar with the context.
#' context$set_bar(bar)
#'
#' # Remove the previous bar configuration.
#' context$configure_bar()
#'
#' # Run a task in parallel (i.e., approx. 1.9 seconds).
#' context$sapply(x = 1:25, fun = task, y = 10)
#'
#' # Get the task output.
#' backend$get_output(wait = TRUE)
#'
#' # Close the backend.
#' context$stop()
#'
#' @seealso
#' [`parabar::Context`], [`parabar::Service`], [`parabar::Backend`], and
#' [`parabar::AsyncBackend`].
#'
#' @export
ProgressTrackingContext <- R6::R6Class("ProgressTrackingContext",
    inherit = Context,

    private = list(
        # The progress bar.
        .bar = NULL,

        # Progress bar configuration.
        .bar_config = list(),

        # Create a temporary file to log progress from backend tasks.
        .make_log = function() {
            # Get a temporary file name (i.e., OS specific) or a fixed one.
            file_path <- Helper$get_option("progress_log_path")

            # Create the temporary file.
            creation_status <- file.create(file_path)

            # If the file creation failed.
            if (!creation_status) {
                # Throw.
                Exception$temporary_file_creation_failed(file_path)
            }

            # Return path of created file.
            return(file_path)
        },

        # Decorate task function to log the progress after each execution.
        .decorate = function(task, log) {
            # Determine file log lock path.
            log_lock_path <- paste0(log, ".lock")

            # Get the body of the function to patch.
            fun_body <- body(task)

            # Get the length of the body.
            length_fun_body <- length(fun_body)

            # Insert the expression.
            fun_body[[length_fun_body + 1]] <- bquote(
                # The injected expression.
                on.exit({
                    # Acquire an exclusive lock.
                    log_lock <- filelock::lock(.(log_lock_path))

                    # Write the line.
                    cat("\n", file = .(log), sep = "", append = TRUE)

                    # Release the lock.
                    filelock::unlock(log_lock)
                })
            )

            # Reorder the body.
            fun_body <- fun_body[c(1, (length_fun_body + 1), 2:length_fun_body)]

            # Attach the function body and return it.
            body(task) <- fun_body

            return(task)
        },

        # Show the progress bar based on the backend task execution.
        .show_progress = function(total, log) {
            # Get the checking delay from options.
            timeout <- Helper$get_option("progress_timeout")

            # Initialize the bar at the initial starting point.
            do.call(
                private$.bar$create,
                utils::modifyList(
                    list(total = total, initial = 0), private$.bar_config
                )
            )

            # Kick-start the bar.
            private$.bar$update(0)

            # Counter for the number of tasks processed.
            tasks_processed <- 0

            # While there are still tasks1 to be processed.
            while (tasks_processed < total) {
                # Get the current number of tasks processed.
                current_tasks_processed <- length(readLines(log, warn = FALSE))

                # Redraw the bar only if the number of tasks processed has increased.
                if (current_tasks_processed > tasks_processed) {
                    # Update the number of tasks processed.
                    tasks_processed <- current_tasks_processed

                    # Update the progress bar to completed state.
                    private$.bar$update(tasks_processed)
                }

                # Wait a bit.
                Sys.sleep(timeout)
            }

            # Close and remove the progress bar.
            private$.bar$terminate()
        }
    ),

    public = list(
        #' @description
        #' Set the backend instance to be used by the context.
        #'
        #' @param backend An object of class [`parabar::Backend`] that supports
        #' progress tracking implements the [`parabar::Service`] interface.
        #'
        #' @details
        #' This method overrides the parent method to validate the backend
        #' provided and guarantee it is an instance of the
        #' [`parabar::AsyncBackend`] class.
        set_backend = function(backend) {
            # Get backend type.
            type <- Helper$get_class_name(backend)

            # If an incompatible backend is provided.
            if (type != "AsyncBackend") {
                # Throw incorrect type error.
                Exception$type_not_assignable(type, "AsyncBackend")
            }

            # Set the backend.
            super$set_backend(backend)
        },

        #' @description
        #' Set the [`parabar::Bar`] instance to be used by the context.
        #'
        #' @param bar An object of class [`parabar::Bar`].
        set_bar = function(bar) {
            # Set the bar.
            private$.bar = bar
        },

        # Set bar configuration.
        #' @description
        #' Configure the [`parabar::Bar`] instance registered with the context.
        #'
        #' @param ... A list of named arguments passed to the `create()` method
        #' of the [`parabar::Bar`] instance. See the documentation of the
        #' specific concrete bar for details (e.g., [`parabar::ModernBar`]).
        configure_bar = function(...) {
            # Store bar options.
            private$.bar_config = list(...)
        },

        #' @description
        #' Run a task on the backend akin to [parallel::parSapply()], but with a
        #' progress bar.
        #'
        #' @param x A vector (i.e., usually of integers) to pass to the `fun`
        #' function.
        #'
        #' @param fun A function to apply to each element of `x`.
        #'
        #' @param ... Additional arguments to pass to the `fun` function.
        #'
        #' @return
        #' This method returns void. The output of the task execution must be
        #' stored in the private field `.output` on the [`parabar::Backend`]
        #' abstract class, and is accessible via the `get_output()` method.
        sapply = function(x, fun, ...) {
            # Create file for logging progress.
            log <- private$.make_log()

            # Clear the temporary file on function exit.
            on.exit({
                # Remove.
                unlink(log)
            })

            # Decorate task function.
            task <- private$.decorate(task = fun, log = log)

            # Execute the decorated task.
            super$sapply(x = x, fun = task, ...)

            # Show the progress bar and block the main process.
            private$.show_progress(total = length(x), log = log)
        }
    ),

    active = list(
        #' @field bar The [`parabar::Bar`] instance registered with the context.
        bar = function() { return(private$.bar) }
    )
)
