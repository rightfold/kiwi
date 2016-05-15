#lang racket
(require
  (only-in kiwi/page page-path render-page)
  (only-in net/url path/param-path url-path)
  (only-in web-server/http request-uri)
  (only-in web-server/http/response-structs response/output)
  (only-in web-server/http/xexpr response/xexpr)
)

(define (template title body)
  `(html
    (head
      (meta ((charset "utf-8")))
      (title ,(string-append title " — kiwi"))
      (link ((rel "stylesheet") (href "/raw/style.css")))
    )
    (body
      (header ((class "-sidebar"))
        ,@(render-page "sidebar.md"))
      (article ((class "-content"))
        ,@body))))

(define (home req)
  (response/xexpr (template "home" (render-page "index.md"))))

(define (search req)
  (response/xexpr (template "search" '("hello"))))

(define (html req page)
  (response/xexpr (template page (render-page page))))

(define (raw req page)
  (let ((i (open-input-file (page-path page))))
    (response/output
      (λ (o) (copy-port i o))
      #:mime-type #"text/plain")))

(provide servlet)
(define (servlet req)
  (match (map path/param-path (url-path (request-uri req)))
    ((list "")            (home req))
    ((list "search")      (search req))
    ((list-rest "html" p) (html req (string-join p "/")))
    ((list-rest "raw"  p) (raw  req (string-join p "/")))
  )
)
