% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/print.parameters_model.R
\name{print.parameters_model}
\alias{print.parameters_model}
\alias{summary.parameters_model}
\title{Print model parameters}
\usage{
\method{print}{parameters_model}(
  x,
  pretty_names = TRUE,
  split_components = TRUE,
  select = NULL,
  caption = NULL,
  footer = NULL,
  digits = 2,
  ci_digits = 2,
  p_digits = 3,
  footer_digits = 3,
  show_sigma = FALSE,
  show_formula = FALSE,
  zap_small = FALSE,
  groups = NULL,
  column_width = NULL,
  ci_brackets = c("[", "]"),
  ...
)

\method{summary}{parameters_model}(object, ...)
}
\arguments{
\item{x, object}{An object returned by \code{\link[=model_parameters]{model_parameters()}}.}

\item{pretty_names}{Can be \code{TRUE}, which will return "pretty" (i.e. more human
readable) parameter names. Or \code{"labels"}, in which case value and variable
labels will be used as parameters names. The latter only works for "labelled"
data, i.e. if the data used to fit the model had \code{"label"} and \code{"labels"}
attributes. See also section \emph{Global Options to Customize Messages when Printing}.}

\item{split_components}{Logical, if \code{TRUE} (default), For models with
multiple components (zero-inflation, smooth terms, ...), each component is
printed in a separate table. If \code{FALSE}, model parameters are printed
in a single table and a \code{Component} column is added to the output.}

\item{select}{Character vector (or numeric index) of column names that should
be printed. If \code{NULL} (default), all columns are printed. The shortcut
\code{select = "minimal"} prints coefficient, confidence intervals and p-values,
while \code{select = "short"} prints coefficient, standard errors and p-values.}

\item{caption}{Table caption as string. If \code{NULL}, depending on the model,
either a default caption or no table caption is printed. Use \code{caption = ""}
to suppress the table caption.}

\item{footer}{Can either be \code{FALSE} or an empty string (i.e. \code{""}) to
suppress the footer, \code{NULL} to print the default footer, or a string. The
latter will combine the string value with the default footer.}

\item{digits, ci_digits, p_digits}{Number of digits for rounding or
significant figures. May also be \code{"signif"} to return significant
figures or \code{"scientific"} to return scientific notation. Control the
number of digits by adding the value as suffix, e.g. \code{digits = "scientific4"}
to have scientific notation with 4 decimal places, or \code{digits = "signif5"}
for 5 significant figures (see also \code{\link[=signif]{signif()}}).}

\item{footer_digits}{Number of decimal places for values in the footer summary.}

\item{show_sigma}{Logical, if \code{TRUE}, adds information about the residual
standard deviation.}

\item{show_formula}{Logical, if \code{TRUE}, adds the model formula to the output.}

\item{zap_small}{Logical, if \code{TRUE}, small values are rounded after
\code{digits} decimal places. If \code{FALSE}, values with more decimal
places than \code{digits} are printed in scientific notation.}

\item{groups}{Named list, can be used to group parameters in the printed output.
List elements may either be character vectors that match the name of those
parameters that belong to one group, or list elements can be row numbers
of those parameter rows that should belong to one group. The names of the
list elements will be used as group names, which will be inserted as "header
row". A possible use case might be to emphasize focal predictors and control
variables, see 'Examples'. Parameters will be re-ordered according to the
order used in \code{groups}, while all non-matching parameters will be added
to the end.}

\item{column_width}{Width of table columns. Can be either \code{NULL}, a named
numeric vector, or \code{"fixed"}. If \code{NULL}, the width for each table column is
adjusted to the minimum required width. If a named numeric vector, value
names are matched against column names, and for each match, the specified
width is used. If \code{"fixed"}, and table is split into multiple components,
columns across all table components are adjusted to have the same width.}

\item{ci_brackets}{Logical, if \code{TRUE} (default), CI-values are
encompassed in square brackets (else in parentheses).}

\item{...}{Arguments passed to or from other methods.}
}
\value{
Invisibly returns the original input object.
}
\description{
A \code{print()}-method for objects from \code{\link[=model_parameters]{model_parameters()}}.
}
\details{
\code{summary()} is a convenient shortcut for
\code{print(object, select = "minimal", show_sigma = TRUE, show_formula = TRUE)}.
}
\section{Global Options to Customize Messages and Tables when Printing}{

The \code{verbose} argument can be used to display or silence messages and
warnings for the different functions in the \strong{parameters} package. However,
some messages providing additional information can be displayed or suppressed
using \code{options()}:
\itemize{
\item \code{parameters_summary}: \code{options(parameters_summary = TRUE)} will override the
\code{summary} argument in \code{model_parameters()} and always show the model summary
for non-mixed models.
\item \code{parameters_mixed_summary}: \code{options(parameters_mixed_summary = TRUE)} will
override the \code{summary} argument in \code{model_parameters()} for mixed models, and
will then always show the model summary.
\item \code{parameters_cimethod}: \code{options(parameters_cimethod = TRUE)} will show the
additional information about the approximation method used to calculate
confidence intervals and p-values. Set to \code{FALSE} to hide this message when
printing \code{model_parameters()} objects.
\item \code{parameters_exponentiate}: \code{options(parameters_exponentiate = TRUE)} will
show the additional information on how to interpret coefficients of models
with log-transformed response variables or with log-/logit-links when the
\code{exponentiate} argument in \code{model_parameters()} is not \code{TRUE}. Set this option
to \code{FALSE} to hide this message when printing \code{model_parameters()} objects.
}

There are further options that can be used to modify the default behaviour
for printed outputs:
\itemize{
\item \code{parameters_labels}: \code{options(parameters_labels = TRUE)} will use variable
and value labels for pretty names, if data is labelled. If no labels
available, default pretty names are used.
\item \code{parameters_interaction}: \verb{options(parameters_interaction = <character>)}
will replace the interaction mark (by default, \code{*}) with the related character.
\item \code{parameters_select}: \verb{options(parameters_select = <value>)} will set the
default for the \code{select} argument. See argument's documentation for available
options.
}
}

