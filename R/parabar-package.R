# # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                              _                      #
#                             | |                     #
#   _ __    __ _  _ __   __ _ | |__    __ _  _ __     #
#  | '_ \  / _` || '__| / _` || '_ \  / _` || '__|    #
#  | |_) || (_| || |   | (_| || |_) || (_| || |       #
#  | .__/  \____||_|    \____||____/  \____||_|       #
#  | |                                                #
#  |_|                                                #
#                                                     #
# # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Author: Mihai A. Constantin                         #
# Documentation: https://parabar.mihaiconstantin.com  #
# Contact: mihai@mihaiconstantin.com                  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # #


# On package load.
.onLoad <- function(libname, pkgname) {
    # Set package options.
    set_default_options()
}


# On package attach.
.onAttach <- function(libname, pkgname) {
    # If there this is an interactive session.
    if (interactive()) {
        # Print package information.
        packageStartupMessage(LOGO)
    }
}


# On package unload.
.onUnload <- function(libpath) {
    # Remove package options.
    options(parabar = NULL)
}
