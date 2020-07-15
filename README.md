# r_installer
:no_mouth: Silently install different versions of R on Windows

*Note: This repo is currently not working solution yet*

## Related work
[installr](https://github.com/talgalili/installr)

## Reference
1. https://www.r-bloggers.com/how-to-do-a-silent-install-of-r/
2. https://cran.r-project.org/bin/windows/base/rw-FAQ.html#Can-I-customize-the-installation_003f
3. https://jrsoftware.org/ishelp/

## Extra
While this repo is mainly to automate R installation outside of R, an R script ['install_packages.R'](https://raw.githubusercontent.com/jonekeat/r_installer/master/install_packages.R) also included for "safer" R package installation on Windows. For a better alternative, consider [pak](https://github.com/r-lib/pak).

### Usage
Run 'install_packages.R' and just install any packages you want!
```r
> required_packages <- c("disk.frame", "tsibble")
> install_packages(required_packages)
Warning in install_packages(required_packages) :
  Some non-base packages are loaded before installation: 'yaml'. Installing these packages might caused installation failed, try run 'rm(list = ls())' & launch a new R session

'disk.frame', 'tsibble' already installed and will be skipped. If you want to re-install these packages, try remove it first and re-run again
```
