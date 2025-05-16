MAIN ?= main
DIFF ?= HEAD^
DEPS := rev.tex abstract.txt
LTEX := --latex-args="-synctex=1 -shell-escape"
BTEX := --bibtex-args="-min-crossrefs=99"
SHELL:= $(shell echo $$SHELL)

all: $(DEPS) ## generate a pdf
	@TEXINPUTS="sty:" bin/latexrun $(LTEX) $(BTEX) $(MAIN)
	cp latex.out/$(MAIN).synctex.gz .

submit: $(DEPS) ## proposal function
	@for f in $(wildcard submit-*.tex); do \
		TEXINPUTS="sty:" bin/latexrun $$f; \
	done

diff: $(DEPS) ## generate diff-highlighed pdf
	@bin/diff.sh $(DIFF)

help: ## print help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'

rev.tex: FORCE
	@printf '\\gdef\\therev{%s}\n\\gdef\\thedate{%s}\n' \
	   "$(shell git rev-parse --short HEAD)"            \
	   "$(shell git log -1 --format='%ci' HEAD)" > $@

draft: $(DEPS) ## generate pdf with a draft info
	echo -e '\\newcommand*{\\DRAFT}{}' >> rev.tex
	@TEXINPUTS="sty:" bin/latexrun $(BTEX) $(MAIN)

watermark: $(DEPS) ## generate pdf with a watermark
	echo -e '\\usepackage[firstpage]{draftwatermark}' >> rev.tex
	@TEXINPUTS="sty:" bin/latexrun $(BTEX) $(MAIN)

spell: ## run a spell check
	@for i in *.tex figures/*.tex; do bin/aspell.sh tex $$i; done
	@for i in *.tex; do bin/double.pl $$i; done
	@for i in *.tex; do bin/abbrv.pl  $$i; done
	@bin/hyphens.sh *.tex
	@pdftotext $(MAIN).pdf /dev/stdout | grep '??'

bib: all ## print bib used in the paper
	bibexport latex.out/$(MAIN).aux

clean: ## clean up
	@bin/latexrun --clean
	rm -f abstract.txt
	rm -f $(MAIN).synctex.gz

abstract.txt: abstract.tex $(MAIN).tex ## generate abstract.txt
	@bin/mkabstract $(MAIN).tex $< | fmt -w72 > $@

.PHONY: all help FORCE draft clean spell distclean init bib
