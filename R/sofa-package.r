#' @title R client for CouchDB.
#'
#' @description Relax.
#'
#' @section About sofa:
#' \pkg{sofa} provides an interface to the NoSQL database CouchDB
#' (<http://couchdb.apache.org>). Methods are provided for managing
#' databases within CouchDB, including creating/deleting/updating/transferring,
#' and managing documents within databases. One can connect with a local
#' CouchDB instance, or a remote CouchDB databases such as Cloudant
#' (<https://cloudant.com>). Documents can be inserted directly from
#' vectors, lists, data.frames, and JSON.
#'
#' @section Client connections:
#' All functions take as their first parameter a client connection object,
#' or a **cushion**. Create the object with [Cushion]. You
#' can have multiple connection objects in an R session.
#'
#' @section CouchDB versions:
#' \pkg{sofa} was built assuming CouchDB version 2 or greater. Some
#' functionality of this package will work with versions < 2, while
#' some may not (mango queries, see [db_query()]). I don't
#' plan to support older CouchDB versions per se.
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
#' `jsonlite::toJSON()`.
#'
#' @section Defunct functions:
#'
#' - [attach_get]
#'
#' @importFrom R6 R6Class
#' @importFrom jsonlite fromJSON toJSON unbox
#' @importFrom crul HttpClient
#' @name sofa-package
#' @aliases sofa
#' @docType package
#' @title R client for CouchDB
#' @author Yaoxiang Li \email{liyaoxiang@@outlook.com}
#' @author Scott Chamberlain \email{myrmecocystus@@gmail.com}
#' @author Eduard Szöcs \email{eduardszoecs@@gmail.com}
#' @keywords package
NULL
