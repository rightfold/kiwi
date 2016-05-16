#lang racket
(require
  (only-in kiwi/page page-path render-page search-pages)
  (only-in net/url path/param-path url-path url-query)
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
  (html req "index.md"))

(define (assoc-or k d xs)
  (match (assoc k xs) (#f d) (p (cdr p))))

(define (search req)
  (let* ((params (url-query (request-uri req)))
         (text-param (λ (k) (or (assoc-or k "" params) "")))
         (bool-param (λ (k) (not (not (assoc-or k #f params)))))
         (query  (text-param 'query))
         (regex  (bool-param 'regex))
         (invert (bool-param 'invert))
         (case   (bool-param 'case))
         (results (search-pages query regex invert case))
         (lis (map (λ (e) `(li (a ((href ,(string-append "/html/" e))) ,e))) results)))
    (response/xexpr (template "search" `((h1 "search") (ul ,@lis))))))

(define (footer page)
  `((p
      (a ((href ,(string-append "/raw/"     page))) "raw") " "
      (a ((href ,(string-append "/history/" page))) "history"))))

(define (html req page)
  (response/xexpr (template page (append (render-page page) (footer page)))))

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
