#' Create documents to a database.
#'
#' @export
#' @template all
#' @template return
#' @param dbname Database name3
#' @param doc Document content, can be character string or a list.
#' The character type can be XML as well, if embedded in JSON. When
#' the document is retrieved via [doc_get()], the XML is given back and
#' you can parse it as normal.
#' @param docid Document ID
#' @param how (character) One of rows (default) or columns. If rows, each row
#' becomes a separate document; if columns, each column becomes a separate
#' document.
#' @param as (character) One of list (default) or json
#'
#' @details Documents can have attachments just like email. There are two ways
#' to use attachments: the first one is via a separate REST call
#' (see [doc_attach_create()]); the second is inline within your
#' document, you can do so with this fxn. See
#' https://docs.couchdb.org/en/latest/api/document/attachments.html for help
#' on formatting json appropriately.
#'
#' Note that you can create documents from a data.frame with this function,
#' where each row or column is a separate document. However, this function
#' does not use the bulk API
#' <https://couchdb.readthedocs.org/en/latest/api/database/bulk-api.html#db-bulk-docs>
#' - see [db_bulk_create()] and [db_bulk_update()] to
#' create or update documents with the bulk API - which should be much faster
#' for a large number of documents.
#' 
#' @section Digits after the decimal:
#' If you have any concern about number of digits after the decimal
#' in your documents, make sure to look at `digits` in your R options.
#' The default value is 7 (see [options] for more informnation). You
#' can set the value you like with e.g., `options(digits = 10)`, and 
#' get what `digits` is set to with `getOption("digits")`. 
#' 
#' Note that in [doc_create()] we convert your document to JSON with 
#' `jsonlite::toJSON()` if given as a list, which has a `digits` parameter.
#' We pass `getOption("digits")` to the `digits` parameter in 
#' `jsonlite::toJSON()` 
#' 
#' @examples \dontrun{
#' user <- Sys.getenv("COUCHDB_TEST_USER")
#' pwd <- Sys.getenv("COUCHDB_TEST_PWD")
#' (x <- Cushion$new(user=user, pwd=pwd))
#'
#' if ("sofadb" %in% db_list(x)) {
#'   invisible(db_delete(x, dbname="sofadb"))
#' }
#' db_create(x, 'sofadb')
#'
#' # write a document WITH a name (uses PUT)
#' doc1 <- '{"name": "drink", "beer": "IPA", "score": 5}'
#' doc_create(x, dbname="sofadb", doc1, docid="abeer")
#' doc_create(x, dbname="sofadb", doc1, docid="morebeer", as='json')
#' doc_get(x, dbname = "sofadb", docid = "abeer")
#' ## with factor class values
#' doc2 <- list(name = as.factor("drink"), beer = "stout", score = 4)
#' doc_create(x, doc2, dbname="sofadb", docid="nextbeer", as='json')
#' doc_get(x, dbname = "sofadb", docid = "nextbeer")
#'
#' # write a json document WITHOUT a name (uses POST)
#' doc2 <- '{"name": "food", "icecream": "rocky road"}'
#' doc_create(x, doc2, dbname="sofadb")
#' doc3 <- '{"planet": "mars", "size": "smallish"}'
#' doc_create(x, doc3, dbname="sofadb")
#' ## assigns a UUID instead of a user given name
#' db_alldocs(x, dbname = "sofadb")
#'
#' # write an xml document WITH a name (uses PUT). xml is written as xml in
#' # couchdb, just wrapped in json, when you get it out it will be as xml
#' doc4 <- "<top><a/><b/><c><d/><e>bob</e></c></top>"
#' doc_create(x, doc4, dbname="sofadb", docid="somexml")
#' doc_get(x, dbname = "sofadb", docid = "somexml")
#'
#' # You can pass in lists that autoconvert to json internally
#' doc1 <- list(name = "drink", type = "soda", score = 9)
#' doc_create(x, dbname="sofadb", doc1, docid="gooddrink")
#'
#' # Write directly from a data.frame
#' ## Each row or column becomes a separate document
#' ### by rows
#' if ("test" %in% db_list(x)) {
#'   invisible(db_delete(x, dbname="test"))
#' }
#' db_create(x, dbname = "test")
#' doc_create(x, mtcars, dbname="test", how="rows")
#' doc_create(x, mtcars, dbname="test", how="columns")
#'
#' if ("testiris" %in% db_list(x)) {
#'   invisible(db_delete(x, dbname="testiris"))
#' }
#' db_create(x, dbname = "testiris")
#' head(iris)
#' doc_create(x, iris, dbname = "testiris")
#' }
doc_create <- function(cushion, dbname, doc, docid = NULL,
                       how = 'rows', as = 'list', ...) {
  check_cushion(cushion)
  doc_create_(doc, cushion, dbname, docid, how, as, ...)
}

doc_create_ <- function(doc, cushion, dbname, docid = NULL,
                       how = 'rows', as = 'list', ...) {
  UseMethod("doc_create_")
}

doc_create_.character <- function(doc, cushion, dbname, docid = NULL,
                                 how = 'rows', as = 'list', ...) {
  url <- sprintf("%s/%s", cushion$make_url(), dbname)
  docex <- tryCatch(doc_head(cushion, dbname, docid), error = function(e) e)
  rev <- if (inherits(docex, "error")) NULL else docex$rev
  if (!is.null(docid)) {
    sofa_PUT_doc_create(file.path(url, docid), as, body = check_inputs(doc),
      encode = "json", rev = rev,
      headers = c(cushion$get_headers(), list(`Accept` = "application/json")),
      auth = cushion$get_auth(), ...)
  } else {
    sofa_POST(url, as, body = check_inputs(doc),
              headers = cushion$get_headers(), auth = cushion$get_auth(), ...)
  }
}

doc_create_.list <- function(doc, cushion, dbname, docid = NULL,
                                 how = 'rows', as = 'list', ...) {
  url <- sprintf("%s/%s", cushion$make_url(), dbname)
  if (!is.null(docid)) {
    sofa_PUT(paste0(url, "/", docid), as, body = check_inputs(doc),
             headers = cushion$get_headers(), auth = cushion$get_auth(), ...)
  } else {
    sofa_POST(url, as, body = check_inputs(doc),
              headers = cushion$get_headers(), auth = cushion$get_auth(), ...)
  }
}

doc_create_.data.frame <- function(doc, cushion, dbname, docid = NULL,
                            how = 'rows', as = 'list', ...) {
  url <- sprintf("%s/%s", cushion$make_url(), dbname)
  each <- parse_df(doc, how = how)
  lapply(each, function(x) {
    sofa_POST(url, as, body = x,
              headers = cushion$get_headers(), auth = cushion$get_auth(), ...)
  })
}

sofa_PUT_doc_create <- function(url, as = 'list', body, encode = "json", rev,
                                headers = NULL, auth = NULL, ...){
  as <- match.arg(as, c('list','json'))
  cli <- crul::HttpClient$new(
    url = url,
    headers = sc(c(ct_json, headers, list(`If-Match` = rev))),
    opts = sc(c(auth, list(...))))
  res <- cli$put(body = body, encode = encode)
  txt <- res$parse("UTF-8")
  if (as == 'json') txt else jsonlite::fromJSON(txt, FALSE)
}
