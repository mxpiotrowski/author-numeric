# author-numeric

Pandoc Lua filter for in-text (narrative, author-prominent) citations with numeric CSL styles.

In contrast to author-date styles, with numeric CSL styles, there’s no difference between `@Klaus1966b` and `[@Klaus1966b]`: both produce just something like “[42]”.

CSL currently doesn’t have a notion of in-text citations and it’s therefore impossible to create CSL styles that would produce something like “Klaus [42]” for author-in-text citations.  This makes it hard to switch between author-date and numeric styles: when switching from author-date to numeric, either you have no author names (and thus get something like “As [42] points out…”) or you have to add the author names manually.  But when you diligently add the author names with a numeric style and then switch to author-date, you get something like “As Klaus Klaus (1966) points out…”

It’s also not something that Pandoc could easily do, because CSL styles simply don’t contain the information necessary for formatting in-text citations.  But Pandoc records the type of citation: `NormalCitation` (parenthetical), `AuthorInText`, or `AuthorSuppressed`, so a filter can check for `AuthorInText` and add the author name to turn “[42]” into “Klaus [42].”

## Usage

Add the `author-numeric.lua` filter **after** `citeproc`.  When processing your document, `author-numeric.lua` inserts the names of authors before the normal numeric reference.  So, the exact results depend on your chosen citation style.  For example, for [ieee.csl](https://github.com/citation-style-language/styles/blob/master/ieee.csl):

| Markdown           | Result           |
|--------------------|------------------|
| `@Klaus1966b`      | Klaus [1]        |
| `@Klaus1966b [12]` | Klaus [1, p. 12] |

For a citation style that uses superscript numbers, say, [apa-numeric-superscript.csl](https://github.com/citation-style-language/styles/blob/master/apa-numeric-superscript.csl), you’d get:

| Markdown           | Result                   |
|--------------------|--------------------------|
| `@Klaus1966b`      | Klaus<sup>1</sup>        |
| `@Klaus1966b [12]` | Klaus<sup>1(p. 12)</sup> |

Note `author-numeric.lua` automatically ensures that there is a space before a number in brackets or parenthesis and _no space_ before superscripts.

Otherwise, the formatting of the names is determined by a template.  The `default` template conforms to the following widely-used style:

- For items with one or two authors, include both names.
- For items with 3 or more authors, include the first author’s surname and then “et al.”

| Authors | Structure  | Example                |
|---------|------------|------------------------|
| 1       | A          | Klaus [1]              |
| 2       | A `<et>` B | Cope and Kalantzis [2] |
| 3+      | A `<etal>` | van Zundert et al. [3] |

You can customize the formatting by metadata options.  `author-numeric.lua` expects a key–value list under the `author_numeric` key.  In particular, you can specify the text to use for “and” (key `et`) and “et al.” (key `etal`).  You can select a different predefined template using `use_template` (the only other reasonable choice is currently `default_sc`, which sets author names in small caps).

For example:

``` yaml
author_numeric:
    et: "&"
    etal: "and colleagues"
    use_template: default_sc
```

One of the hardest problems in document processing is whitespace handling.  Pandoc removes leading and trailing whitespace in metadata, so whitespace is handled by the templates.  The default templates assume that the text in `et` is surrounded by spaces and that `etal` is preceded by a space.  Pandoc treats metadata fields as Markdown, so you can also specify formatting; for example, _et al._ is often typeset in italics:

``` yaml
author_numeric:
    etal: "_et al._"
```

These options should be sufficient for most reasonable styles.

You can also specify a full template (in [Pandoc’s template syntax](https://pandoc.org/MANUAL.html#templates)); the result of the template is then interpreted as Markdown.  The variable `names` is predefined and contains the list of the authors’ (or editors’) last names.  For example, the following template would always output only the first author in bold and uppercase:

``` yaml
author_numeric:
    template: "\*\*${names/first/uppercase}\*\*"
```

Note: Pandoc treats metadata values as Markdown, and `author-numeric.lua` uses `stringify()`, which removes markup, you need to escape markup that you want to appear in the final result.  This is obviously not very user-friendly, so this feature should be considered experimental.  In actual practice, it seems unlikely that you need anything beyond the default templates and the `et` and `etal` configuration options above.

## Using `author-numeric.lua` with `citefield.lua`

Make sure that `author-numeric.lua` comes **after** `citefield.lua` (which needs to come after `citeproc`).

There is a conflict when using this filter together with [citefield.lua](https://github.com/bcdavasconcelos/cite-field), because the syntax of a citefield citation, e.g., `[@Klaus1966b]{.title}`, *looks* like a `NormalCitation` with attributes—in fact, it’s a Span containing an `AuthorInText` citation!

Since `author-numeric.lua` manipulates `AuthorInText` citations, it would mangle these citations.  `author-numeric.lua` therefore assumes that if the stringified text of the citation doesn't start with “[”, “(“, or a digit, it's not a numerical citation (but a title, author name, etc.).

-------------------------------------------------------------------------------

© 2024 by Michael Piotrowski <mxp@dynalabs.de>

