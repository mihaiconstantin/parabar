#' @include Options.R Helper.R Specification.R BackendFactory.R ContextFactory.R Exception.R BarFactory.R

#' @template set-default-options
#' @order 3
#' @export
set_default_options <- function() {
    # Set `Options` instance.
    options(parabar = Options$new())

    # Remain silent.
    invisible(NULL)
}


#' @template get-option
#' @order 1
#' @export
get_option <- function(option) {
    # Invoke the helper.
    Helper$get_option(option)
}


#' @template set-option
#' @order 2
#' @export
set_option <- function(option, value) {
    # Invoke the helper.
    Helper$set_option(option, value)

    # Remain silent.
    invisible()
}


#' @template configure-bar
#' @export
configure_bar <- function(type = "modern", ...) {
    # If the type is not known.
    if (!type %in% c("modern", "basic")) {
        # Throw an error.
        Exception$feature_not_developed()
    }

    # Update the bar type in options.
    set_option("progress_bar_type", type)

    # Capture the bar configuration requested by the user.
    user_bar_config <- list(...)

    # If the configuration is not empty.
    if (length(user_bar_config)) {
        # Get the default config options.
        bar_config <- get_option("progress_bar_config")

        # Combine the configurations.
        bar_config[[type]] <- utils::modifyList(bar_config[[type]], user_bar_config)

        # Set the bar config in options.
        set_option("progress_bar_config", bar_config)
    }

    # Remain silent.
    invisible()
}


#' @template start-backend
#' @export
start_backend <- function(cores, cluster_type = "psock", backend_type = "async") {
    # Create specification object.
    specification <- Specification$new()

    # Set specification cores.
    specification$set_cores(cores)

    # Set the specification cluster type.
    specification$set_type(cluster_type)

    # Initialize a backend factory.
    backend_factory <- BackendFactory$new()

    # Get a backend instance of the desired type.
    backend <- backend_factory$get(backend_type)

    # Start the backend.
    backend$start(specification)

    # Return the backend.
    return(backend)
}


#' @template stop-backend
#' @export
stop_backend <- function(backend) {
    # Check the type.
    Helper$check_object_type(backend, "Backend")

    # Stop the backend
    backend$stop()

    # Remain silent.
    invisible()
}


#' @template clear
#' @export
clear <- function(backend) {
    # Check the type.
    Helper$check_object_type(backend, "Backend")

    # Peek the backend.
    backend$clear()
}


#' @template peek
#' @export
peek <- function(backend) {
    # Check the type.
    Helper$check_object_type(backend, "Backend")

    # Peek the backend..
    backend$peek()
}


#' @template export
#' @export
export <- function(backend, variables, environment) {
    # Check the type.
    Helper$check_object_type(backend, "Backend")

    # Export variables.
    backend$export(variables, environment)
}


#' @template evaluate
#' @export
evaluate <- function(backend, expression) {
    # Check the type.
    Helper$check_object_type(backend, "Backend")

    # Capture the expression.
    capture <- substitute(expression)

    # Prepare the call.
    capture_call <- bquote(backend$evaluate(.(capture)))

    # Perform the call.
    eval(capture_call)
}


#' @template par-sapply
#' @export
par_sapply <- function(backend = NULL, x, fun, ...) {
    # If no backend is provided.
    if (is.null(backend)) {
        # Then use the built in, non-parallel `base::sapply`.
        output <- base::sapply(X = x, FUN = fun, ...)

        # Return results.
        return(output)

    # Otherwise, if a backend is provided.
    } else {
        # Check the type.
        Helper$check_object_type(backend, "Backend")
    }

    # Get user warning settings.
    user_options <- options()

    # Enable printing warnings as soon as they occur.
    options(warn = 1)

    # Restore user's original settings.
    on.exit({
        # Reset user's options.
        options(user_options)
    })

    # Whether to track progress or not.
    progress <- get_option("progress_track")

    # If the user requested progress tracking and the backend does not support it.
    if (progress && !backend$supports_progress) {
        # Warn the users.
        Warning$progress_not_supported_for_backend(backend)
    }

    # Create a context manager factory.
    context_factory <- ContextFactory$new()

    # If progress is requested and the conditions are right.
    if (progress && backend$supports_progress && interactive()) {
        # Then use a progress-decorated context.
        context <- context_factory$get("progress")

        # Progress bar type.
        bar_type <- get_option("progress_bar_type")

        # Progress bar default configuration.
        bar_config <- get_option("progress_bar_config")[[bar_type]]

        # Create a bar factory.
        bar_factory <- BarFactory$new()

        # Get a bar of desired type.
        bar <- bar_factory$get(bar_type)

        # Set the bar.
        context$set_bar(bar)

        # Configure the bar.
        do.call(context$configure_bar, bar_config)

    # Otherwise, if progress tracking is not requested, nor possible.
    } else {
        # Use a regular context.
        context <- context_factory$get("regular")
    }

    # Register the backend with the context.
    context$set_backend(backend)

    # Execute the task using the backend provided (i.e., aka context).
    context$sapply(x = x, fun = fun, ...)

    # If the current context wraps a backend that supports progress tracking.
    if (context$backend$supports_progress) {
        # Then wait for the results.
        output <- context$get_output(wait = TRUE)
    } else {
        # Otherwise, return the output whenever the task is finished.
        output <- context$get_output()
    }

    return(output)
}
