# Blue print for class storing various static helper methods.
Helper <- R6::R6Class("Helper")

# Add helper for getting the class of a given instance.
Helper$get_class_name <- function(object) {
    return(class(object)[1])
}
