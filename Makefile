MAIN ?= main
DIFF ?= HEAD^
DEPS := rev.tex abstract.txt

OUTDIR ?= latex.out
LATEXMK ?= latexmk
LATEXMK_OPTS ?= -pdf
LATEXMK_ENV := TEXINPUTS="sty:"
LATEXMK_CMD := $(LATEXMK_ENV) $(LATEXMK) $(LATEXMK_OPTS)

SHELL:= $(shell echo $$SHELL)

all: $(DEPS) ## generate a pdf
	@$(LATEXMK_CMD) $(MAIN).tex

submit: $(DEPS) ## proposal function
	@for f in $(wildcard submit-*.tex); do \
		$(LATEXMK_CMD) $$f; \
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
	@$(LATEXMK_CMD) $(MAIN).tex

watermark: $(DEPS) ## generate pdf with a watermark
	echo -e '\\usepackage[firstpage]{draftwatermark}' >> rev.tex
	@$(LATEXMK_CMD) $(MAIN).tex

bib: all ## print bib used in the paper
	bibexport $(OUTDIR)/$(MAIN).aux

clean: ## clean up
	@$(LATEXMK_ENV) $(LATEXMK) -c $(MAIN).tex
	@rm -rf $(OUTDIR)
	rm -f abstract.txt
	rm -f $(MAIN).synctex.gz

abstract.txt: abstract.tex $(MAIN).tex ## generate abstract.txt
	@bin/mkabstract $(MAIN).tex $< | fmt -w72 > $@

.PHONY: all help FORCE draft clean spell distclean init bib
