# - how low does accuracy for base vocab go?
# - 10% is good, 75% is too high

set random_seed $::env(PMSP_RANDOM_SEED)
puts "Random seed: $random_seed"
set dilution_amount $::env(PMSP_DILUTION)
puts "Dilution amount: $dilution_amount"
set partition_id $::env(PMSP_PARTITION)
puts "Partition ID: $partition_id"

# reproducible
seed $random_seed

set script_name "cogsci-recurrent-dt-100-dilution-$dilution_amount-seed-$random_seed-partition-$partition_id-straight-through"

# all relative to tcl file
set root_path "../"
set weights_path "${root_path}/var/${script_name}/weights"
set results_path "${root_path}/var/${script_name}/results"
set examples_path "${root_path}/examples"

source ./network.tcl
source ./parameters.tcl

###
# Sweep frequency parameter space

# set example_test_file "${examples_path}/pmsp/pmsp-train-the-normalized.ex"
# loadExamples $example_test_file -s "vocab_pmsp"
# exampleSetMode "vocab_pmsp" PERMUTED
# useTestingSet "vocab_pmsp"


set example_file "${examples_path}/cogsci/cogsci-pmsp-added-partition-$partition_id-dilution-${dilution_amount}.ex"
loadExamples $example_file -s "vocab_anchors"
exampleSetMode "vocab_anchors" PERMUTED
useTrainingSet "vocab_anchors"

setObj testGroupCrit 0.5
setObj trainGroupCrit 0.5

setObj vocab_anchors.minTime 2.0
setObj vocab_anchors.maxTime 2.0
# when vocab_anchors.graceTime is 1.991 there's 0 error

foreach {grace_time_iter} [ list 1.0 1.899 1.990 1.991 ] {
    puts "setObj vocab_anchors.graceTime $grace_time_iter"
    setObj vocab_anchors.graceTime $grace_time_iter
    loadWeights "${weights_path}/1999.wt.gz"
    train 1
    test
    puts "Test(percentCorrect): $Test(percentCorrect)"
}

exit
