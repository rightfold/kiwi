#lang racket
(require
  (only-in net/url path/param-path url-path)
  (only-in web-server/http request-uri)
  (only-in web-server/http/response-structs response/output)
  (only-in web-server/http/xexpr response/xexpr)
)

(define (render-page title body)
  `(html
    (head
      (meta ((charset "utf-8")))
      (title ,(string-append title " — kiwi"))
      (link ((rel "stylesheet") (href "/raw/style.css")))
    )
    (body
      (header ((class "kiwi-sidebar"))
        (a ((href "/")) "kiwi")
      )
      (article ((class "kiwi-content"))
        (h1 ,title)
        ,@body
      )
    )
  )
)

(define (page-path page)
  (let* ((base (build-path (current-directory) "doc"))
         (full (build-path base page)))
    ; BUG: check whether full is a subpath of base
    full))

(define (home req)
  (response/xexpr (render-page "home" (list))))

(define (html req page)
  (response/xexpr (render-page "html" (list page))))

(define (raw req page)
  (response/output
    (λ (o) (copy-port (open-input-file (page-path page)) o))
    #:mime-type #"text/plain"))

(provide servlet)
(define (servlet req)
  (match (map path/param-path (url-path (request-uri req)))
    ((list "")            (home req))
    ((list-rest "html" p) (html req (string-join p "/")))
    ((list-rest "raw"  p) (raw  req (string-join p "/")))
  )
)
