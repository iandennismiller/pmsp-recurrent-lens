# pmsp-lens
# Ian Dennis Miller
# 2021-03-08

####
# Timeline
# - epoch 0
#   - targetRadius = 0.1 ("output units are trained to targets of 0.1 and 0.9")
#   - learning rate = 0.05 ("the global learning rate ... was increased from 0.001 to 0.05")
#   - weight decay = 0.0 ("the slight tendency for weights to decay towards zero was removed)
#   - delta-bar-delta ("adaptive connection-specific rates")
#   - momentum = 0.9
#   - time intervals = 2 ("the network is run for 2.0 units of time")
#   - ticks per interval: dt = 5 ("the network was trained using a discretization _d_ = 0.2")
#  - "units update their states 10 times (2.0/0.2) in the forward pass"
# - epoch 200
#   - momentum = 0.98
# - epoch 1800
#   - dt = 20 ("... _d_ was reduced from 0.2 to 0.05")
# - epoch 1850
#   - dt = 100 ("... reduced further to 0.01")
# - epoch 1900
#   - exit

set random_seed $::env(PMSP_RANDOM_SEED)
puts "Random seed: $random_seed"
set dilution_amount $::env(PMSP_DILUTION)
puts "Dilution amount: $dilution_amount"
set partition_id $::env(PMSP_PARTITION)
puts "Partition ID: $partition_id"

# reproducible
seed $random_seed

# unique name of this script, for naming saved weights
set script_name "cogsci-recurrent-dt-100-dilution-$dilution_amount-seed-$random_seed-partition-$partition_id-straight-through"

# root of project is relative to this .tcl file
set root_path "../"

set examples_path "${root_path}/examples"

set weights_path "${root_path}/var/${script_name}/weights"
set results_path "${root_path}/var/${script_name}/results"

file mkdir $results_path
file mkdir $weights_path

source ./network.tcl
source ./parameters.tcl

# this routine will save weights to the proper path
proc save_weights_hook {} {
    global weights_path
    set epoch [ getObj totalUpdates ]
    saveWeights "${weights_path}/${epoch}.wt.gz"
}
setObj postEpochProc { save_weights_hook }

# Log accuracy throughout training
# source "accuracy.tcl"
# set loggingInterval 1
# setObj postExampleProc { logAccuracyHook }

###
# Examples

# NB: "error is injected only for the second unit of time; units receive no direct pressure to be correct for the first unit of time (although back-propagated internal error causes weight changes that encourage units to move towards the appropriate states as early as possible"
# this prevents error from being computed until after the graceTime has passed.

set pmsp_example_file "${examples_path}/pmsp/pmsp-train-the-normalized.ex"

loadExamples $pmsp_example_file -s "vocab_pmsp"
exampleSetMode "vocab_pmsp" PERMUTED
setObj vocab_pmsp.minTime 2.0
setObj vocab_pmsp.maxTime 2.0
setObj vocab_pmsp.graceTime 1.0

set cogsci_example_file "${examples_path}/cogsci/cogsci-pmsp-added-partition-$partition_id-dilution-${dilution_amount}.ex"

loadExamples $cogsci_example_file -s "vocab_cogsci"
exampleSetMode "vocab_cogsci" PERMUTED
setObj vocab_cogsci.minTime 2.0
setObj vocab_cogsci.maxTime 2.0
setObj vocab_cogsci.graceTime 1.0

###
# Training: PMSP

useTrainingSet "vocab_pmsp"

# coax network to settle
train -a steepest -setOnly
setObj momentum 0.0
resetNet
train 10

# perform remaining training with delta-bar-delta
train -a "deltaBarDelta" -setOnly

setObj momentum 0.9
train 190

# Change momentum to 0.98 for remainder of training
setObj momentum 0.98
train 1800

###
# Training: CogSci Replication

useTrainingSet "vocab_cogsci"

train 2000

exit
