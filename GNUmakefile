.PHONY: clean

BIB       := bib/references.bib
CITEFIELD := -L citefield.lua

%-latex.pdf: %.md filters/*.lua ${BIB} ${CSL}
	pandoc -s -f markdown-implicit_figures -t pdf -o $@ \
	--citeproc --bibliography=${BIB} \
	${CITEFIELD} -L filters/author-numeric.lua \
	--pdf-engine=xelatex $<

%-ms.pdf: %.md filters/*.lua
	pandoc -s -f markdown-implicit_figures -t pdf -o $@ \
	--citeproc --bibliography=${BIB} \
	${CITEFIELD} -L filters/author-numeric.lua \
	--pdf-engine=pdfroff --pdf-engine-opt=-dpaper=a4 \
	--pdf-engine-opt=-U --pdf-engine-opt=-P-pa4 $<

%.tex: %.md filters/*.lua
	pandoc -s -f markdown-implicit_figures -t latex -o $@ \
	--citeproc --bibliography=${BIB} \
	${CITEFIELD} -L filters/author-numeric.lua \
	--pdf-engine=xelatex $<

%.ms: %.md filters/*.lua
	pandoc -s -f markdown-implicit_figures -t ms -o $@ \
	--citeproc --bibliography=${BIB} \
	${CITEFIELD} -L filters/author-numeric.lua \
	--pdf-engine=pdfroff --pdf-engine-opt=-dpaper=a4 \
	--pdf-engine-opt=-U --pdf-engine-opt=-P-pa4 $<

%.html: %.md filters/*.lua
	pandoc -s -f markdown-implicit_figures -t html -o $@ \
	--citeproc --bibliography=${BIB} \
	${CITEFIELD} -L filters/author-numeric.lua $<

clean:
	rm -f *~ test*.pdf test.{tex,ms,html}
