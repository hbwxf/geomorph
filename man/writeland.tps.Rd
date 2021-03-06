% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/writeland.tps.r
\name{writeland.tps}
\alias{writeland.tps}
\title{Write landmark data to tps file}
\usage{
writeland.tps(A, file, scale = NULL, specID = TRUE)
}
\arguments{
\item{A}{A 3D array (p x k x n) containing landmark coordinates for a set of specimens}

\item{file}{Name of the *.tps file to be created}

\item{scale}{An optional vector containing the length of the scale for each specimen}

\item{specID}{A logical value stating whether specimen ID names should be saved to line ID=}
}
\description{
Write *.tps file from obtain landmark coordinates in a 3-dimensional array
}
\details{
This function writes a *.tps file from a 3-dimensional array (p x k x n) 
 of landmark coordinates.
}
\author{
Dean Adams
}
\keyword{IO}

