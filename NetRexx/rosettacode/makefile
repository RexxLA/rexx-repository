COMPILE_COMMAND = nrc
COMPILE_OPTIONS =  -sourcedir -time -comments -keep -replace -compact -format -warnexit0 -nocrossref -utf8

NRX_SRC		:= $(wildcard *.nrx)
NRX_OBJS	:= $(NRX_SRC:.nrx=.class)

.nrx.class:
	$(COMPILE_COMMAND) $< $(COMPILE_OPTIONS)
	mv $*.java.keep $*.java


.SUFFIXES: .nrx .nry .njp .class .skel .xsl .java .u

all::	$(NRX_OBJS)

.PHONY: clean
clean: 
	rm -f *.class
	rm -f *.crossref
	find . -name "*.nrx" | awk '{$$2 = $$1 ; sub ( /\.nrx/,".java",$$1 ) ; print $$1 }' | xargs rm -f



