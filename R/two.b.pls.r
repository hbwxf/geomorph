#' Two-block partial least squares analysis for shape data
#'
#' Function performs two-block partial least squares analysis to assess the degree of association between 
#' to blocks of Procrustes-aligned coordinates (or other variables)
#'
#' The function quantifies the degree of association between two blocks of shape data as 
#'   defined by landmark coordinates using partial least squares (see Rohlf and Corti 2000). If geometric morphometric data are 
#'   used, it is assumed 
#'   that the landmarks have previously been aligned using 
#'   Generalized Procrustes Analysis (GPA) [e.g., with \code{\link{gpagen}}]. If other variables are used, they must be input as a 
#'   2-Dimensional matrix (rows = specimens, columns = variables).  It is also assumed that the separate inputs
#'   have specimens (observations) in the same order.
#'   
#'  The generic functions, \code{\link{print}}, \code{\link{summary}}, and \code{\link{plot}} all work with \code{\link{two.b.pls}}.
#'  The generic function, \code{\link{plot}}, produces a two-block.pls plot.  This function calls \code{\link{plot.pls}}, which has two additional
#'  arguments (with defaults): label = NULL, warpgrids = TRUE.  These arguments allow one to include a vector to label points and a logical statement to
#'  include warpgrids, respectively.  Warpgrids can only be included for 3D arrays of Procrustes residuals. The plot is a plot of PLS scores from 
#'  Block1 versus Block2 performed for the first set of PLS axes. 
#'  
#'  \subsection{For more than two blocks}{ 
#' If one wishes to consider 3+ arrays or matrices, there are multiple options.  First, one could perform multiple two.b.pls analyses and use
#' \code{\link{compare.pls}} to ascertain which blocks are more "integrated".  Second, one could use \code{\link{integration.test}} and perform a test that
#' averages the amount of integration (correlations) across multiple pairwise blocks.  Note that \code{\link{integration.test}} performed on two matrices or
#' arrays returns the same results as two.b.pls.  (Thus, \code{\link{integration.test}} is more flexible and thorough.)
#' }
#' 
#'  \subsection{Using phylogenies and PGLS}{ 
#' If one wishes to incorporate a phylogeny, \code{\link{phylo.integration}} is the function to use.  This function is exactly the same as \code{\link{integration.test}}
#' but allows PGLS estimation of PLS vectors.  Because \code{\link{integration.test}} can be used on two blocks, \code{\link{phylo.integration}} likewise allows one to
#' perform a phylogenetic two-block PLS analysis.
#' }
#'  
#'  \subsection{Notes for geomorph 3.0}{ 
#' There is a slight change in two.b.pls plots with geomorph 3.0.  Rather than use the shapes of specimens that matched minimum and maximum PLS
#' scores, major-axis regression is used and the extreme fitted values are used to generate deformation grids.  This ensures that shape deformations
#' are exactly along the major axis of shape covariation.  This axis is also shown as a best-fit line in the plot.
#' }
#' 
#' @param A1 A 3D array (p x k x n) containing GPA-aligned coordinates for the first block, or a matrix (n x variables)
#' @param A2 A 3D array (p x k x n) containing GPA-aligned coordinates for the second block, or a matrix (n x variables)
#' @param iter Number of iterations for significance testing
#' @param seed An optional argument for setting the seed for random permutations of the resampling procedure.  
#' If left NULL (the default), the exact same P-values will be found for repeated runs of the analysis (with the same number of iterations).
#' If seed = "random", a random seed will be used, and P-values will vary.  One can also specify an integer for specific seed values,
#' which might be of interest for advanced users.
#' @param print.progress A logical value to indicate whether a progress bar should be printed to the screen.  
#' This is helpful for long-running analyses.
#' @export
#' @keywords analysis
#' @author Dean Adams and Michael Collyer
#' @return Object of class "pls" that returns a list of the following:
#'   \item{r.pls}{The correlation coefficient between scores of projected values on the first
#'   singular vectors of left (x) and right (y) blocks of landmarks (or other variables).  This value can only be negative
#'   if single variables are input, as it reduces to the Pearson correlation coefficient.}
#'   \item{P.value}{The empirically calculated P-value from the resampling procedure.}
#'   \item{left.pls.vectors}{The singular vectors of the left (x) block}
#'   \item{right.pls.vectors}{The singular vectors of the right (y) block}
#'   \item{random.r}{The correlation coefficients found in each random permutation of the 
#'   resampling procedure.}
#'   \item{XScores}{Values of left (x) block projected onto singular vectors.}
#'   \item{YScores}{Values of right (y) block projected onto singular vectors.}
#'   \item{svd}{The singular value decomposition of the cross-covariances.  See \code{\link{svd}} for further details.}
#'   \item{A1}{Input values for the left block.}
#'   \item{A2}{Input values for the right block.}
#'   \item{A1.matrix}{Left block (matrix) found from A1.}
#'   \item{A2.matrix}{Right block (matrix) found from A2.}
#'   \item{permutations}{The number of random permutations used in the resampling procedure.}
#'   \item{call}{The match call.}
#'   
#' @seealso \code{\link{integration.test}}, \code{\link{modularity.test}}, \code{\link{phylo.pls}},  
#' \code{\link{phylo.integration}}, and \code{\link{compare.pls}}
#' @references  Rohlf, F.J., and M. Corti. 2000. The use of partial least-squares to study covariation in shape. 
#' Systematic Biology 49: 740-753.
#' @examples
#' data(plethShapeFood) 
#' Y.gpa<-gpagen(plethShapeFood$land)    #GPA-alignment    
#'
#' #2B-PLS between head shape and food use data
#' PLS <-two.b.pls(Y.gpa$coords,plethShapeFood$food,iter=999)
#' summary(PLS)
#' plot(PLS)

