CPP_OPTIONS = -E -C -P -Ihelpers
# -C    Do not discard comments
# -E    Only run the preprocessor
# -P    Inhibit generation of linemarkers in the output from the preprocessor


help:
	@echo Usage:
	@echo make scripts
	@echo make crexx_results
	@echo make netrexx_results
	@echo make oorexx_results
	@echo make regina_results
	@echo make executor_results
	@echo make clean
	@echo make clean_crexx
	@echo make clean_netrexx
	@echo make clean_oorexx
	@echo make clean_regina
	@echo make clean_executor

scripts: \
        generated \
        generated/crexx_expected_results.rexx \
        generated/netrexx_expected_results.nrx \
        generated/oorexx_expected_results.rex \
        generated/regina_expected_results.rex \
        generated/executor_expected_results.rex


#########
# CREXX #
#########

generated/crexx_expected_results.rexx: \
        expected_results.rex \
        helpers/do_not_edit.txt \
        helpers/check_interpreter.rex
	cpp -DCREXX $(CPP_OPTIONS) expected_results.rex > generated/crexx_expected_results.rexx

crexx_results: \
        generated/results \
        generated/results/crexx_results.txt

generated/results/crexx_results.txt: \
        generated/crexx_expected_results.rexx
	cd generated && \
	rxc crexx_expected_results && \
	rxas crexx_expected_results && \
	rm -f results/crexx_results.txt && \
	rxvm crexx_expected_results > results/crexx_results.tmp.txt && \
	mv -f results/crexx_results.tmp.txt results/crexx_results.txt

clean:: clean_crexx

clean_crexx:
	rm -f generated/crexx_expected_results.rexx
	rm -f generated/crexx_expected_results.rxas
	rm -f generated/crexx_expected_results.rxbin
	rm -f generated/results/crexx_results.tmp.txt
	rm -f generated/results/crexx_results.txt


###########
# NETREXX #
###########

generated/netrexx_expected_results.nrx: \
        expected_results.rex \
        helpers/do_not_edit.txt \
        helpers/check_interpreter.rex
	cpp -DNETREXX $(CPP_OPTIONS) expected_results.rex > generated/netrexx_expected_results.nrx

netrexx_results: \
        generated/results \
        generated/results/netrexx_results.txt

generated/results/netrexx_results.txt: \
        generated/netrexx_expected_results.nrx
	cd generated && \
	nrc netrexx_expected_results.nrx && \
	rm -f results/netrexx_results.txt && \
	java netrexx_expected_results > results/netrexx_results.tmp.txt && \
	mv -f results/netrexx_results.tmp.txt results/netrexx_results.txt

clean:: clean_netrexx

clean_netrexx:
	rm -f generated/netrexx_expected_results.nrx
	rm -f generated/netrexx_expected_results.class
	rm -f generated/results/netrexx_results.tmp.txt
	rm -f generated/results/netrexx_results.txt


##########
# OOREXX #
##########

generated/oorexx_expected_results.rex: \
        expected_results.rex \
        helpers/do_not_edit.txt \
        helpers/check_interpreter.rex
	cpp -DOOREXX $(CPP_OPTIONS) expected_results.rex > generated/oorexx_expected_results.rex

oorexx_results: \
        generated/results \
        generated/results/oorexx_results.txt

generated/results/oorexx_results.txt: \
        generated/oorexx_expected_results.rex
	cd generated && \
	rm -f results/oorexx_results.txt && \
	rexx oorexx_expected_results.rex > results/oorexx_results.tmp.txt && \
	mv -f results/oorexx_results.tmp.txt results/oorexx_results.txt

clean:: clean_oorexx

clean_oorexx:
	rm -f generated/oorexx_expected_results.rex
	rm -f generated/results/oorexx_results.tmp.txt
	rm -f generated/results/oorexx_results.txt


##########
# REGINA #
##########

generated/regina_expected_results.rex: \
        expected_results.rex \
        helpers/do_not_edit.txt \
        helpers/check_interpreter.rex
	cpp -DREGINA $(CPP_OPTIONS) expected_results.rex > generated/regina_expected_results.rex

regina_results: \
        generated/results \
        generated/results/regina_results.txt

generated/results/regina_results.txt: \
        generated/regina_expected_results.rex
	cd generated && \
	rm -f results/regina_results.txt && \
	rexx regina_expected_results.rex > results/regina_results.tmp.txt && \
	mv -f results/regina_results.tmp.txt results/regina_results.txt

clean:: clean_regina

clean_regina:
	rm -f generated/regina_expected_results.rex
	rm -f generated/results/regina_results.tmp.txt
	rm -f generated/results/regina_results.txt


############
# EXECUTOR #
############

generated/executor_expected_results.rex: \
        expected_results.rex \
        helpers/do_not_edit.txt \
        helpers/check_interpreter.rex \
        helpers/executor_bif_declaration.rex \
        helpers/executor_bif_implementation.rex
	cpp -DEXECUTOR $(CPP_OPTIONS) expected_results.rex > generated/executor_expected_results.rex

executor_results: \
        generated/results \
        generated/results/executor_results.txt

generated/results/executor_results.txt: \
        generated/executor_expected_results.rex
	cd generated && \
	rm -f results/executor_results.txt && \
	rexx executor_expected_results.rex > results/executor_results.tmp.txt && \
	mv -f results/executor_results.tmp.txt results/executor_results.txt

clean:: clean_executor

clean_executor:
	rm -f generated/executor_expected_results.rex
	rm -f generated/results/executor_results.tmp.txt
	rm -f generated/results/executor_results.txt


###############
# Directories #
###############

generated:
	mkdir generated

generated/results:
	cd generated && \
	mkdir results
