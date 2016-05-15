#lang racket
(provide (contract-out (page-path (-> string? path?))))
(define (page-path page)
  (let* ((base (build-path (current-directory) "doc"))
         (full (build-path base page)))
    ; BUG: check whether full is a subpath of base
    full))