\section{Interpretation of Interaction Terms}{

Note that the \emph{interpretation} of interaction terms depends on many
characteristics of the model. The number of parameters, and overall
performance of the model, can differ \emph{or not} between \code{a * b}
\code{a : b}, and \code{a / b}, suggesting that sometimes interaction terms
give different parameterizations of the same model, but other times it gives
completely different models (depending on \code{a} or \code{b} being factors
of covariates, included as main effects or not, etc.). Their interpretation
depends of the full context of the model, which should not be inferred
from the parameters table alone - rather, we recommend to use packages
that calculate estimated marginal means or marginal effects, such as
\CRANpkg{modelbased}, \CRANpkg{emmeans}, \CRANpkg{ggeffects}, or
\CRANpkg{marginaleffects}. To raise awareness for this issue, you may use
\code{print(...,show_formula=TRUE)} to add the model-specification to the output
of the \code{\link[=print.parameters_model]{print()}} method for \code{model_parameters()}.
}

\section{Labeling the Degrees of Freedom}{

Throughout the \strong{parameters} package, we decided to label the residual
degrees of freedom \emph{df_error}. The reason for this is that these degrees
of freedom not always refer to the residuals. For certain models, they refer
to the estimate error - in a linear model these are the same, but in - for
instance - any mixed effects model, this isn't strictly true. Hence, we
think that \code{df_error} is the most generic label for these degrees of
freedom.
}

\examples{
\donttest{
library(parameters)
if (require("glmmTMB", quietly = TRUE)) {
  model <- glmmTMB(
    count ~ spp + mined + (1 | site),
    ziformula = ~mined,
    family = poisson(),
    data = Salamanders
  )
  mp <- model_parameters(model)

  print(mp, pretty_names = FALSE)

  print(mp, split_components = FALSE)

  print(mp, select = c("Parameter", "Coefficient", "SE"))

  print(mp, select = "minimal")
}


# group parameters ------

data(iris)
model <- lm(
  Sepal.Width ~ Sepal.Length + Species + Petal.Length,
  data = iris
)
# don't select "Intercept" parameter
mp <- model_parameters(model, parameters = "^(?!\\\\(Intercept)")
groups <- list(
  "Focal Predictors" = c("Speciesversicolor", "Speciesvirginica"),
  "Controls" = c("Sepal.Length", "Petal.Length")
)
print(mp, groups = groups)

# or use row indices
print(mp, groups = list(
  "Focal Predictors" = c(1, 4),
  "Controls" = c(2, 3)
))

# only show coefficients, CI and p,
# put non-matched parameters to the end

data(mtcars)
mtcars$cyl <- as.factor(mtcars$cyl)
mtcars$gear <- as.factor(mtcars$gear)
model <- lm(mpg ~ hp + gear * vs + cyl + drat, data = mtcars)

# don't select "Intercept" parameter
mp <- model_parameters(model, parameters = "^(?!\\\\(Intercept)")
print(mp, groups = list(
  "Engine" = c("cyl6", "cyl8", "vs", "hp"),
  "Interactions" = c("gear4:vs", "gear5:vs")
))
}
}
\seealso{
There is a dedicated method to use inside rmarkdown files,
\code{\link[=print_md.parameters_model]{print_md()}}.
}
