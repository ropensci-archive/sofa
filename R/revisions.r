#' Get document revisions.
#'
#' @export
#' @template all
#' @template return
#' @param dbname Database name
#' @param docid Document ID
#' @param simplify (logical) Simplify to character vector of revision ids.
#' If `FALSE`, gives back availability info too. Default: `TRUE`
#' @examples \dontrun{
#' user <- Sys.getenv("COUCHDB_TEST_USER")
#' pwd <- Sys.getenv("COUCHDB_TEST_PWD")
#' (x <- Cushion$new(user = user, pwd = pwd))
#'
#' if ("sofadb" %in% db_list(x)) {
#'   db_delete(x, dbname = "sofadb")
#' }
#' db_create(x, dbname = "sofadb")
#'
#' doc1 <- '{"name": "drink", "beer": "IPA", "score": 5}'
#' doc_create(x, dbname = "sofadb", doc1, docid = "abeer")
#' doc_create(x, dbname = "sofadb", doc1, docid = "morebeer", as = "json")
#'
#' db_revisions(x, dbname = "sofadb", docid = "abeer")
#' db_revisions(x, dbname = "sofadb", docid = "abeer", simplify = FALSE)
#' db_revisions(x, dbname = "sofadb", docid = "abeer", as = "json")
#' db_revisions(x, dbname = "sofadb", docid = "abeer", simplify = FALSE, as = "json")
#' }
db_revisions <- function(cushion, dbname, docid, simplify = TRUE,
                         as = "list", ...) {
  check_cushion(cushion)
  call_ <- sprintf("%s/%s/%s", cushion$make_url(), dbname, docid)
  tmp <- sofa_GET(call_,
    as = "list", query = list(revs_info = "true"),
    cushion$get_headers(), cushion$get_auth(), ...
  )
  revs <- if (simplify) {
    vapply(tmp$`_revs_info`, "[[", "", "rev")
  } else {
    tmp$`_revs_info`
  }
  if (as == "json") jsonlite::toJSON(revs) else revs
}
