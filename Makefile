# include .settings.mk

DATESTAMP=$(shell date +'%Y-%m-%d')

archive:
	rm -f ./var/$(DATESTAMP)-activations.tgz
	tar cfz ./var/$(DATESTAMP)-activations.tgz var/*/results/*.txt

pull-var:
	rsync -az $(SSH_AUTH):Work/pmsp-recurrent-lens/var/ ./var/

push-src:
	rsync -az ./src/ $(SSH_AUTH):Work/pmsp-recurrent-lens/src/
	rsync -az ./examples/ $(SSH_AUTH):Work/pmsp-recurrent-lens/examples/
	rsync -az ./bin/ $(SSH_AUTH):Work/pmsp-recurrent-lens/bin/

examples:
	bin/create-for-partition.sh 0
	bin/create-for-partition.sh 1
	bin/create-for-partition.sh 2
	SETTINGS=~/.dilution-deadline-study.ini \
		bin/create-example-file.py create_probes --frequency 1.0 > \
		examples/probes-new-2021-08-04.ex

grace-time:
	PMSP_RANDOM_SEED=1 \
        PMSP_DILUTION=3 \
        PMSP_PARTITION=0 \
        ./bin/alens-batch.sh \
        ./src/check-grace-time.tcl

start-lens:
	docker run -d --rm \
		--name lens \
		-p 5901:5901 \
		-v $(PWD):/home/lens/Work/pmsp-recurrent-lens \
		iandennismiller/lens

stop-lens:
	docker container stop lens

run-train-cogsci:
	docker exec lens sudo -u lens /bin/bash -c '\
		cd /home/lens/Work/pmsp-recurrent-lens && \
		PMSP_RANDOM_SEED=1 \
		PMSP_DILUTION=0 \
		PMSP_PARTITION=0 \
		./bin/alens-batch.sh \
			./src/train-pmsp-cogsci.tcl'
