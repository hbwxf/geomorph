% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/advanced.procD.lm.r
\name{advanced.procD.lm}
\alias{advanced.procD.lm}
\title{Procrustes ANOVA and pairwise tests for shape data, using complex linear models}
\usage{
advanced.procD.lm(f1, f2, groups = NULL, slope = NULL, angle.type = c("r",
  "deg", "rad"), pc.shape = FALSE, iter = 999, seed = NULL,
  print.progress = TRUE, data = NULL, ...)
}
\arguments{
\item{f1}{A formula for a linear model, containing the response matrix (e.g., y ~ x1 + x2)}

\item{f2}{A formula for another linear model (e.g., ~ x1 + x2 + x3 + a*b). f1 and f2 should be nested.}

\item{groups}{A formula for grouping factors (e.g., ~ a, or ~ a*b).  This argument should be left NULL unless one wishes to perform pairwise
comparisons of different group levels.  Note that this argument is used in conjunction with the argument, slope.  If slope is NULL, a pairwise
comparison test is performed on group least squares (LS) means.  If slope is not NULL, this argument will designate the group levels to compare
in terms of their slopes.}

\item{slope}{A formula with one - and only one - covariate (e.g., ~ x3).  This argument must be used in conjunction with the groups argument.  It 
will not make sense if the groups argument is left NULL.  The groups argument defines the groups; the slope argument defines for which covariate group
slopes are compared.  Group slopes can differ in their magnitude and direction of shape change.}

\item{angle.type}{A value specifying whether directional differences between slopes should be represented by vector
correlations (r), radians (rad) or degrees (deg).}

\item{pc.shape}{An argument for whether analysis should be performed on the principal component scores fo shape.  This is a useful
option if the data are high-dimensional (many more variables that observations) but will not affect results}

\item{iter}{Number of iterations for significance testing}

\item{seed}{An optional argument for setting the seed for random permutations of the resampling procedure.
If left NULL (the default), the exact same P-values will be found for repeated runs of the analysis (with the same number of iterations).
If seed = "random", a random seed will be used, and P-values will vary.  One can also specify an integer for specific seed values,
which might be of interest for advanced users.}

\item{print.progress}{A logical value to indicate whether a progress bar should be printed to the screen.
This is helpful for long-running analyses.}

\item{data}{A data frame for the function environment; see \code{\link{geomorph.data.frame}}.  If variables
are transformed in formulae, they should also be transformed in the geomorph data frame.  (See examples.)}

\item{...}{Arguments passed on to procD.fit (typically associated with the lm function)}
}
\value{
Function returns an ANOVA table of statistical results for model comparison: error df (for each model), SS, MS,
F ratio, Z, and Prand.  A list of essentially the same components as \code{\link{procD.lm}} is also returned, and additionally
LS means or slopes, pairwise differences comparisons of these, effect sizes, and P-values may also be returned.  If a group formula
is provided but slope formula is null, pairwise differences are Procrustes distances between least squares (LS) means for the 
defined groups.  If a slope formula is provided, two sets of pairwise differences, plus effect sizes and P-values, are provided.  
The first is for differences in slope vector length (magnitude).  The length of the slope vector corresponds to the amount of shape
change per unit of covariate change.  Large differences correspond to differences in the amount of shape change between groups.  
The second is for slope vector orientation differences.  Differences in the direction of shape change (covariance of shape variables)
can be summarized as a vector correlation or angle between vectors.  See \code{\link{summary.advanced.procD.lm}} for summary options.
}
\description{
The function quantifies the relative amount of shape variation explained by a suite of factors
and covariates in a "full" model, after accounting for variation in a "reduced" model. Inputs are 
formulae for full and reduced models (order is not important, but it is better to list the model 
with the most terms first or use a geomorph data frame), plus indication if means or slopes 
are to be compared among groups, with appropriate formulae to define how they should be compared.
}
\details{
The response matrix 'y' can be in the form of a two-dimensional data 
  matrix of dimension (n x [p x k]) or a 3D array (p x k x n). It is assumed that the landmarks have previously 
  been aligned using Generalized Procrustes Analysis (GPA) [e.g., with \code{\link{gpagen}}]. The names specified for the 
  independent (x) variables in the formula represent one or more 
  vectors containing continuous data or factors. It is assumed that the order of the specimens in the 
  shape matrix matches the order of values in the independent variables. Linear model fits (using the  \code{\link{lm}} function)
  can also be input in place of a formula.  Arguments for \code{\link{lm}} can also be passed on via this function.

The function performs statistical assessment of the terms in the model using Procrustes distances among 
  specimens, rather than explained covariance matrices among variables. With this approach, the sum-of-squared 
  Procrustes distances are used as a measure of SS (see Goodall 1991). The SS between models is evaluated through 
  permutation. In morphometrics this approach is known as a Procrustes ANOVA (Goodall 1991), which is equivalent
  to distance-based anova designs (Anderson 2001). Unlike \code{\link{procD.lm}}, this function is strictly for comparison
  of two nested models. (Use of \code{\link{procD.lm}} will be more suitable in most cases.)  
  A residual randomization permutation procedure (RRPP) is utilized 
  for reduced model residuals to evaluate the SS between models (Collyer et al. 2015).  Effect-sizes (Z-scores) are 
  computed as standard deviates of the SS sampling 
  distributions generated, which might be more intuitive for P-values than F-values (see Collyer et al. 2015).  
  
  Pairwise tests are only performed if formulae are provided to compute such results.
  The generic functions, \code{\link{print}}, \code{\link{summary}}, and \code{\link{plot}} all work with \code{\link{advanced.procD.lm}}.
  The generic function, \code{\link{plot}}, produces diagnostic plots for Procrustes residuals of the linear fit.
}
\examples{
data(plethodon)
Y.gpa<-gpagen(plethodon$land)    #GPA-alignment
gdf <- geomorph.data.frame(Y.gpa, species = plethodon$species, site = plethodon$site)

# Example of a nested model comparison (as with ANOVA with RRPP)
advanced.procD.lm(coords ~ log(Csize) + species, 
~ log(Csize)*species*site, iter=499, data = gdf)

# Example of a test of a factor interaction, plus pairwise comparisons 
advanced.procD.lm(coords ~ site*species, ~ site + species, groups = ~site*species, 
   iter=499, data = gdf)

# Example of a test of a factor interaction, plus pairwise comparisons, 
# accounting for a common allometry  
advanced.procD.lm(coords ~ Csize + site*species, 
~ log(Csize) + site + species, 
groups = ~ site*species, slope = ~log(Csize), iter = 499, data = gdf)

# Example of a test of homogeneity of slopes, plus pairwise slopes comparisons
gdf$group <- factor(paste(gdf$species, gdf$site, sep="."))
advanced.procD.lm(coords ~ log(Csize) + group, 
~ log(Csize) * group, 
groups = ~ group, 
slope = ~ log(Csize), angle.type = "deg", iter = 499, data = gdf)

# Example of partial pairwise comparisons, given greater model complexity.
# Plus, working with class advanced.procD.lm objects.
aov.pleth <- advanced.procD.lm(coords ~ log(Csize)*site*species, 
~ log(Csize) + site*species, 
groups = ~ species, slope = ~ log(Csize), angle.type = "deg", iter = 499, data = gdf)

summary(aov.pleth) # ANOVA plus pairwise tests
plot(aov.pleth) # diagnostic plots
aov.pleth$slopes # extract the slope vectors
}
\author{
Michael Collyer
}
\references{
Collyer, M.L., D.J. Sekora, and D.C. Adams. 2015. A method for analysis of phenotypic change for phenotypes described 
by high-dimensional data. Heredity. 115:357-365.
}
\seealso{
\code{\link{procD.lm}}
}
\keyword{analysis}

