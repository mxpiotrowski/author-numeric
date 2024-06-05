;; -*- lexical-binding: t; -*-

(TeX-add-style-hook
 "references"
 (lambda ()
   (LaTeX-add-bibitems
    "Klaus1966b"
    "Dreyfus1972"
    "Dietrich1990"
    "Stork2024"))
 '(or :bibtex :latex))

