# Blue print for class storing various static helper methods.
Helper <- R6::R6Class("Helper")

# Add helper for getting the class of a given instance.
Helper$get_class_name <- function(object) {
    return(class(object)[1])
}

# Get package option, or corresponding default value.
Helper$get_option <- function(option) {
    # Get the `Options` instance from the global options, or create a new one.
    options <- getOption("parabar", default = Options$new())

    # If the requested option is unknown.
    if (!(option %in% ls(options))) {
        # Throw an error.
        Exception$unknown_package_option(option)
    }

    # Return the value.
    return(options[[option]])
}

# Set package option.
Helper$set_option <- function(option, value) {
    # Get the `Options` instance from the global options, or create a new one.
    options <- getOption("parabar", default = Options$new())

    # If the requested option is unknown.
    if (!(option %in% ls(options))) {
        # Throw an error.
        Exception$unknown_package_option(option)
    }

    # Set the value.
    options[[option]] <- value

    # Set the `Options` instance in the global options.
    options(parabar = options)
}
