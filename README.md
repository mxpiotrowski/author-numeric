# author-numeric

Quick and dirty Pandoc Lua filter to output the author name for author-in-text citations with numeric CSL styles.

In contrast to author-date styles, with numeric CSL styles, there’s no difference between `@Klaus1966b` and `[@Klaus1966b]`: both produce just something like “[42]”.

This makes it hard to switch between autor-date and numeric styles: when switching from author-date to numeric, either you have no author names (and thus get something like “As [42] points out…”) or you have to add the author names manually.  But when you diligently add the author names with a numeric style and then switch to author-date, you get something like “As Klaus Klaus (1966) points out…”

It is apparently impossible to create CSL styles that would produce “Klaus [42]” for author-in-text citations.

Luckily, Pandoc records the type of citation: `NormalCitation` (parenthetical), `AuthorInText`, or `AuthorSuppressed`, so we can check for `AuthorInText` and add the author name to turn “[42]” into “Klaus [42].”

## cite-field

There is a problem when using this filter together with [cite-field](https://github.com/bcdavasconcelos/cite-field), because the syntax of a cite-field citation, e.g., `[@Klaus1966b]{.title}`, *looks* like a `NormalCitation` with attributes—in fact, this is a Span containing an `AuthorInText` citation!

Since we can't easily check for the parent, we assume that if the text of the citation doesn't start with “[”, it's not a numerical citation (but a title, author name, etc.).  This means that the filter would have to be modified when used with a numeric style that uses parentheses.

-------------------------------------------------------------------------------

© 2024 by Michael Piotrowski <mxp@dynalabs.de>

