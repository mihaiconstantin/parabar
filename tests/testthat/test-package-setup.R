# Test `parabar` package setup.

test_that("'parabar' package attaches correctly", {
    # Expect the package to be in the search path.
    expect_true("package:parabar" %in% search())

    # Expect the package options to be in the session after loading.
    expect_true(is(getOption("parabar"), "Options"))
})
