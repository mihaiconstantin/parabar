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
    expect_equal(specification$cores, 2)

    # When one core is requested.
    expect_warning(specification$set_cores(cores = 1), as_text(Warning$requested_cluster_cores_too_low()))
    expect_equal(specification$cores, 2)

    # When two cores are requested.
    specification$set_cores(cores = 2)
    expect_equal(specification$cores, 2)

    # When more than two cores are requested.
    expect_warning(specification$set_cores(cores = 7), as_text(Warning$requested_cluster_cores_too_high(specification$usable_cores)))
    expect_equal(specification$cores, 2)

    # Suppose the machine has eight cores.
    specification$available_cores <- 8

    # When zero cores are requested.
    expect_warning(specification$set_cores(cores = 0), as_text(Warning$requested_cluster_cores_too_low()))
    expect_equal(specification$cores, 2)

    # When one core is requested.
    expect_warning(specification$set_cores(cores = 1), as_text(Warning$requested_cluster_cores_too_low()))
    expect_equal(specification$cores, 2)

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


test_that("'Specification' sets the type correctly", {
    # Create specification object.
    specification <- Specification$new()

    # Let the specification determine the cluster type.
    specification$set_type(type = NULL)

    # Expect the correct type was determined.
    if (.Platform$OS.type == "unix") {
       expect_equal(specification$type, c(unix = "FORK"))
    } else {
       expect_equal(specification$type, c(windows = "PSOCK"))
    }

    # Specify the `FORK` type explicitly.
    specification$set_type(type = "fork")

    # Expect the correct type was set.
    expect_equal(specification$type, "FORK")

    # Specify the `PSOCK` type explicitly.
    specification$set_type(type = "psock")

    # Expect the correct type was set.
    expect_equal(specification$type, "PSOCK")
})
