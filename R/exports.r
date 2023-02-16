#' @include Options.R Helper.R Specification.R BackendFactory.R ContextFactory.R Exception.R BarFactory.R

#' @template set-default-options
#' @export
set_default_options <- function() {
    # Set `Options` instance.
    options(parabar = Options$new())

    # Remain silent.
    invisible(NULL)
}


#' @template get-option
#' @export
get_option <- function(option) {
    # Invoke the helper.
    Helper$get_option(option)
}


#' @template set-option
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
    # Stop the backend
    backend$stop()

    # Remain silent.
    invisible()
}
