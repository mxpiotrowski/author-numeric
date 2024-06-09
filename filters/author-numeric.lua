--[[
   author-numeric – A Pandoc filter for in-text (narrative) citations with numeric CSL styles

   Copyright © 2024 by Michael Piotrowski
   License: MIT.  See LICENSE file for details.
]]

local references
local template

local templates = {
   -- Max. two names, otherwise first name + et al.
   default = [[$~$
${names/first}${if(names/rest/rest)} ${etal}
${elseif(names/rest)} ${et} ${names/rest/first}${endif}
$~$]],

  -- Like default, but names are set in small caps
  default_sc = [[$~$[${names/first}]{.smallcaps}${if(names/rest/rest)} ${etal}
${elseif(names/rest)} ${et} [${names/rest/first}]{.smallcaps}${endif}$~$]],

  -- Like default, but names are set in small caps and et al. in italics
  fancy = [[$~$[${names/first}]{.smallcaps}${if(names/rest/rest)} _${etal}_
${elseif(names/rest)} ${et} [${names/rest/first}]{.smallcaps}${endif}$~$]],

  -- Max one name, otherwise first name + et al.
  short = [[$~$${for(names/first)}${it}${endfor}${if(names/rest)}${etal}${endif}$~$]],

  -- All names
  all_names = [[$~$
${names/first}${if(names/rest)}${if(names/rest/allbutlast)}${listsep}${endif}
${for(names/rest/allbutlast)}${it}${sep}${listsep}${endfor}${if(names/rest/allbutlast)}
${if(oxford)}${listsep}${endif}${endif}
${for(names/last)} ${et} ${it}${endfor}
${endif}
$~$]],
}

local options = { et      = 'and',    -- default values
                  etal    = 'et al.',
                  listsep = ', ',
                  oxford  = true,
}

function Pandoc (doc)
   references = pandoc.utils.references(doc)
   -- print(doc.meta.author_numeric.et) -- [DEBUG]
   
   if doc.meta.author_numeric then
      for k, v in pairs(doc.meta.author_numeric) do
         if pandoc.utils.type(v) == 'boolean' then
            options[k] = v
         elseif k == 'use_template' then
            if templates[pandoc.utils.stringify(v)] then
               template = pandoc.template.compile(templates[pandoc.utils.stringify(v)])
            else
               warn('no template with name ' .. pandoc.utils.stringify(v)
                    .. ', using default template.')
            end
         elseif k == 'template' then
            -- print("template: " .. pandoc.utils.stringify(v)) -- [DEBUG]
            template = pandoc.template.compile(pandoc.utils.stringify(v))
         else
            local tmpdoc = pandoc.Pandoc( { pandoc.Plain(v) } )
            options[k] = pandoc.write(tmpdoc, 'markdown')
         end
      end
   end

   if not template then
      template = pandoc.template.compile(templates.default)
   end
   
   return nil
end

function Cite (el)
   local cite_id = el.citations[1].id
   local ref = references:find_if( -- get reference corresponding to citation
      function (r) return cite_id == r.id end)
   local names = {}
   local name_source
   local author = ''

   if el.citations[1].mode ~= 'AuthorInText' then
      return nil
   end

   -- print("Here “" .. pandoc.utils.stringify(el.content) .. "”") -- [DEBUG]
   
   -- Workaround for use with citefield.lua: [@Klaus1966b]{.title}
   -- *looks* like a NormalCitation with attributes, but actually it's
   -- is a Span containing an AuthorInText citation!  We assume that
   -- numerical citations start with a bracket, parenthesis, or digit.
   if not pandoc.utils.stringify(el.content):match('^[%s ]*[[(1-9]') then
      return nil
   end

   if #el.citations > 1 then -- this can't really happen
      return nil
   end

   -- Get the last names of authors or editors
   if ref.author then
      name_source = ref.author
   elseif ref.editor then
      name_source = ref.editor
   else
      name_source = { { literal = "**NO AUTHOR OR EDITOR**" } }
   end

   for n = 1, #name_source do
      local prefix = name_source[n]['non-dropping-particle'] or nil
      if prefix then prefix = prefix .. ' ' end
      name = (prefix or '') .. (name_source[n].family or name_source[n].literal)
      table.insert(names, name)
   end
      
   -- Apply the template
   local context = { names = names,
                     cite = pandoc.utils.stringify(el.c),
                     type = ref.type,
                     raw_authors = ref.author,
                     raw_editors = ref.editor,
                     foo = '*foo*', }

   for k, v in pairs(options) do
      context[k] = v
   end
   
   local result = pandoc.template.apply(template, context)

   -- print(result:render()) -- [DEBUG]
   
   -- Parse the result of the template application as Markdown
   local parsed = pandoc.read(result:render(), 'markdown')
   local fragment = parsed.blocks[1].content

   -- Pandoc removes the space before the citation for superscript styles
   if el.c[1].t == 'Superscript' then
      fragment:insert(1, pandoc.Space())
   else
      -- append a no-break space after the name(s) unless there's already a space or a NBSP
      -- print(el.c) -- [DEBUG]
      if not pandoc.utils.stringify(el.content):match('^[%s ]') then
         fragment:insert(' ')
      end
   end

   fragment:insert(el) -- append the original parenthetical reference (e.g., "[1]")

   return fragment
end

return {
   { Pandoc = Pandoc },
   { Cite = Cite }
}
