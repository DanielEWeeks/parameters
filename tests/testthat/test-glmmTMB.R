.runThisTest <- Sys.getenv("RunAllparametersTests") == "yes"

if (.runThisTest &&
  requiet("testthat") &&
  requiet("parameters") &&
  requiet("glmmTMB") &&
  getRversion() >= "4.0.0") {
  data("fish")
  data("Salamanders")

  win_os <- tryCatch(
    {
      si <- Sys.info()
      if (!is.null(si["sysname"])) {
        si["sysname"] == "Windows" || grepl("^mingw", R.version$os)
      } else {
        FALSE
      }
    },
    error = function(e) {
      FALSE
    }
  )

  m1 <- suppressWarnings(glmmTMB(
    count ~ child + camper + (1 | persons),
    ziformula = ~ child + camper + (1 | persons),
    data = fish,
    family = truncated_poisson()
  ))

  m2 <- suppressWarnings(glmmTMB(
    count ~ child + camper + (1 | persons),
    data = fish,
    family = poisson()
  ))

  m3 <- suppressWarnings(glmmTMB(
    count ~ spp + mined + (1 | site),
    ziformula = ~ spp + mined,
    family = nbinom2,
    data = Salamanders
  ))

  test_that("unsupported args", {
    expect_warning(model_parameters(m1, vcov = "HC3", effects = "fixed", component = "conditional"))
    expect_warning(model_parameters(m1, vcov = "HC3"))
  })

  test_that("ci", {
    expect_equal(
      ci(m1)$CI_low,
      c(0.33067, -1.32402, 0.55037, -1.66786, 1.44667, -1.64177),
      tolerance = 1e-3
    )
    expect_equal(
      ci(m1, component = "cond")$CI_low,
      c(0.33067, -1.32402, 0.55037),
      tolerance = 1e-3
    )
    expect_equal(
      ci(m1, component = "zi")$CI_low,
      c(-1.66786, 1.44667, -1.64177),
      tolerance = 1e-3
    )

    expect_equal(
      ci(m2)$CI_low,
      c(-0.47982, -1.85096, 0.76044),
      tolerance = 1e-3
    )
    expect_equal(
      ci(m2, component = "cond")$CI_low,
      c(-0.47982, -1.85096, 0.76044),
      tolerance = 1e-3
    )

    expect_null(ci(m2, component = "zi"))
  })



  test_that("se", {
    expect_equal(
      standard_error(m1)$SE,
      c(0.47559, 0.09305, 0.09346, 0.65229, 0.3099, 0.32324),
      tolerance = 1e-3
    )
    expect_equal(
      standard_error(m1, component = "cond")$SE,
      c(0.47559, 0.09305, 0.09346),
      tolerance = 1e-3
    )
    expect_equal(
      standard_error(m1, component = "zi")$SE,
      c(0.65229, 0.3099, 0.32324),
      tolerance = 1e-3
    )

    expect_equal(
      standard_error(m2)$SE,
      c(0.62127, 0.08128, 0.08915),
      tolerance = 1e-3
    )
    expect_equal(
      standard_error(m2, component = "cond")$SE,
      c(0.62127, 0.08128, 0.08915),
      tolerance = 1e-3
    )

    expect_null(standard_error(m2, component = "zi"))
  })


  test_that("p_value", {
    expect_equal(
      p_value(m1)$p,
      c(0.00792, 0, 0, 0.55054, 0, 0.00181),
      tolerance = 1e-3
    )
    expect_equal(
      p_value(m1, component = "cond")$p,
      c(0.00792, 0, 0),
      tolerance = 1e-3
    )
    expect_equal(
      p_value(m1, component = "zi")$p,
      c(0.55054, 0, 0.00181),
      tolerance = 1e-3
    )

    expect_equal(
      p_value(m2)$p,
      c(0.23497, 0, 0),
      tolerance = 1e-3
    )
    expect_equal(
      p_value(m2, component = "cond")$p,
      c(0.23497, 0, 0),
      tolerance = 1e-3
    )

    expect_null(p_value(m2, component = "zi"))
  })


  test_that("model_parameters", {
    expect_equal(
      model_parameters(m1, effects = "fixed")$Coefficient,
      c(1.2628, -1.14165, 0.73354, -0.38939, 2.05407, -1.00823),
      tolerance = 1e-3
    )
    expect_equal(
      model_parameters(m1, effects = "all")$Coefficient,
      c(1.2628, -1.14165, 0.73354, -0.38939, 2.05407, -1.00823, 0.9312, 1.17399),
      tolerance = 1e-3
    )
    expect_equal(
      model_parameters(m2, effects = "fixed")$Coefficient,
      c(0.73785, -1.69166, 0.93516),
      tolerance = 1e-3
    )
    expect_equal(
      model_parameters(m3, effects = "fixed")$Coefficient,
      c(
        -0.61038, -0.9637, 0.17068, -0.38706, 0.48795, 0.58949, -0.11327,
        1.42935, 0.91004, 1.16141, -0.93932, 1.04243, -0.56231, -0.893,
        -2.53981, -2.56303, 1.51165
      ),
      tolerance = 1e-2
    )
    expect_equal(
      model_parameters(m1)$Component,
      c(
        "conditional", "conditional", "conditional", "zero_inflated",
        "zero_inflated", "zero_inflated", "conditional", "zero_inflated"
      )
    )
    expect_null(model_parameters(m2, effects = "fixed")$Component)
    expect_equal(
      model_parameters(m2)$Component,
      c("conditional", "conditional", "conditional", "conditional")
    )
    expect_equal(
      model_parameters(m3, effects = "fixed")$Component,
      c(
        "conditional", "conditional", "conditional", "conditional",
        "conditional", "conditional", "conditional", "conditional", "zero_inflated",
        "zero_inflated", "zero_inflated", "zero_inflated", "zero_inflated",
        "zero_inflated", "zero_inflated", "zero_inflated", "dispersion"
      )
    )
    expect_equal(
      model_parameters(m3, effects = "fixed")$SE,
      c(
        0.4052, 0.6436, 0.2353, 0.3424, 0.2383, 0.2278, 0.2439, 0.3666,
        0.6279, 1.3346, 0.8005, 0.714, 0.7263, 0.7535, 2.1817, 0.6045,
        NA
      ),
      tolerance = 1e-2
    )
  })

  test_that("model_parameters.mixed-random", {
    params <- model_parameters(m1, effects = "random", group_level = TRUE)
    expect_equal(c(nrow(params), ncol(params)), c(8, 10))
    expect_equal(
      colnames(params),
      c(
        "Parameter", "Level", "Coefficient", "SE", "CI", "CI_low",
        "CI_high", "Component", "Effects", "Group"
      )
    )
    expect_equal(
      as.vector(params$Parameter),
      c(
        "(Intercept)", "(Intercept)", "(Intercept)", "(Intercept)",
        "(Intercept)", "(Intercept)", "(Intercept)", "(Intercept)"
      )
    )
    expect_equal(
      params$Component,
      c(
        "conditional", "conditional", "conditional", "conditional",
        "zero_inflated", "zero_inflated", "zero_inflated", "zero_inflated"
      )
    )
    expect_equal(
      params$Coefficient,
      c(-1.24, -0.3456, 0.3617, 1.2553, 1.5719, 0.3013, -0.3176, -1.5665),
      tolerance = 1e-2
    )
  })

  test_that("model_parameters.mixed-ran_pars", {
    params <- model_parameters(m1, effects = "random")
    expect_equal(c(nrow(params), ncol(params)), c(2, 9))
    expect_equal(
      colnames(params),
      c("Parameter", "Coefficient", "SE", "CI", "CI_low", "CI_high", "Effects", "Group", "Component")
    )
    expect_equal(
      params$Parameter,
      c("SD (Intercept)", "SD (Intercept)")
    )
    expect_equal(
      params$Component,
      c("conditional", "zero_inflated")
    )
    expect_equal(
      params$Coefficient,
      c(0.9312, 1.17399),
      tolerance = 1e-2
    )
  })

  test_that("model_parameters.mixed-all_pars", {
    params <- model_parameters(m1, effects = "all")
    expect_equal(c(nrow(params), ncol(params)), c(8, 12))
    expect_equal(
      colnames(params),
      c(
        "Parameter", "Coefficient", "SE", "CI", "CI_low",
        "CI_high", "z", "df_error", "p", "Effects", "Group", "Component"
      )
    )
    expect_equal(
      params$Parameter,
      c(
        "(Intercept)", "child", "camper1", "(Intercept)", "child",
        "camper1", "SD (Intercept)", "SD (Intercept)"
      )
    )
    expect_equal(
      params$Component,
      c(
        "conditional", "conditional", "conditional", "zero_inflated",
        "zero_inflated", "zero_inflated", "conditional", "zero_inflated"
      )
    )
    expect_equal(
      params$Coefficient,
      c(1.2628, -1.14165, 0.73354, -0.38939, 2.05407, -1.00823, 0.9312, 1.17399),
      tolerance = 1e-2
    )
  })

  test_that("model_parameters.mixed-all", {
    params <- model_parameters(m1, effects = "all", group_level = TRUE)
    expect_equal(c(nrow(params), ncol(params)), c(14, 13))
    expect_equal(
      colnames(params),
      c(
        "Parameter", "Level", "Coefficient", "SE", "CI", "CI_low",
        "CI_high", "z", "df_error", "p", "Component", "Effects",
        "Group"
      )
    )
    expect_equal(
      params$Parameter,
      c(
        "(Intercept)", "child", "camper1", "(Intercept)", "child",
        "camper1", "(Intercept)", "(Intercept)", "(Intercept)", "(Intercept)",
        "(Intercept)", "(Intercept)", "(Intercept)", "(Intercept)"
      )
    )
    expect_equal(
      params$Component,
      c(
        "conditional", "conditional", "conditional", "zero_inflated",
        "zero_inflated", "zero_inflated", "conditional", "conditional",
        "conditional", "conditional", "zero_inflated", "zero_inflated",
        "zero_inflated", "zero_inflated"
      )
    )
    expect_equal(
      params$Coefficient,
      c(
        1.2628, -1.1417, 0.7335, -0.3894, 2.0541, -1.0082, -1.24, -0.3456,
        0.3617, 1.2553, 1.5719, 0.3013, -0.3176, -1.5665
      ),
      tolerance = 1e-2
    )
  })


  data(mtcars)
  mdisp <- glmmTMB(hp ~ 0 + wt / mpg, mtcars)
  test_that("model_parameters, dispersion", {
    mp <- model_parameters(mdisp)
    expect_equal(mp$Coefficient, c(59.50992, -0.80396, 48.97731), tolerance = 1e-2)
    expect_equal(mp$Parameter, c("wt", "wt:mpg", "(Intercept)"))
    expect_equal(mp$Component, c("conditional", "conditional", "dispersion"))
  })

  mdisp <- glmmTMB(hp ~ 0 + wt / mpg + (1 | gear), mtcars)
  test_that("model_parameters, dispersion", {
    mp <- model_parameters(mdisp)
    expect_equal(mp$Coefficient, c(58.25869, -0.87868, 47.01676, 36.99492), tolerance = 1e-2)
    expect_equal(mp$Parameter, c("wt", "wt:mpg", "SD (Intercept)", "SD (Observations)"))
    expect_equal(mp$Component, c("conditional", "conditional", "conditional", "conditional"))
  })


  m4 <- suppressWarnings(glmmTMB(
    count ~ child + camper + (1 + xb | persons),
    ziformula = ~ child + camper + (1 + zg | persons),
    data = fish,
    family = truncated_poisson()
  ))

  test_that("model_parameters.mixed-ran_pars", {
    params <- model_parameters(m4, effects = "random")
    expect_equal(c(nrow(params), ncol(params)), c(6, 9))
    expect_equal(
      colnames(params),
      c("Parameter", "Coefficient", "SE", "CI", "CI_low", "CI_high", "Effects", "Group", "Component")
    )
    expect_equal(
      params$Parameter,
      c(
        "SD (Intercept)", "SD (xb)", "Cor (Intercept~xb)",
        "SD (Intercept)", "SD (zg)", "Cor (Intercept~zg)"
      )
    )
    expect_equal(
      params$Component,
      c(
        "conditional", "conditional", "conditional",
        "zero_inflated", "zero_inflated", "zero_inflated"
      )
    )
    expect_equal(
      params$Coefficient,
      c(3.40563, 1.21316, -1, 2.73583, 1.56833, 1),
      tolerance = 1e-2
    )
  })


  # exponentiate for dispersion = sigma parameters -----------------------

  set.seed(101)
  ## rbeta() function parameterized by mean and shape
  my_rbeta <- function(n, mu, shape0) {
    rbeta(n, shape1 = mu * shape0, shape2 = (1 - mu) * shape0)
  }
  n <- 100
  ng <- 10
  dd <- data.frame(x = rnorm(n), f = factor(rep(1:(n / ng), ng)))
  dd <- transform(dd, y = my_rbeta(n, mu = plogis(-1 + 2 * x + rnorm(ng)[f]), shape0 = 5))

  m_exp <- glmmTMB(y ~ x + (1 | f), family = "beta_family", dd)

  test_that("model_parameters, exp, glmmTMB", {
    mp1 <- model_parameters(m_exp, exponentiate = TRUE)
    mp2 <- model_parameters(m_exp, exponentiate = FALSE)
    expect_equal(mp1$Coefficient, c(0.49271, 6.75824, 5.56294, 1.14541), tolerance = 1e-3)
    expect_equal(mp1$Coefficient[3:4], mp2$Coefficient[3:4], tolerance = 1e-3)
  })

  test_that("model_parameters, no dispersion, glmmTMB", {
    mp1 <- model_parameters(m_exp, effects = "fixed", component = "conditional", exponentiate = TRUE)
    mp2 <- model_parameters(m_exp, effects = "fixed", component = "conditional", exponentiate = FALSE)
    expect_equal(mp1$Coefficient, unname(exp(unlist(fixef(m_exp)$cond))), tolerance = 1e-3)
    expect_equal(mp2$Coefficient, unname(unlist(fixef(m_exp)$cond)), tolerance = 1e-3)
  })


  # proper printing ---------------------

  if (win_os && getRversion() <= "4.2.0") {
    test_that("print-model_parameters glmmTMB", {
      mp <- model_parameters(m4, effects = "fixed", component = "conditional")
      out <- utils::capture.output(print(mp))
      expect_equal(
        out[-5],
        c(
          "# Fixed Effects",
          "",
          "Parameter   | Log-Mean |   SE |         95% CI |      z |      p",
          "----------------------------------------------------------------",
          "child       |    -1.09 | 0.10 | [-1.28, -0.90] | -11.09 | < .001",
          "camper [1]  |     0.27 | 0.10 | [ 0.07,  0.47] |   2.70 | 0.007 "
        )
      )

      mp <- model_parameters(m4, ci_random = TRUE, effects = "random", component = "conditional")
      out <- utils::capture.output(print(mp))
      expect_equal(
        out,
        c(
          "# Random Effects",
          "",
          "Parameter                   | Coefficient |        95% CI",
          "---------------------------------------------------------",
          "SD (Intercept: persons)     |        3.41 | [ 1.67, 6.93]",
          "SD (xb: persons)            |        1.21 | [ 0.60, 2.44]",
          "Cor (Intercept~xb: persons) |       -1.00 | [-1.00, 1.00]"
        )
      )

      mp <- model_parameters(m4, ci_random = TRUE, effects = "fixed", component = "zero_inflated")
      out <- utils::capture.output(print(mp))
      expect_equal(
        out[-6],
        c(
          "# Fixed Effects (Zero-Inflation Component)",
          "",
          "Parameter   | Log-Mean |   SE |        95% CI |     z |     p",
          "-------------------------------------------------------------",
          "(Intercept) |     1.89 | 0.66 | [ 0.59, 3.19] |  2.84 | 0.004",
          "camper [1]  |    -0.17 | 0.39 | [-0.93, 0.59] | -0.44 | 0.663"
        )
      )

      mp <- model_parameters(m4, ci_random = TRUE, effects = "random", component = "zero_inflated")
      out <- utils::capture.output(print(mp))
      expect_equal(
        out,
        c(
          "# Random Effects (Zero-Inflation Component)",
          "",
          "Parameter                   | Coefficient |        95% CI",
          "---------------------------------------------------------",
          "SD (Intercept: persons)     |        2.74 | [ 1.16, 6.43]",
          "SD (zg: persons)            |        1.57 | [ 0.64, 3.82]",
          "Cor (Intercept~zg: persons) |        1.00 | [-1.00, 1.00]"
        )
      )

      mp <- model_parameters(m4, ci_random = TRUE, effects = "all", component = "conditional")
      out <- utils::capture.output(print(mp))
      expect_equal(
        out[-5],
        c(
          "# Fixed Effects",
          "",
          "Parameter   | Log-Mean |   SE |         95% CI |      z |      p",
          "----------------------------------------------------------------",
          "child       |    -1.09 | 0.10 | [-1.28, -0.90] | -11.09 | < .001",
          "camper [1]  |     0.27 | 0.10 | [ 0.07,  0.47] |   2.70 | 0.007 ",
          "",
          "# Random Effects",
          "",
          "Parameter                   | Coefficient |        95% CI",
          "---------------------------------------------------------",
          "SD (Intercept: persons)     |        3.41 | [ 1.67, 6.93]",
          "SD (xb: persons)            |        1.21 | [ 0.60, 2.44]",
          "Cor (Intercept~xb: persons) |       -1.00 | [-1.00, 1.00]"
        )
      )

      mp <- model_parameters(m4, effects = "all", ci_random = TRUE, component = "zero_inflated")
      out <- utils::capture.output(print(mp))
      expect_equal(
        out[-6],
        c(
          "# Fixed Effects (Zero-Inflation Component)",
          "",
          "Parameter   | Log-Mean |   SE |        95% CI |     z |     p",
          "-------------------------------------------------------------",
          "(Intercept) |     1.89 | 0.66 | [ 0.59, 3.19] |  2.84 | 0.004",
          "camper [1]  |    -0.17 | 0.39 | [-0.93, 0.59] | -0.44 | 0.663",
          "",
          "# Random Effects (Zero-Inflation Component)",
          "",
          "Parameter                   | Coefficient |        95% CI",
          "---------------------------------------------------------",
          "SD (Intercept: persons)     |        2.74 | [ 1.16, 6.43]",
          "SD (zg: persons)            |        1.57 | [ 0.64, 3.82]",
          "Cor (Intercept~zg: persons) |        1.00 | [-1.00, 1.00]"
        )
      )

      mp <- model_parameters(m4, effects = "all", component = "all", ci_random = TRUE)
      out <- utils::capture.output(print(mp))
      expect_equal(
        out[-c(5, 14)],
        c(
          "# Fixed Effects (Count Model)",
          "",
          "Parameter   | Log-Mean |   SE |         95% CI |      z |      p",
          "----------------------------------------------------------------",
          "child       |    -1.09 | 0.10 | [-1.28, -0.90] | -11.09 | < .001",
          "camper [1]  |     0.27 | 0.10 | [ 0.07,  0.47] |   2.70 | 0.007 ",
          "",
          "# Fixed Effects (Zero-Inflation Component)",
          "",
          "Parameter   | Log-Odds |   SE |        95% CI |     z |     p",
          "-------------------------------------------------------------",
          "(Intercept) |     1.89 | 0.66 | [ 0.59, 3.19] |  2.84 | 0.004",
          "camper [1]  |    -0.17 | 0.39 | [-0.93, 0.59] | -0.44 | 0.663",
          "",
          "# Random Effects Variances",
          "",
          "Parameter                   | Coefficient |        95% CI",
          "---------------------------------------------------------",
          "SD (Intercept: persons)     |        3.41 | [ 1.67, 6.93]",
          "SD (xb: persons)            |        1.21 | [ 0.60, 2.44]",
          "Cor (Intercept~xb: persons) |       -1.00 | [-1.00, 1.00]",
          "",
          "# Random Effects (Zero-Inflation Component)", "", "Parameter                   | Coefficient |        95% CI",
          "---------------------------------------------------------",
          "SD (Intercept: persons)     |        2.74 | [ 1.16, 6.43]",
          "SD (zg: persons)            |        1.57 | [ 0.64, 3.82]",
          "Cor (Intercept~zg: persons) |        1.00 | [-1.00, 1.00]"
        )
      )
    })


    # proper printing of digits ---------------------

    test_that("print-model_parameters glmmTMB digits", {
      mp <- model_parameters(m4, ci_random = TRUE, effects = "all", component = "all")
      out <- utils::capture.output(print(mp, digits = 4, ci_digits = 5))
      expect_equal(
        out[-c(5, 14)],
        c(
          "# Fixed Effects (Count Model)",
          "",
          "Parameter   | Log-Mean |     SE |               95% CI |        z |      p",
          "--------------------------------------------------------------------------",
          "child       |  -1.0875 | 0.0981 | [-1.27966, -0.89529] | -11.0903 | < .001",
          "camper [1]  |   0.2723 | 0.1009 | [ 0.07460,  0.46999] |   2.6996 | 0.007 ",
          "",
          "# Fixed Effects (Zero-Inflation Component)",
          "",
          "Parameter   | Log-Odds |     SE |              95% CI |       z |     p",
          "-----------------------------------------------------------------------",
          "(Intercept) |   1.8896 | 0.6646 | [ 0.58714, 3.19213] |  2.8435 | 0.004",
          "camper [1]  |  -0.1701 | 0.3898 | [-0.93409, 0.59395] | -0.4363 | 0.663",
          "",
          "# Random Effects Variances",
          "",
          "Parameter                   | Coefficient |              95% CI",
          "---------------------------------------------------------------",
          "SD (Intercept: persons)     |      3.4056 | [ 1.67398, 6.92858]",
          "SD (xb: persons)            |      1.2132 | [ 0.60210, 2.44440]",
          "Cor (Intercept~xb: persons) |     -1.0000 | [-1.00000, 1.00000]",
          "",
          "# Random Effects (Zero-Inflation Component)",
          "",
          "Parameter                   | Coefficient |              95% CI",
          "---------------------------------------------------------------",
          "SD (Intercept: persons)     |      2.7358 | [ 1.16473, 6.42622]",
          "SD (zg: persons)            |      1.5683 | [ 0.64351, 3.82225]",
          "Cor (Intercept~zg: persons) |      1.0000 | [-1.00000, 1.00000]"
        )
      )

      mp <- model_parameters(m4, effects = "all", component = "all", ci_random = TRUE, digits = 4, ci_digits = 5)
      out <- utils::capture.output(print(mp))
      expect_equal(
        out[-c(5, 14)],
        c(
          "# Fixed Effects (Count Model)",
          "",
          "Parameter   | Log-Mean |     SE |               95% CI |        z |      p",
          "--------------------------------------------------------------------------",
          "child       |  -1.0875 | 0.0981 | [-1.27966, -0.89529] | -11.0903 | < .001",
          "camper [1]  |   0.2723 | 0.1009 | [ 0.07460,  0.46999] |   2.6996 | 0.007 ",
          "",
          "# Fixed Effects (Zero-Inflation Component)",
          "",
          "Parameter   | Log-Odds |     SE |              95% CI |       z |     p",
          "-----------------------------------------------------------------------",
          "(Intercept) |   1.8896 | 0.6646 | [ 0.58714, 3.19213] |  2.8435 | 0.004",
          "camper [1]  |  -0.1701 | 0.3898 | [-0.93409, 0.59395] | -0.4363 | 0.663",
          "",
          "# Random Effects Variances",
          "",
          "Parameter                   | Coefficient |              95% CI",
          "---------------------------------------------------------------",
          "SD (Intercept: persons)     |      3.4056 | [ 1.67398, 6.92858]",
          "SD (xb: persons)            |      1.2132 | [ 0.60210, 2.44440]",
          "Cor (Intercept~xb: persons) |     -1.0000 | [-1.00000, 1.00000]",
          "",
          "# Random Effects (Zero-Inflation Component)", "", "Parameter                   | Coefficient |              95% CI",
          "---------------------------------------------------------------",
          "SD (Intercept: persons)     |      2.7358 | [ 1.16473, 6.42622]",
          "SD (zg: persons)            |      1.5683 | [ 0.64351, 3.82225]",
          "Cor (Intercept~zg: persons) |      1.0000 | [-1.00000, 1.00000]"
        )
      )
    })


    # proper alignment of CIs ---------------------

    model_pr <- tryCatch(
      {
        load(url("https://github.com/d-morrison/parameters/raw/glmmTMB/data/pressure_durations.RData"))
        glmmTMB(
          formula = n_samples ~ Surface + Side + Jaw + (1 | Participant / Session),
          ziformula = ~ Surface + Side + Jaw + (1 | Participant / Session),
          dispformula = ~1,
          family = nbinom2(),
          data = pressure_durations
        )
      },
      error = function(e) {
        NULL
      }
    )

    if (!is.null(model_pr)) {
      test_that("print-model_parameters glmmTMB CI alignment", {
        mp <- model_parameters(model_pr, effects = "random", component = "all", ci_random = TRUE)
        out <- utils::capture.output(print(mp))
        expect_equal(
          out,
          c(
            "# Random Effects: conditional",
            "",
            "Parameter                           | Coefficient |       95% CI",
            "----------------------------------------------------------------",
            "SD (Intercept: Session:Participant) |        0.27 | [0.08, 0.87]",
            "SD (Intercept: Participant)         |        0.38 | [0.16, 0.92]",
            "",
            "# Random Effects: zero_inflated",
            "",
            "Parameter                           | Coefficient |       95% CI",
            "----------------------------------------------------------------",
            "SD (Intercept: Session:Participant) |        0.69 | [0.40, 1.19]",
            "SD (Intercept: Participant)         |        2.39 | [1.25, 4.57]"
          )
        )
        mp <- model_parameters(model_pr, effects = "fixed", component = "all")
        out <- utils::capture.output(print(mp))
        expect_equal(
          out,
          c(
            "# Fixed Effects",
            "",
            "Parameter          | Log-Mean |   SE |        95% CI |     z |      p",
            "---------------------------------------------------------------------",
            "(Intercept)        |     2.12 | 0.30 | [ 1.53, 2.71] |  7.05 | < .001",
            "Surface [Lingual]  |     0.01 | 0.29 | [-0.56, 0.58] |  0.04 | 0.971 ",
            "Surface [Occlusal] |     0.54 | 0.22 | [ 0.10, 0.98] |  2.43 | 0.015 ",
            "Side [Anterior]    |     0.04 | 0.32 | [-0.58, 0.66] |  0.14 | 0.889 ",
            "Side [Left]        |    -0.04 | 0.20 | [-0.44, 0.37] | -0.17 | 0.862 ",
            "Jaw [Maxillar]     |    -0.10 | 0.21 | [-0.51, 0.30] | -0.51 | 0.612 ",
            "",
            "# Zero-Inflation",
            "",
            "Parameter          | Log-Odds |   SE |         95% CI |     z |      p",
            "----------------------------------------------------------------------",
            "(Intercept)        |     4.87 | 0.93 | [ 3.04,  6.69] |  5.23 | < .001",
            "Surface [Lingual]  |     0.93 | 0.34 | [ 0.27,  1.60] |  2.75 | 0.006 ",
            "Surface [Occlusal] |    -1.01 | 0.29 | [-1.59, -0.44] | -3.45 | < .001",
            "Side [Anterior]    |    -0.20 | 0.37 | [-0.93,  0.52] | -0.55 | 0.583 ",
            "Side [Left]        |    -0.38 | 0.27 | [-0.91,  0.14] | -1.44 | 0.151 ",
            "Jaw [Maxillar]     |     0.59 | 0.24 | [ 0.11,  1.07] |  2.42 | 0.016 ",
            "",
            "# Dispersion",
            "",
            "Parameter   | Coefficient |       95% CI",
            "----------------------------------------",
            "(Intercept) |        2.06 | [1.30, 3.27]"
          )
        )
      })
    }
  }



  test_that("model_parameters.mixed-all", {
    params <- model_parameters(m4, effects = "all")
    expect_equal(c(nrow(params), ncol(params)), c(12, 12))
    expect_equal(
      colnames(params),
      c(
        "Parameter", "Coefficient", "SE", "CI", "CI_low", "CI_high",
        "z", "df_error", "p", "Effects", "Group", "Component"
      )
    )
    expect_equal(
      params$Parameter,
      c(
        "(Intercept)", "child", "camper1", "(Intercept)", "child",
        "camper1", "SD (Intercept)", "SD (xb)", "Cor (Intercept~xb)",
        "SD (Intercept)", "SD (zg)", "Cor (Intercept~zg)"
      )
    )
    expect_equal(
      params$Component,
      c(
        "conditional", "conditional", "conditional", "zero_inflated",
        "zero_inflated", "zero_inflated", "conditional", "conditional",
        "conditional", "zero_inflated", "zero_inflated", "zero_inflated"
      )
    )
    expect_equal(
      params$Coefficient,
      c(
        2.54713, -1.08747, 0.2723, 1.88964, 0.15712, -0.17007, 3.40563,
        1.21316, -1, 2.73583, 1.56833, 1
      ),
      tolerance = 1e-2
    )
  })

  test_that("print-model_parameters", {
    out <- utils::capture.output(print(model_parameters(m1, effects = "fixed")))
    expect_equal(
      out,
      c(
        "# Fixed Effects",
        "",
        "Parameter   | Log-Mean |   SE |         95% CI |      z |      p",
        "----------------------------------------------------------------",
        "(Intercept) |     1.26 | 0.48 | [ 0.33,  2.19] |   2.66 | 0.008 ",
        "child       |    -1.14 | 0.09 | [-1.32, -0.96] | -12.27 | < .001",
        "camper [1]  |     0.73 | 0.09 | [ 0.55,  0.92] |   7.85 | < .001",
        "",
        "# Zero-Inflation",
        "",
        "Parameter   | Log-Odds |   SE |         95% CI |     z |      p",
        "---------------------------------------------------------------",
        "(Intercept) |    -0.39 | 0.65 | [-1.67,  0.89] | -0.60 | 0.551 ",
        "child       |     2.05 | 0.31 | [ 1.45,  2.66] |  6.63 | < .001",
        "camper [1]  |    -1.01 | 0.32 | [-1.64, -0.37] | -3.12 | 0.002 "
      )
    )

    out <- utils::capture.output(print(model_parameters(m1, effects = "fixed", exponentiate = TRUE)))
    expect_equal(
      out,
      c(
        "# Fixed Effects",
        "",
        "Parameter   |  IRR |   SE |       95% CI |      z |      p",
        "----------------------------------------------------------",
        "(Intercept) | 3.54 | 1.68 | [1.39, 8.98] |   2.66 | 0.008 ",
        "child       | 0.32 | 0.03 | [0.27, 0.38] | -12.27 | < .001",
        "camper [1]  | 2.08 | 0.19 | [1.73, 2.50] |   7.85 | < .001",
        "",
        "# Zero-Inflation",
        "",
        "Parameter   | Odds Ratio |   SE |        95% CI |     z |      p",
        "----------------------------------------------------------------",
        "(Intercept) |       0.68 | 0.44 | [0.19,  2.43] | -0.60 | 0.551 ",
        "child       |       7.80 | 2.42 | [4.25, 14.32] |  6.63 | < .001",
        "camper [1]  |       0.36 | 0.12 | [0.19,  0.69] | -3.12 | 0.002 "
      )
    )

    out <- utils::capture.output(print(model_parameters(m1, effects = "all")))
    expect_equal(
      out,
      c(
        "# Fixed Effects (Count Model)",
        "",
        "Parameter   | Log-Mean |   SE |         95% CI |      z |      p",
        "----------------------------------------------------------------",
        "(Intercept) |     1.26 | 0.48 | [ 0.33,  2.19] |   2.66 | 0.008 ",
        "child       |    -1.14 | 0.09 | [-1.32, -0.96] | -12.27 | < .001",
        "camper [1]  |     0.73 | 0.09 | [ 0.55,  0.92] |   7.85 | < .001",
        "",
        "# Fixed Effects (Zero-Inflation Component)",
        "",
        "Parameter   | Log-Odds |   SE |         95% CI |     z |      p",
        "---------------------------------------------------------------",
        "(Intercept) |    -0.39 | 0.65 | [-1.67,  0.89] | -0.60 | 0.551 ",
        "child       |     2.05 | 0.31 | [ 1.45,  2.66] |  6.63 | < .001",
        "camper [1]  |    -1.01 | 0.32 | [-1.64, -0.37] | -3.12 | 0.002 ",
        "",
        "# Random Effects Variances",
        "",
        "Parameter               | Coefficient |       95% CI",
        "----------------------------------------------------",
        "SD (Intercept: persons) |        0.93 | [0.46, 1.89]",
        "",
        "# Random Effects (Zero-Inflation Component)",
        "",
        "Parameter               | Coefficient |       95% CI",
        "----------------------------------------------------",
        "SD (Intercept: persons) |        1.17 | [0.54, 2.57]"
      )
    )
  })
}
