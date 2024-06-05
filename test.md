# author-numeric

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
| `[@Klaus1966b; @Stork2024]` | [1; 2]                 | [@Klaus1966b; @Stork2024] |
|                             |                        |                           |

## cite-field

`[@Klaus1966b]{.title}` should produce *Kybernetik und Erkenntnistheorie*

[@Klaus1966b]{.title}

# References
