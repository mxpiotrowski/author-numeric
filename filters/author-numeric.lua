--[[ Quick and dirty filter to output the author name for
   author-in-text citations with numeric CSL styles.  ]]

local references

function Pandoc (doc)
  references = pandoc.utils.references(doc)
  return nil
end

function Cite (el)
   local cite_id = el.citations[1].id
   local ref = references:find_if( -- get reference corresponding to citation
      function (r) return cite_id == r.id end)
   local author = ''
   local authors = {}

   if el.citations[1].mode ~= 'AuthorInText' then
      return nil
   end

   -- Workaround for use with citefield.lua: [@Klaus1966b]{.title}
   -- *looks* like a NormalCitation with attributes, but actually this
   -- is a Span containing an AuthorInText citation!  We can't easily
   -- check for the parent, so we assume that if the text of the
   -- citation doesn't start with “[”, it's not a numerical citation
   -- (but a title, author name, etc.).
   if pandoc.utils.stringify(el.content):sub(1, 1) ~= '[' then
      return nil
   end

   if #el.citations > 1 then -- this can't really happen
      return nil
   end

   -- Get authors
   for n = 1, #ref.author do
      local prefix = ref.author[n]['non-dropping-particle'] or nil
      if prefix then prefix = prefix .. ' ' end
      author = (prefix or '') .. ref.author[n].family
      table.insert(authors, author)
   end

   if #ref.author == 2 then
      author = table.concat(authors, ' and ')
   else
      author = authors[1]
   end

   if #ref.author > 2 then
      author = author .. ' et al.'
   end

   local sep = ' '
   if FORMAT:match 'latex' then
      sep = pandoc.RawInline('latex', '\\ ') -- ensure interword space
   end
   
   return {
      -- pandoc.Code(pandoc.utils.stringify(ref.id)), -- [DEBUG]
      -- pandoc.Code(pandoc.utils.stringify(el.content)), -- [DEBUG]
      -- '◊', -- [DEBUG]
      author, sep, el
   }
end

return {
   { Pandoc = Pandoc },
   { Cite = Cite }
}
