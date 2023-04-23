# Test for logo-related objects.

test_that("'make_logo' function correctly sets the package version", {
    # Create a temporary file.
    path <- tempfile("parabar-logo")

    # Create a mock logo template.
    mock_logo_template <- c("parabar {{major}}.{{minor}}.{{patch}}")

    # Write mock logo template to the temporary file.
    writeLines(mock_logo_template, path)

    # Remove the file on exit.
    on.exit({
        # Remove.
        unlink(path)
    })

    # Expect that the logo is produced with the correct version.
    expect_equal(
        make_logo(template = path, version = c(1, 2, 3)),
        c("parabar 1.2.3")
    )

    # Expect that the logo version can also handle character.
    expect_equal(
        make_logo(template = path, version = c(1, "x", "x")),
        c("parabar 1.x.x")
    )
})


test_that("'LOGO' constant exists and is of correct type", {
    # Expect that the `LOGO` constant is not null.
    expect_false(is.null(LOGO))

    # Expect that the `LOGO` constant has the correct type.
    expect_true(is(LOGO, "parabar"))
})


test_that("'LOGO' is printed correctly", {
    # Capture the output of the `S3` method.
    output <- capture.output(print(LOGO))

    # Expect the logo to contain a given package version.
    expect_true(grepl("v\\d\\.x\\.x", output[2], perl = TRUE))
})
