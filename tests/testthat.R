# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/tests.html
# * https://testthat.r-lib.org/reference/test_package.html#special-files

# Set environmental variable to prevent hang on quitting the `R` session.
# Error message:
# - `Error while shutting down parallel: unable to terminate some child processes`
# See:
# - https://github.com/r-lib/processx/issues/310
# - https://github.com/r-lib/processx/issues/240
# - https://github.com/r-lib/callr/issues/158
Sys.setenv(PROCESSX_NOTIFY_OLD_SIGCHLD = "true")

library(testthat)
library(parabar)

test_check("parabar")
