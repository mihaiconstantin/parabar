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
