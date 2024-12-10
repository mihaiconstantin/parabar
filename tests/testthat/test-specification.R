# Test `Specification` class.

test_that("'Specification' fails on single core machines", {
    # Create a specification object.
    specification <- SpecificationTester$new()

    # Pretend the machine has a single core.
    specification$available_cores <- 1

    # Expect failure regardless of the number of requested cores.
    expect_error(specification$set_cores(cores = 1), as_text(Exception$not_enough_cores()))
    expect_error(specification$set_cores(cores = 2), as_text(Exception$not_enough_cores()))
    expect_error(specification$set_cores(cores = 7), as_text(Exception$not_enough_cores()))
})


test_that("'Specification' sets the number of cores correctly", {
    # Create a specification object.
    specification <- SpecificationTester$new()

    # Suppose the machine has two cores.
    specification$available_cores <- 2

    # When zero cores are requested.
    expect_warning(specification$set_cores(cores = 0), as_text(Warning$requested_cluster_cores_too_low()))
    expect_equal(specification$cores, 1)

    # When one core is requested.
    specification$set_cores(cores = 1)
    expect_equal(specification$cores, 1)

    # When two cores are requested.
    expect_warning(specification$set_cores(cores = 2), as_text(Warning$requested_cluster_cores_too_high(specification$usable_cores)))
    expect_equal(specification$cores, 1)

    # When more than two cores are requested.
    expect_warning(specification$set_cores(cores = 7), as_text(Warning$requested_cluster_cores_too_high(specification$usable_cores)))
    expect_equal(specification$cores, 1)

    # Suppose the machine has three cores.
    specification$available_cores <- 3

    # When zero cores are requested.
    expect_warning(specification$set_cores(cores = 0), as_text(Warning$requested_cluster_cores_too_low()))
    expect_equal(specification$cores, 1)

    # When one core is requested.
    specification$set_cores(cores = 1)
    expect_equal(specification$cores, 1)

    # When two cores are requested.
    specification$set_cores(cores = 2)
    expect_equal(specification$cores, 2)

    # When three cores are requested.
    expect_warning(specification$set_cores(cores = 3), as_text(Warning$requested_cluster_cores_too_high(specification$usable_cores)))
    expect_equal(specification$cores, 2)

    # Suppose the machine has eight cores.
    specification$available_cores <- 8

    # When zero cores are requested.
    expect_warning(specification$set_cores(cores = 0), as_text(Warning$requested_cluster_cores_too_low()))
    expect_equal(specification$cores, 1)

    # When one core is requested.
    specification$set_cores(cores = 1)
    expect_equal(specification$cores, 1)

    # When two cores are requested.
    specification$set_cores(cores = 2)
    expect_equal(specification$cores, 2)

    # When seven cores are requested.
    specification$set_cores(cores = 7)
    expect_equal(specification$cores, 7)

    # When eight cores are requested.
    expect_warning(specification$set_cores(cores = 8), as_text(Warning$requested_cluster_cores_too_high(specification$usable_cores)))
    expect_equal(specification$cores, 7)

    # When nine cores are requested.
    expect_warning(specification$set_cores(cores = 9), as_text(Warning$requested_cluster_cores_too_high(specification$usable_cores)))
    expect_equal(specification$cores, 7)
})


test_that("'Specification' sets the cluster type on Unix correctly", {
    # Skip test on Windows.
    skip_on_os("windows")

    # Create specification object.
    specification <- Specification$new()

    # Let the specification determine the cluster type.
    specification$set_type(type = NULL)

    # Expect a `FORK` cluster was determined as default on Unix platforms.
    expect_equal(specification$type, c(unix = "FORK"))

    # Specify the `FORK` type explicitly.
    specification$set_type(type = "fork")

    # Expect the correct type was set.
    expect_equal(specification$type, "FORK")

    # Specify the `PSOCK` type explicitly.
    specification$set_type(type = "psock")

    # Expect the correct type was set.
    expect_equal(specification$type, "PSOCK")

    # Expect warning when specifying an invalid type.
    expect_warning(
        specification$set_type(type = "invalid"),
        as_text(Warning$requested_cluster_type_not_supported(specification$types))
    )
})


test_that("'Specification' sets the cluster type on Windows correctly", {
    # Skip test on Unix and the like.
    skip_on_os(c("mac", "linux", "solaris"))

    # Create specification object.
    specification <- Specification$new()

    # Let the specification determine the cluster type.
    specification$set_type(type = NULL)

    # Expect a `PSOCK` cluster was determined as default on Windows platforms.
    expect_equal(specification$type, c(windows = "PSOCK"))

    # Expect warning if a `FORK` cluster is requested on Windows platforms.
    expect_warning(
        specification$set_type(type = "fork"),
        as_text(Warning$requested_cluster_type_not_compatible(specification$types))
    )

    # Expect that the correct type was set regardless the incompatible request.
    expect_equal(specification$type, c(windows = "PSOCK"))

    # Specify the `PSOCK` type explicitly.
    specification$set_type(type = "psock")

    # Expect the correct type was set.
    expect_equal(specification$type, "PSOCK")

    # Expect warning when specifying an invalid type.
    expect_warning(
        specification$set_type(type = "invalid"),
        as_text(Warning$requested_cluster_type_not_supported(specification$types))
    )
})
