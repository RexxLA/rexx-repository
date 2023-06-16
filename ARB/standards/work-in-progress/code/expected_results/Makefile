all: crexx_expected_results.rexx \
     netrexx_expected_results.nrx \
     oorexx_expected_results.rex \
     regina_expected_results.rex \
     executor_expected_results.rex

crexx_expected_results.rexx: expected_results.rex do_not_edit.txt
	cpp -E -C -P -DCREXX expected_results.rex > crexx_expected_results.rexx

netrexx_expected_results.nrx: expected_results.rex do_not_edit.txt
	cpp -E -C -P -DNETREXX expected_results.rex > netrexx_expected_results.nrx

oorexx_expected_results.rex: expected_results.rex do_not_edit.txt
	cpp -E -C -P -DOOREXX expected_results.rex > oorexx_expected_results.rex

regina_expected_results.rex: expected_results.rex do_not_edit.txt
	cpp -E -C -P -DREGINA expected_results.rex > regina_expected_results.rex

executor_expected_results.rex: expected_results.rex do_not_edit.txt executor_bif_declaration.rex executor_bif_implementation.rex
	cpp -E -C -P -DEXECUTOR expected_results.rex > executor_expected_results.rex


# -C    Do not discard comments
# -E    Only run the preprocessor
# -P    Inhibit generation of linemarkers in the output from the preprocessor
