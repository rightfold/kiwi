#lang racket
(define grep-path (find-executable-path "grep"))

(define (grep-args query regex invert case)
  (append (if invert '("-L") '("-l"))
          (if case   '()     '("-i"))
          (if regex  '("-E") '("-F"))
          (list query)
          '("-r" ".")))

(provide (contract-out (grep (-> string? boolean? boolean? boolean?
                                 (listof path?)))))
(define (grep query regex invert case)
  (let* ((args (grep-args query regex invert case))
         (go   (λ () (apply system* grep-path args #:set-pwd? #t)))
         (raw  (with-output-to-string go))
         (rawl (string-split raw "\n")))
    (map string->path rawl)))
