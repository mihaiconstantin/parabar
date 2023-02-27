# Development

## Added
- Add several exported wrappers to the user API:
  - `clear`: to clean a provided backend instance.
  - `export`: to export variables from a give environment to the `.GlobalEnv` of
    the backend instance.
  - `peek`: to list the variables names available on the backend instance.
  - `evaluate`: to evaluate arbitrary expressions on the backend instance.
- Add type checks for the exported functions (i.e., the user API).
- Add helper method for checking and validating the type of an object. The
  `Helper$check_object_type` method checks if the type of an object matches an
  expected type. If that is not the case, the helper throws an error (i.e.,
  `Exception$type_not_assignable`).

## Changed
- Change `backend` argument of `par_sapply` to `backend = NULL`. This implies,
  that `par_sapply` without a backend behaves identically to `base::sapply`.
- Update `roxygen2` `@examples` for exported wrappers. The code for the examples
  is located in the documentation for the `start_backend` function. All other
  exported wrappers (i.e., `clear`, `export`, `peek`, `evaluate`, and
  `par_sapply`) inherit the `@examples` section from `start_backend`.
- Update references in `@seealso` documentation sections.

## Fixed
- Update `export` method to use the `.GlobalEnv` as fallback when exporting
  variables.

# parabar 0.9.4

## Added
- Add custom styles to `extra.scss` to improve documentation website.
- Add `S3` print method for the `LOGO` object.

## Changed
- Improve documentation for exported objects.
- Merge documentations of `get_option`, `set_option`, and `set_default_options`.
- Improved `README`. More specifically, added description for `Service`
  interface methods and enabled documentation linking (i.e., via `?`) for
  `pkgdown` website.

## Fixed
- Add missing export for `Options` class.
- Ensure the examples in `ProgressBar` use `wait = TRUE` when fetching the
  output.
