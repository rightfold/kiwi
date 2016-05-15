#lang racket
(require
  (only-in kiwi/grep grep)
  (only-in markdown parse-markdown)
  (only-in xml xexpr?)
)

(provide (contract-out (search-pages (-> string? boolean? boolean? boolean?
                                         (listof string?)))))
(define (search-pages query regex invert case)
  (map path->string (grep query regex invert case)))

(provide (contract-out (page-path (-> string? path?))))
(define (page-path page)
  (let* ((base (current-directory))
         (full (build-path base page)))
    ; BUG: check whether full is a subpath of base
    full))

(define (render/markdown page)
  (parse-markdown (page-path page)))

(define (render/pre page)
  `((h1 ,page) (pre (code ,(file->string (page-path page))))))

(provide (contract-out (render-page (-> string? (listof xexpr?)))))
(define (render-page page)
  (case (filename-extension page)
    ((#"md") (render/markdown page))
    (else    (render/pre page))))
