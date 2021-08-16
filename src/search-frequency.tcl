# - how low does accuracy for base vocab go?
# - 10% is good, 75% is too high

set random_seed $::env(PMSP_RANDOM_SEED)
puts "Random seed: $random_seed"
set dilution_amount $::env(PMSP_DILUTION)
puts "Dilution amount: $dilution_amount"
set partition_id $::env(PMSP_PARTITION)
puts "Partition ID: $partition_id"
set freq $::env(PMSP_FREQ)
puts "Frequency: $freq"

# reproducible
seed $random_seed

set script_name "cogsci-recurrent-dt-100-dilution-$dilution_amount-seed-$random_seed-partition-$partition_id-straight-through"

# all relative to tcl file
set root_path "../"
set weights_path "${root_path}/var/${script_name}/weights"
set results_path "${root_path}/var/${script_name}/results"
set examples_path "${root_path}/examples"

set output_file "$results_path/search-frequency.tsv"
# file delete $output_file

source ./network.tcl
source ./parameters.tcl

###
# Sweep frequency parameter space

# set freqs [ list 0.00001 0.0001 0.001 0.01 0.1 1 10 100 1000 10000 100000 ]

set example_test_file "${examples_path}/pmsp/pmsp-train-the-normalized.ex"
loadExamples $example_test_file -s "vocab_pmsp"
exampleSetMode "vocab_pmsp" PERMUTED
useTestingSet "vocab_pmsp"

# test.group.crit 0.5, will test at group level, will pass criterion if all units on corrct side of 0.5
# setObj test.group.crit 0.5

set example_file "${root_path}/examples/frequency-search/freq-$freq-partition-$partition_id-dilution-$dilution_amount.ex"
loadExamples $example_file -s "vocab_anchors"
exampleSetMode "vocab_anchors" PERMUTED
useTrainingSet "vocab_anchors"

setObj vocab_anchors.minTime 2.0
setObj vocab_anchors.maxTime 2.0
setObj vocab_anchors.graceTime 1.0

# resume training at the end of the PMSP, before anchor introduction
loadWeights "${weights_path}/1999.wt.gz"

for { set epoch_idx 1999} {$epoch_idx <= 2300} {incr epoch_idx} {
    train 1

    # at each epoch, run test on base vocabulary corpus, -return arg to test command? instead of printing, it returns an object; test_result.percent_corret or test_result.error; will be the percent correct of base vocabulary; just keep minimum results across this sweep, save minimum and key it according to dilution level and scaling frequency for language
    test

    puts $Test(percentCorrect)

    set f [open $output_file "a"]
    puts $f "$freq\t$epoch_idx\t$Test(percentCorrect)"
    close $f

}

exit