- Fix bug in the `evaluate` backend operation. The expression passed to
  `evaluate` was not correctly passed down the function chain to
  `parallel::clusterCall`. See [this
  question](https://stackoverflow.com/q/75543796/5252007) on `StackOverflow` for
  clarifications. Closes
  [#9](https://github.com/mihaiconstantin/parabar/issues/9).

# parabar 0.9.3

## Changed
- Change type of private field `.bar_config` in `ProgressDecorator` class to
  `list`. This way, the `configure_bar()` method of `ProgressBar` class becomes
  an optional step.

## Fixed
- Implement file locking when logging progress from child processes to avoid
  race conditions. The implementation is based on the `filelock` package. Closes
  [#8](https://github.com/mihaiconstantin/parabar/issues/8).
- Fix typo in `DESCRIPTION`.

# parabar 0.9.2

## Fixed
- Update `man-roxygen/parabar.R` `\html{...}` to fix `HTML` validation errors.
  Closes [#6](https://github.com/mihaiconstantin/parabar/issues/6).
- Fix package description in `DESCRIPTION` file to comply with `CRAN`
  requirements.

# parabar 0.9.1

## Fixed
- Update broken links in `README` file.
- Disable examples for `par_sapply` exported function due to exceeding the
  `CRAN` time limit for running examples.

# parabar 0.9.0

## Added
- Add package website via `pkgdown` and `GitHub` pages.
- Add `GitHub` workflow to automatically check the package on several platforms
  and `R` versions.
- Export all `R6` classes as developer API and regenerate the namespace.
- Add preliminary package documentation to `README` file.
- Add exported wrapper `par_sapply` to run tasks in parallel and display a
  progress bar if appropriate.
- Add exported wrapper `stop_backend` to stop a backend instance.
- Add exported wrapper `start_backend` to create a backend instance based on the
  specified specification.
- Add exported wrapper `configure_bar` for configuring the type and behavior of
  the progress bar.
- Add exported wrapper `set_option` for `Helper$set_option`. This function is
  available to end-users and can be used to set the value of a specific option.
- Add helper method for setting package options. The static method
  `Helper$set_option` is a wrapper around `base::getOption` that sets the value
  of a specific option if it exists, or throws an error otherwise.
- Add package object documentation and relevant information in `DESCRIPTION`
  file.
- Add `parabar` logo startup message for interactive `R` sessions.
- Add function to generate package logo based on the `ASCII` template in
  `inst/assets/logo/parabar-logo.txt`.
- Add exported wrapper `get_option` for `Helper$get_option`. This function is
  available to end-users and can be used to get the value of a specific option
  or its default value.
- Add helper method for getting package options or their defaults. The static
  method `Helper$get_option` is a wrapper around `base::getOption` that returns
  the value of a specific option if it exists, or the default value set by the
  `Options` class otherwise.
- Add `Options` `R6` class and `set_default_options` function to manage package
  options for `parabar`. The documented fields of the `Options` class represent
  the options that can be configured by the user. The `set_default_options`
  function can be used to set the default package options and is automatically
  run at package load time. In a nutshell, `set_default_options` stores an
  instance of `Options` in the `base::.Options` list under the key `parabar`.
- Implement initial software design. For a helicopter view, the design consists
  of `backend` and `context` objects. A `backend` represents a set of operations
  that can be deployed on a cluster produced by `parallel::makeCluster`. The
  backend, therefore, interacts with the cluster via specific operations defined
  by the `Service` interface. The `context` represents the specific conditions
  in which the backend operations are invoked. A regular context object simply
  forwards the call to the corresponding backend method. However, a more complex
  context can augment the operation before invoking the backend operation. One
  example of a complex context is the `ProgressDecorator` class. This class
  extends the regular `Context` class and decorates the backend `sapply`
  operation to provide progress tracking and display a progress bar.
- Add context classes to consume and decorate backend APIs. Since the context
  classes implement the `Service` interface, the client can interact with
  context objects as if they represents instances of `Backend` type. This
  release introduces the following contexts:
  - `Context`: represents a regular context that wraps backend objects. In other
    words, all `Service` methods calls implemented by this context are forwarded
    to the corresponding methods implemented by the backend object.
  - `ProgressDecorator`: represents a progress tracking context. This context
    decorates the `sapply` method available on the backend instance to log the
    progress after each task execution and display a progress bar.
  - `ContextFactory`: represents a blueprint for obtaining specific context
    instances.
- Add classes to work with synchronous and asynchronous backends:
  - `Service`: represents an *interface* that all concrete backends must
    implement. It contains the methods (i.e., operations) that can be requested
    from a given backend instance. These methods form the main API of `parabar`.
  - `Backend`: represents an abstract class that implements the `Service`
    interface. It contains fields and methods relevant to all concrete backend
    implementations that extend the class.
  - `SyncBackend`: represents a concrete implementation for a synchronous
    backend. When executing a task in parallel via the `sapply` method, the
    caller process (i.e., usually the interactive `R` session) is blocked until
    the task finishes executing.
  - `AsyncBackend`: represents a concrete implementation for an asynchronous
    backend. After lunching a task in parallel via the `sapply` method, the
    method returns immediately leaving the caller process (e.g., the interactive
    `R` session) free. The computation of the task is offloaded to a permanent
    background `R` session. One can read the state of the task using the public
    field (i.e., active binding) `task_state`. Furthermore, the results can be
    fetched from the background session using the `get_output` method, which can
    either block the main process to wait for the results, or attempt to fetch
    them immediately and throw an error if not successful.
  - `Specification`: represents an auxiliary class that encapsulates the logic
    for determining the type of cluster to create (i.e., via
    `parallel::makeCluster`), and the number of nodes (i.e., `R` processes) for
    the cluster.
  - `TaskState`: represents an auxiliary class that encapsulates the logic for
    determining the state of a task.
  - `BackendFactory`: represents a blueprint for obtaining concrete backend
    implementations.
- Add `Helper`, `Warning`, and `Exception` `R6` classes. These classes contain
  static member methods that provide useful utilities, handle warning messages,
  and throw informative errors, respectively.
- Add `UML` diagram for package classes. The classes provided by `parabar` can
  be split in three categories, namely (1) backend classes responsible for
  managing clusters, (2) context classes that decorate backend objects with
  additional functionality (e.g., progress tracking), and (3) progress bar
  classes providing a common interface for creating and interacting with various
  progress bars.

# parabar 0.1.0

## Added
- Add `Bar` abstraction for working with progress bars in `R`. Currently, two
  types of of progress bars are supported (i.e., `BasicBar` and `ModernBar`).
  `BasicBar` uses as engine the `utils::txtProgressBar`, and `ModernBar` relies
  on the `R6` class obtained from `progress::progress_bar`. Specific concrete
  instances of these bar types can be requested from the `BarFactory`.
