# MAKEFILE FILE CHUNKS
######################

# VARIABLE DEFINITIONS
######################

FILE  := Security
SHELL := /bin/bash

# DEFAULT Target
################
.PHONY : TWJR TANGLE WEAVE TEXI INFO PDF HTML
.PHONY : default twjr tangle weave texi info pdf html
default : INFO PDF HTML

# TWJR TARGETS
##############
TWJR : twjr
twjr : tangle weave worldclean

TANGLE : tangle
tangle : $(FILE).twjr
	jrtangle $(FILE).twjr

WEAVE : weave
weave : TEXI
TEXI  : texi
texi  : $(FILE).texi
$(FILE).texi : $(FILE).twjr
	jrweave $(FILE).twjr > $(FILE).texi

INFO : info
info : $(FILE).info
$(FILE).info : $(FILE).texi
	makeinfo $(FILE).texi
openinfo : INFO
	emacs $(FILE).info

PDF : pdf
pdf : $(FILE).pdf
$(FILE).pdf : $(FILE).texi
	pdftexi2dvi --build=tidy --build-dir=build --quiet $(FILE).texi
openpdf : PDF
	open $(FILE).pdf

HTML : html
html : $(FILE)/index.html
$(FILE)/index.html : $(FILE).texi
	makeinfo --html $(FILE).texi
openhtml : HTML
	open $(FILE)/index.html

.PHONY : clean dirclean distclean worldclean

# remove backup files
clean :
	rm -f *~ .*~ #*#

# remove  all directories;  leave the  source files  @file{TWJR}, @{TEXI},  and
# @file{Makefile}; resources dir
dirclean : clean
	for file in *; do          \
	  case $$file in           \
	    $(FILE)* | Makefile) ;;\
	    my-bib-macros*)      ;;\
            resources*)	 	 ;;\
	    *) rm -vfr $$file	 ;;\
	  esac                     \
	done

# after dirclean, remove HTML directory and PDF files
distclean : dirclean
	rm -vfr $(FILE) $(FILE).pdf

# after distclean, remove INFO and my-bib-macros
worldclean : distclean
	rm -rfv *.info* my-bib-macros.texi

# BIB MACROS EXAMPLE TARGET
# #########################
.PHONY : bibmacros bibexample
bibmacros : bibmacros.texi
bibmacros.texi : twjr
bibexample : bibmacros.texi
	makeinfo my-file-with-bib.texi

# JWT EXPRESS SERVER
# ##################

PWD := $$PWD
JWT-EXPRESS-SERVER-ROOT := $(PWD)/JWT-Auth-Demo
JWT-AUTH-SERVER := jwt-auth-server
JWT-EXPRESS-SERVER := $(JWT-EXPRESS-SERVER-ROOT)/$(JWT-AUTH-SERVER)

DEPS := express jsonwebtoken cors express-jwt

.PHONY : jwt-auth-demo
jwt-auth-demo : $(JWT-EXPRESS-SERVER) move-jwt-auth-index.js
$(JWT-EXPRESS-SERVER) :
	mkdir -p $(JWT-EXPRESS-SERVER); \
	cd $(JWT-EXPRESS-SERVER-ROOT);  \
	yarn add $(DEPS)
	  
jwt-auth-index.js : $(FILE).twjr
	jrtangle $(FILE).twjr

.PHONY : move-jwt-auth-index.js
move-jwt-auth-index.js : jwt-auth-index.js
	mv -fv jwt-auth-index.js $(JWT-EXPRESS-SERVER)/index.js




