#' @title
#' Progress Bar for Parallel Tasks
#'
#' @details
#' The package is aimed at two audiences: (1) end-users who want to execute a
#' task in parallel in an interactive `R` session and track the execution
#' progress, and (2) `R` package developers who want to use [`parabar::parabar`]
#' as a solution for parallel processing in their packages.
#'
#' @section Users:
#' For the first category of users, [`parabar::parabar`] provides several main
#' functions of interest:
#' - [parabar::start_backend()]: creates a parallel backend for executing tasks
#'   according to the specifications provided.
#' - [parabar::stop_backend()]: stops an active backend and makes the [`R6::R6`]
#'   eligible for garbage collection.
#' - [parabar::par_sapply()]: is a drop-in replacement for the built-in
#'   [`base::sapply()`] function when no backend is provided. However, when a
#'   backend is provided, the function will execute a task in parallel on the
#'   backend, similar to the built-in function [`parallel::parSapply()`].
#' - [parabar::par_lapply()]: is a drop-in replacement for the built-in
#'   [`base::lapply()`] function when no backend is provided. However, when a
#'   backend is provided, the function will execute a task in parallel on the
#'   backend, similar to the built-in function [`parallel::parLapply()`].
#' - [parabar::par_apply()]: is a drop-in replacement for the built-in
#'   [`base::apply()`] function when no backend is provided. However, when a
#'   backend is provided, the function will execute a task in parallel on the
#'   backend, similar to the built-in function [`parallel::parApply()`].
#' - [parabar::clear()]: removes all variables available on a backend.
#' - [parabar::peek()]: returns the names of all variables available on a
#'   backend.
#' - [parabar::export()]: exports objects from a specified environment to a
#'   backend.
#' - [parabar::evaluate()]: evaluates arbitrary and unquoted expression on a
#'   backend.
#'
#'  [`parabar::parabar`] also provides a function [parabar::configure_bar()] for
#'  configuring the progress bar, and three functions can be used to get and set
#'  the package options:
#' - [parabar::get_option()]: gets the value of a package option.
#' - [parabar::set_option()]: sets the value of a package option.
#' - [parabar::set_default_options()]: sets default values for all package
#'   options. This function is automatically called on package load.
#'
#' @section Developers:
#' For the second category of users, [`parabar::parabar`] provides a set of
#' classes (i.e., [R6::R6Class()]) that can be used to create backends (i.e.,
#' synchronous and asynchronous) and interact with them via a simple interface.
#' From a high-level perspective, the package consists of **`backends`** and
#' **`contexts`** in which these backends are employed for executing the tasks
#' in parallel.
#'
#' ### Backends
#' A **`backend`** represents a set of operations, defined by the
#' [`parabar::BackendService`] interface, that can be deployed on a cluster
#' returned by [parallel::makeCluster()]. Backends can be synchronous (i.e.,
#' [`parabar::SyncBackend`]) or asynchronous (i.e., [`parabar::AsyncBackend`]).
#' The former will block the execution of the current `R` session until the
#' parallel task is completed, while the latter will return immediately and the
#' task will be executed in a background `R` session.
#'
#' The [`parabar::BackendService`] interface defines the following operations:
#' [`start()`][parabar::BackendService], [`stop()`][parabar::BackendService],
#' [`clear()`][parabar::BackendService], [`peek()`][parabar::BackendService],
#' [`export()`][parabar::BackendService],
#' [`evaluate()`][parabar::BackendService],
#' [`sapply()`][parabar::BackendService], [`lapply()`][parabar::BackendService],
#' [`apply()`][parabar::BackendService], and
#' [`get_output()`][parabar::BackendService].
#'
#' Check out the documentation for [`parabar::BackendService`] for more
#' information on each method.
#'
#' ### Contexts
#' A **`context`** represents the specific conditions in which the backend
#' operates. The default, regular [`parabar::Context`] class simply forwards the
#' call to the corresponding backend method. However, a more complex context can
#' augment the operation before forwarding the call to the backend. One example
#' of a complex context is the [`parabar::ProgressTrackingContext`] class. This
#' class extends the regular [`parabar::Context`] class and decorates, for
#' example, the backend [`sapply()`][parabar::BackendService] operation to log
#' the progress after each task execution and display a progress bar.
#'
#' The following are the main classes provided by `parabar`:
#' - [`parabar::BackendService`]: interface for backend operations.
#' - [`parabar::Backend`]: abstract class that serves as a base class for all
#'   concrete implementations.
#' - [`parabar::SyncBackend`]: synchronous backend extending the abstract
#'   [`parabar::Backend`] class.
#' - [`parabar::AsyncBackend`]: asynchronous backend extending the abstract
#'   [`parabar::Backend`] class.
#' - [`parabar::Specification`]: backend specification used when starting a
#'   backend.
#' - [`parabar::TaskState`]: determine the state of a task deployed to an
#'   asynchronous backend.
#' - [`parabar::BackendFactory`]: factory for creating backend objects.
#' - [`parabar::Context`]: default context for executing backend operations.
#' - [`parabar::ProgressTrackingContext`]: context for decorating the
#'   [`sapply()`][parabar::BackendService],
#'   [`lapply()`][parabar::BackendService], and
#'   [`apply()`][parabar::BackendService] operations to track and display the
#'   execution progress.
#' - [`parabar::ContextFactory`]: factory for creating context objects.
#' - [`parabar::UserApiConsumer`]: opinionated wrapper around the other
#'   [`R6::R6`] classes used in by the exported functions for the users.
#'
#' @section Progress Bars:
#' [`parabar::parabar`] also exposes several classes for creating and updating
#' different progress bars, namely:
#' - [`parabar::Bar`]: abstract class defining the pure virtual methods to be
#'   implemented by concrete bar classes.
#' - [`parabar::BasicBar`]: a simple, but robust, bar created via
#'   [utils::txtProgressBar()] extending the [`parabar::Bar`] abstract class.
#' - [`parabar::ModernBar`]: a modern bar created via [`progress::progress_bar`]
#'   extending the [`parabar::Bar`] abstract class.
#' - [`parabar::BarFactory`]: factory for creating bar objects.
#'
#' Finally, [`parabar::parabar`] uses several [base::options()] to configure the
#' behavior of the functionality it provides. For more information on the
#' options used and their see default values, see the [`parabar::Options`]
#' class.
#'
#' For more information about the design of [`parabar::parabar`], check out the
#' documentation and the `UML` diagram at
#' [parabar.mihaiconstantin.com](https://parabar.mihaiconstantin.com).
#'
#' \if{html}{
#' \out{<div style="display: block; text-align: center">}
#'
#' \out{<div style="display: block; margin-top: 1rem; margin-bottom: 0.5rem">}
#'
#' \strong{Software Design}
#'
#' \out{</div>}
#'
#' \figure{parabar-design.png}{options: style="max-width: 95\%;" alt="parabar Software Design"}
#'
#' \out{</div>}
#' }
#'
#' @keywords internal
