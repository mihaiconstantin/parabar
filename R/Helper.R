#' @include Options.R

#' @title
#' Package Helpers
#'
#' @description
#' This class contains static helper methods.
#'
#' @format
#' \describe{
#'   \item{\code{Helper$get_class_name()}}{Helper for getting the class of a given object.}
#'   \item{\code{Helper$is_of_class()}}{Check if an object is of a certain class.}
#'   \item{\code{Helper$get_option()}}{Get package option, or corresponding default value.}
#'   \item{\code{Helper$set_option()}}{Set package option.}
#'   \item{\code{Helper$check_object_type()}}{Check the type of a given object.}
#' }
#'
#' @export
Helper <- R6::R6Class("Helper",
    cloneable = FALSE
)

# Helper for getting the class of a given instance.
Helper$get_class_name <- function(object) {
    return(class(object)[1])
}

# Helper to check if object is of certain class.
Helper$is_of_class <- function(object, class) {
    return(class(object)[1] == class)
}

# Get package option, or corresponding default value.
Helper$get_option <- function(option) {
    # Get the `Options` instance from the global options, or create a new one.
    options <- getOption("parabar", default = Options$new())

    # If the requested option is unknown.
    if (!option %in% ls(options)) {
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
    if (!option %in% ls(options)) {
        # Throw an error.
        Exception$unknown_package_option(option)
    }

    # Set the value.
    options[[option]] <- value

    # Set the `Options` instance in the global options.
    options(parabar = options)
}

# Helper for performing a type check on a given object.
Helper$check_object_type <- function(object, expected_type) {
    # Get object class name.
    type <- Helper$get_class_name(object)

    # If the object does not inherit from the expected type.
    if (!inherits(object, expected_type)) {
        # Throw incorrect type error.
        Exception$type_not_assignable(type, expected_type)
    }
}
