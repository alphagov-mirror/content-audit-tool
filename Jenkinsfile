#!/usr/bin/env groovy

library("govuk")

node {
  govuk.buildProject(
    rubyLintDiff: false,
    beforeTest: {
      govuk.setEnvar("TEST_COVERAGE", "true")
    }
  )
}
