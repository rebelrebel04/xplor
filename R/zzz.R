.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "xplor v", packageVersion("xplor")
    )
}
