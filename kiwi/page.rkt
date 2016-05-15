#lang racket
(provide (contract-out (page-path (-> string? path?))))
(define (page-path page)
  (let* ((base (current-directory))
         (full (build-path base page)))
    (print full (current-error-port))
    ; BUG: check whether full is a subpath of base
    full))
