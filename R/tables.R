logical_vars <- c("archived_data", "deep_forest_data", "prioritized_for_testing",
                  "pooled", "message_sent_to_country", "message_sent_to_govt",
                  "govt_approved_release", "predict_protocol", "known",
                  "human_health")

date_vars <- c("event_date", "sample_date", "specimen_date",
               "test_date", "lab_submission_date", "results_date")

datetime_vars <- c("date_created", "date_modified", "database_date")

#' Load EIDITH data from the local database
#'
#' These functions load data from the locally-stored SQLite database of downloaded
#' and cleaned EIDITH data. `ed_table` is a general function, and `ed_table_`
#' it's [standard evaluation](https://cran.r-project.org/web/packages/dplyr/vignettes/nse.html)
#' equivalent, useful for programming.  The other functions are convenience aliases
#' for the individual tables. Alternate versions return [mock data][ed_mock()] for
#' tutorials and practice.
#'
#' These functions take [dplyr::filter()] arguments to sub-set the data.  Using
#' these, the data is subsetted via SQL *before* it is loaded into memory.
#' For large tables, such as the *tests* table, this is useful for reducing the memory footprint of your R session.
#'
#' Note that subsetting in SQL is more limited:
#'
#' -  Use `0` or `1` instead of `TRUE` or `FALSE`
#' -  Dates are stored as character strings, but as they are in YYYY-MM-DD
#'    format, filtering such as `event_date > "2014-01-01"` still works.
#'
#' @param table one of the EIDITH database tables. One of "events", "animals",
#' "specimens", "tests", "viruses", or "test_specimen_ids".
#' @param ... arguments passed to [dplyr::filter()] to subset data
#' @param .dots standard-evaluation versions of subsetting arguments
#' @return a [tibble][tibble::tibble]-style data frame.
#' @importFrom dbplyr partial_eval
#' @importFrom dplyr tbl tbl_df filter_ mutate_at funs_ funs collect vars
#' @importFrom stringi stri_replace_first_regex stri_extract_last_regex stri_detect_fixed
#' @export
#' @rdname ed_table
ed_table_ <- function(table, ..., .dots) {
  dots <- lazyeval::all_dots(.dots, ...)
  dots = lazyeval::as.lazy_dots(   #This stuff deals with the dplyr bug found at https://github.com/hadley/dplyr/issues/511 by modifying "%in%" calls
    lapply(dots, function(dot_expr) {
      new_expr <- paste0(
        deparse(partial_eval(dot_expr[["expr"]], env=dot_expr[["env"]]),
                width.cutoff = 500L),
        collapse = "")
      if(stri_detect_fixed(new_expr, "%in%")) {
        matched_expr <- stri_extract_last_regex(new_expr, "(?<=%in%\\s).*$")
        if(length(eval(parse(text=matched_expr))) ==  0 ) {
          new_expr <- stri_replace_first_fixed(new_expr, matched_expr, "('')")
        }
        else if(length(eval(parse(text=matched_expr))) == 1) {
          new_expr <- stri_replace_first_fixed(new_expr, matched_expr,
                                               paste0("(", matched_expr, ")"))
        }
      }
      lazyeval::as.lazy(new_expr, env=dot_expr[["env"]])
    }))
  ed_tb <- tbl(eidith_db(), table)
  ed_tb %>%
    filter_(.dots=dots) %>%
    collect(n=Inf) %>%
    fix_classes()
}

fix_classes <- function(table) {
  logical_cols <- names(table)[names(table) %in% logical_vars]
  date_cols <-  names(table)[names(table) %in% date_vars]
  datetime_cols <- names(table)[names(table)  %in% datetime_vars]
  if(length(logical_cols) != 0) table <- mutate_at(table, vars(logical_cols), funs_("as.logical"))
  if(length(date_cols) != 0) table <- mutate_at(table, vars(date_cols), funs(quicktime))
  if(length(datetime_cols) != 0) table <- mutate_at(table, vars(datetime_cols), funs(quicktime2))
  return(table)
}

#' @export
#' @rdname ed_table
ed_table <- function(table, ...) {
  ed_table_(table, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname ed_table
ed_events <- function(...) {
  ed_table_("events", .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname ed_table
ed_animals <- function(...) {
  ed_table_("animals", .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname ed_table
ed_specimens <- function(...) {
  ed_table_("specimens", .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname ed_table
ed_tests <- function(...) {
  ed_table_("tests", .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname ed_table
ed_viruses <- function(...) {
  ed_table_("viruses", .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname ed_table
ed_testspecimen <- function(...) {
  ed_table_("test_specimen_ids", .dots = lazyeval::lazy_dots(...))
}