two.b.pls <- function (A1, A2,  iter = 999, seed = NULL, print.progress=TRUE){
  if (any(is.na(A1)) == T) 
    stop("Data matrix 1 contains missing values. Estimate these first (see 'estimate.missing').")
  if (any(is.na(A2)) == T) 
    stop("Data matrix 2 contains missing values. Estimate these first (see 'estimate.missing').")
  if (is.null(dim(A1))) A1 <- as.matrix(A1); if (is.null(dim(A2))) A2 <- as.matrix(A2)
  if (length(dim(A1)) == 3) x <- two.d.array(A1) else x <- as.matrix(A1)
  if (length(dim(A2)) == 3) y <- two.d.array(A2) else y <- as.matrix(A2)
  if (nrow(x) != nrow(y)) stop("Data matrices have different numbers of specimens.")
  if (!is.null(rownames(x))  && !is.null(rownames(y))) {y <- y[rownames(x), ] }
  n <- nrow(x)
  pls.obs <- pls(x, y, RV=FALSE, verbose=TRUE)
  rownames(pls.obs$pls.svd$u) <- colnames(x)
  rownames(pls.obs$pls.svd$v) <- colnames(pls.obs$pls.svd$vt) <- colnames(y)
  if(NCOL(x) > n){
    pcax <- prcomp(x)
    d <- which(zapsmall(pcax$sdev) > 0)
    x <- pcax$x[,d]
  }
  if(NCOL(y) > n){
    pcay <- prcomp(y)
    d <- which(zapsmall(pcay$sdev) > 0)
    y <- pcay$x[,d]
  }
  if(print.progress) pls.rand <- apply.pls(center(x), center(y), RV=FALSE, iter=iter, seed=seed) else
    pls.rand <- .apply.pls(center(x), center(y), RV=FALSE, iter=iter, seed=seed) 
  p.val <- pval(abs(pls.rand))
  XScores <- pls.obs$XScores
  YScores <- pls.obs$YScores
  out <- list(r.pls = pls.rand[1], P.value = p.val,
              left.pls.vectors = pls.obs$left.vectors,
              right.pls.vectors = pls.obs$right.vectors,
              random.r = pls.rand, 
              XScores = pls.obs$XScores,
              YScores = pls.obs$YScores,
              svd = pls.obs$pls.svd,
              A1 = A1, A2 = A2,
              A1.matrix = x, A2.matrix =y,
              permutations = iter+1, call=match.call(),
              method="PLS")
  class(out) <- "pls"
  out
}
