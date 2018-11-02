# MAKEFILE FILE CHUNKS
######################

# VARIABLE DEFINITIONS
######################

ROOT  := /usr/local/dev/programming/Security
FILE  := Security
SHELL := /bin/bash

# DEFAULT Target
################
.PHONY : TWJR JRTANGLE JRWEAVE TEXI INFO PDF HTML
.PHONY : default twjr jrtangle jrweave weave texi info pdf html
default : INFO PDF HTML

# TWJR TARGETS
##############
TWJR : twjr
twjr : jrtangle jrweave worldclean

lodestone : $(FILE).twjr
	jrtangle $(FILE).twjr
	touch $(FILE).twjr
	touch lodestone;

JRTANGLE : jrtangle
jrtangle : tangle
tangle   : lodestone

JRWEAVE : WEAVE
WEAVE   : jrweave
jrweave : weave
weave   : TEXI
TEXI    : texi
texi    : $(FILE).texi
$(FILE).texi : $(FILE).twjr
	jrweave $(FILE).twjr > $(FILE).texi
	emacs --batch --eval '(progn (find-file "./$(FILE).texi" nil) (texinfo-master-menu 1) (save-buffer 0))'

INFO : info
info : $(FILE).info
$(FILE).info : $(FILE).texi $(FILE).twjr
	makeinfo $(FILE).texi
openinfo : INFO
	open -na EmacsMac --args --eval '(info "($(ROOT)/$(FILE).info)top" "$(FILE).texi")'

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
	@echo clean
	@rm -f *~ .*~ #*#

# remove  all directories;  leave the  source files  @file{TWJR}, @{TEXI},  and
# @file{Makefile}; resources dir
dirclean : clean
	@echo dirclean
	@for file in *; do          \
	  case $$file in           \
	    $(FILE)* | Makefile) ;;\
	    my-bib-macros*)      ;;\
            resources*)	 	 ;;\
	    lodestone)		 ;;\
	    *) rm -vfr $$file	 ;;\
	  esac                     \
	done

# after dirclean, remove HTML directory and PDF files
distclean : dirclean
	@echo distclean
	@rm -vfr $(FILE) $(FILE).pdf

# after distclean, remove INFO and my-bib-macros
worldclean : distclean
	@echo worldclean
	@rm -vfr *.info* my-bib-macros.texi

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

JWT-EXPRESS-SERVER-TARGETS := jwt-auth-demo

.PHONY : jwt-auth-demo
jwt-auth-demo : $(JWT-EXPRESS-SERVER) move-jwt-auth-index.js
$(JWT-EXPRESS-SERVER) :
	mkdir -p $(JWT-EXPRESS-SERVER); \
	cd $(JWT-EXPRESS-SERVER-ROOT);  \
	yarn add $(DEPS);
	  
JWT-AUTH-DEMO-INDEX.JS := jwt-auth-demo-index.js
JWT-AUTH-DEMO-TARGETS +:= jwt-auth-demo-install-index.js

jwt-auth-index.js : $(TWJR)
	jrtangle $(FILE).twjr
	
.PHONY : move-jwt-auth-index.js
move-jwt-auth-index.js : jwt-auth-index.js
	mv -fv jwt-auth-index.js $(JWT-EXPRESS-SERVER)/index.js




