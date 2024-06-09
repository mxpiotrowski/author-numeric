---
title: "*author-numeric* tests"
csl: csl/ieee.csl
---

# Narrative vs. parenthetical citations

The filter should handle these cases:

| Markdown           | Expected w/ `ieee.csl` | Output           |
|--------------------|------------------------|------------------|
| `@Klaus1966b`      | Klaus [1]              | @Klaus1966b      |
| `@Klaus1966b [12]` | Klaus [1, p. 12]       | @Klaus1966b [12] |

The filter should leave these citations alone:

| Markdown                    | Expected w/ `ieee.csl` | Output                    |
|-----------------------------|------------------------|---------------------------|
| `[@Stork2024]`              | [2]                    | [@Stork2024]              |
| `[@Stork2024, 68–70]`       | [2, pp. 68–70]         | [@Stork2024, 68–70]       |
| `[@Klaus1966b; @Stork2024]` | [1], [2]                 | [@Klaus1966b; @Stork2024] |

# Handling multiple authors

The `default` template conforms to the following widely-used style:

- For items with one or two authors, include both names.
- For items with 3 or more authors, include the first author’s surname and then “et al.”


| _n_ | Expected structure |          Output |
|-----|--------------------|----------------:|
| 1   | A                  |     @Klaus1966b |
| 2   | A `<et>` B         |       @Cope2023 |
| 3+  | A `<etal>`         | @vanZundert2012 |

# Special cases

| What?            | Expected | Output        |
|------------------|----------|---------------|
| Editors only     |          | @McGrail2022  |
| “Literal” author |          | @CIDOC-CRM713 |
| No author/editor |          | @scorm2004.4  |

# cite-field

`[@Klaus1966b]{.title}` should produce *Kybernetik und Erkenntnistheorie*

Result: [@Klaus1966b]{.title}

# References

