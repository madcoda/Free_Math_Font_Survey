
# Makefile for font survey

all: survey.pdf survey.html

EPSPictures=cm.eps cmbright.eps concrete.eps concmath.eps kerkis.eps millennial.eps fourier.eps chartermd.eps garamondmd.eps utopiamd.eps pazo.eps pxfonts.eps mathpple.eps belleek.eps txfonts.eps mathptmx.eps arev.eps kurier.eps iwona.eps anttor.eps antpolt.eps mbtimes.eps fouriernc.eps comicsans.eps
# minionpro.eps gentium.eps 

PDFPictures=$(patsubst %.eps,%.pdf,$(EPSPictures))
survey.pdf: survey.tex $(PDFPictures)
	pdflatex survey
	pdflatex survey

#survey.pdf: survey.ps
#	ps2pdf survey.ps survey.pdf

#survey.ps: survey.dvi
#	-z option is for hyperlinks
#	This doesn't work, causing dvips to cryptically say 'Page xx may be too complex to print'
#	and 'Warning:  no %%Page comments generated.'  The outcome is that only the last page is viewable.
#	dvips -Ppdf -z survey

#survey.dvi: survey.tex $(EPSPictures)
#	latex survey
#	latex survey

#For PracTeX journal:
hartke.tex: survey.tex
	# add PracTEX preamble options: email, address, abstract, license
	# we need \makeatother and \makeatletter around email for the switchemail package used by pracjourn.cls
	# change typewriter font to lmtt and sans serif to lmss for author block titles
 	# change documentclass to pracjourn
	# graphicx is already included by pracjourn class
	sed -e 's/%PracTEXreplacement/\\makeatother\\email{lastname @ gmail .dot. com}\\makeatletter\\address{Department of Mathematics\\\\University of Illinois at Urbana-Champaign\\\\Urbana, IL, 61801 USA}\\abstract{We survey free math fonts for \\TeX\\ and \\LaTeX, with examples, instructions for using \\LaTeX\\ packages for changing fonts, and links to sources for the fonts and packages.}\\license{Copyright \\copyright\\ 2006 Stephen G.\\ Hartke\\\\Permission is granted to distribute verbatim or modified\\\\copies of this document provided this notice remains intact.}\\TPJrevision{2006-02-03}\\TPJissue{TPJ 2006 No 01, 2006-02-15}\\renewcommand\\ttdefault{lmtt}\\renewcommand\\sfdefault{lmss}/g' survey.tex | sed -e 's/\\documentclass\[\(.\)*\]{article}/\\documentclass[english]{pracjourn}/g' | sed -e 's/\\usepackage\[pdftex\]{graphicx}//g'> hartke.tex

hartke.pdf: hartke.tex $(PDFPictures)
	pdflatex hartke
	pdflatex hartke


PNGPictures=$(patsubst %.eps,%.png,$(EPSPictures))
survey.html: survey.tex $(PNGPictures)
#	survey.aux from LaTeX can confuse HeVeA
	rm -f survey.aux
	hevea survey
	hevea survey

clean:
	rm survey.html *.dvi *.eps *.pdf *.png *.aux *.log


# Font sample files

TEXTFRAGMENT=textfragment.tex
SAMPLEFORMAT=sampleformat.tex

# $@ is the name of the matched target
# $< is the name of the matched dependency
# $* is the stem

$(EPSPictures): %.eps: %.dvi
	dvips -o $@ -E $*
# if the papersize option t is present in ~/.dvipsrc, then the -E option will not work
# 	some files, like arev.eps, have too much white space on the left
	./fixepsbbox $@ 90 2


DVIPictures=$(patsubst %.eps,%.dvi,$(EPSPictures))
$(DVIPictures): %.dvi: %.tex $(TEXTFRAGMENT) $(SAMPLEFORMAT)
	latex $*

$(PDFPictures): %.pdf: %.eps
	epstopdf $< -o=$@

RESOLUTION=576
BORDER=25
$(PNGPictures): %.png: %.eps
#	Uses ImageMagick and ghostscript; rescaling antialiases better
	convert -density $(RESOLUTION)x$(RESOLUTION) -antialias -scale 25% -bordercolor white -border $(BORDER)x$(BORDER) $< $@

TEXPictures=$(patsubst %.eps,%.tex,$(EPSPictures))
ArchDir=fontsurvey_$(shell date +%Y-%m-%d-%H-%M-%S)
archive:
	mkdir Archive/$(ArchDir)
	mkdir Archive/$(ArchDir)/fontsurvey
	cp survey.lyx survey.tex hevea.sty Makefile $(TEXPictures) $(TEXTFRAGMENT) $(SAMPLEFORMAT) Archive/$(ArchDir)/fontsurvey
	cd Archive/$(ArchDir); tar cfj $(ArchDir).tar.bz2 fontsurvey

WebPictures=$(patsubst %.eps,%.png,$(EPSPictures))
ReleaseDir=release_$(shell date +%Y-%m-%d-%H-%M-%S)
release:
	mkdir Release/$(ReleaseDir)
	mkdir Release/$(ReleaseDir)/Free_Math_Font_Survey
	mkdir Release/$(ReleaseDir)/Free_Math_Font_Survey/source
	mkdir Release/$(ReleaseDir)/Free_Math_Font_Survey/images
	cp survey.pdf survey.html README Release/$(ReleaseDir)/Free_Math_Font_Survey
	cp survey.lyx survey.tex Makefile fixepsbbox $(TEXPictures) $(TEXTFRAGMENT) $(SAMPLEFORMAT) Release/$(ReleaseDir)/Free_Math_Font_Survey/source
	cp $(WebPictures) Release/$(ReleaseDir)/Free_Math_Font_Survey/images
	cd Release/$(ReleaseDir); tar cfj $(ReleaseDir).tar.bz2 Free_Math_Font_Survey
