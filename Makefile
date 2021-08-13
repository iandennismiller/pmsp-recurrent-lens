DATESTAMP=$(shell date +'%Y-%m-%d')

archive:
	rm -f ./var/$(DATESTAMP)-activations.tgz
	tar cfz ./var/$(DATESTAMP)-activations.tgz var/*/results/*.txt

pull-armstronglab:
	rsync -az idm@armstronglab.utsc.utoronto.ca:Work/pmsp-recurrent-lens/var/ ./var/
