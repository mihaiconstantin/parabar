.onLoad <- function(libname, pkgname) {
    # Set package options.
    set_default_options()
}


# On package unload.
.onUnload <- function(libpath) {
    # Remove package options.
    options(parabar = NULL)
}
