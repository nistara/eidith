---
title: "Eidith R Package Setup"
output: 
  rmarkdown::html_vignette
author: "Noam Ross"
vignette: >
  %\VignetteIndexEntry{Eidith R Package Setup}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



The **eidith** R package provides programmatic access and analytical tools for
data from the [PREDICT Program](http://www.vetmed.ucdavis.edu/ohi/predict/),
housed at the [Emerging Infectious Disease Information Technology Hub](https://www.eidith.org/) (EIDITH).

The **eidith** package contains no data. To access data, you must be a
[registered](https://www.eidith.org/register.aspx) EIDITH user with data access
privileges. If you have a question about your access level, contact technology@eidith.org.

This package is currently in development. We anticipate additional functionality
for common analytical tasks. It also currently only accesses data from PREDICT-1. If
you have questions, bug reports, or feature requests, please post them on our
[issue tracker](https://github.com/ecohealthalliance/eidith/issues).

### Installation

**eidith** is installed from our own package repository rather than CRAN.  To
install the latest stable version, run the following command:


```r
install.packages("eidith", repos=c("https://ecohealthalliance.github.io/eidith/", "https://cran.rstudio.com"))
```

If you wish to install the latest *development* (unstable) version, you will
require the **devtools** package, like so:


```r
devtools::install_github('ecohealthalliance/eidith@dev')
```

### Authentication

To download data from EIDITH, you must provide logon credentials.  If you run
`ed_db_download()` or the `ed_get()` functions from the R console, your EIDITH username
and password will be requested.  To use these functions in scripts, you 
must provide these credentials as *environment variables*.  

You can cache your credentials and login automatically by putting them in a hidden
`.Renviron` file, which defines environment variables for your R session. For
more information see the `ed_auth()` help file.

### Downloading data

The **eidith** package downloads data from EIDITH and stores it locally on your
computer in a database so you don't have to download from the web repeatedly.
Once you've installed the package, you'll need to populated this database with
the `ed_db_download()` command, like so:

```
library(eidith)
ed_db_download()
```
This may take a few minutes to complete depending on the speed of your internet
connection.

Running `ed_db_status()` will give you a summary of the contents of your database.
This is useful to see which countries' data you have access to or the latest
updated you have downloaded.

`ed_db_updates()` will check if the online database has been updated since
your last download.  If it has, `ed_db_download()` may be run again to update your local database with the latest
data.  You should also run it after installing a new version of the **eidith**
package, as a new version may change the structure of the database.

### Loading data

Once you've populated your local database, you can look up EIDITH data with
the *table functions*, each of which loads data from the different table in the
database: `ed_events()`, `ed_animals()`, `ed_specimens()`, `ed_tests()`, and
`ed_viruses()`, as well as `ed_testspecimen()`, which contains cross-references
between the test and specimen tables.  See the help for these functions for more
details.

`ed_metadata()` contains a list of all variables across these tables
and some information on them.  If you lookup this in R help in RStudio with
`?ed_metadata` you'll find this metadata in searchable form.
