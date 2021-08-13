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

# all relative to ./scripts
# set root_path "../../.."
set root_path "."
set examples_path "${root_path}/examples"

set pmsp_example_file "${examples_path}/pmsp-train-the-normalized.ex"
set cogsci_example_file "${examples_path}/cogsci-pmsp-added-partition-$partition_id-dilution-${dilution_amount}.ex"

set weights_path "${root_path}/var/${script_name}/weights"
set results_path "${root_path}/var/${script_name}/results"

file mkdir $results_path
file mkdir $weights_path

###
# Network Architecture

set dt 100
# set dt 1

addNet "pmspRecurrent" -i 2 -t $dt CONTINUOUS

# input layer
addGroup ortho_onset 30 INPUT
addGroup ortho_vowel 27 INPUT
addGroup ortho_coda 48 INPUT

# hidden layer
addGroup hidden 100 IN_INTEGR

# output layer
addGroup phono_onset 23 OUTPUT IN_INTEGR CROSS_ENTROPY
addGroup phono_vowel 14 OUTPUT IN_INTEGR CROSS_ENTROPY
addGroup phono_coda 24 OUTPUT IN_INTEGR CROSS_ENTROPY

# connections
connectGroups ortho_onset hidden -p FULL
connectGroups ortho_vowel hidden -p FULL
connectGroups ortho_coda hidden -p FULL
connectGroups hidden phono_onset -p FULL -bidirectional
connectGroups hidden phono_vowel -p FULL -bidirectional
connectGroups hidden phono_coda -p FULL -bidirectional
connectGroups {phono_onset phono_vowel phono_coda} {phono_onset phono_vowel phono_coda}

useNet "pmspRecurrent"

###
# Parameters

# "the global learning rate ... was increased from 0.001 to 0.05, to compensate for the fact that the summed frequency for the entire training corpus is reduced from 683.4 to 6.05 when using actual rather than logarithmic frequencies."
# How to sum frequencies in examples file:
# echo $(grep freq pmsp-train.ex | cut -d ' ' -f2 | sed 's/$/+/') 0 | bc
# echo $(cat plaut_dataset_collapsed.csv|cut -d',' -f5 | tr -d $'\r' | sed 's/$/+/') 0 | bc
# df = pd.read_csv('../pmsp-torch/pmsp/data/plaut_dataset_collapsed.csv')
# sum([math.log(2+x) for x in df['freq']])
# Our previous sum: 8208.649287087

setObj learningRate 0.05

# p. 28 "the slight tendency for weights to decay towards zero was removed, to prevent the very small weight changes induced by low-frequency words - due to their very small scaling factors - from being overcome by the tendency of weights to shrink towards zero."
setObj weightDecay 0.00000

# "output units are trained to targets of 0.1 and 0.9"
setObj targetRadius 0.1

# diagnostic parameter not related to replication
setObj reportInterval 10

# example frequencies are caclulated as log(2 + kucera-and-francis-count, e)
# "In order to improve performance on the XOR task, we might think of trying to weight the examples presented to the network more heavily in favor of the ones it gets wrong. One way to do this is to activate pseudo-example-frequencies by setting the network's pseudoExampleFreq to 1. The error on an example will then be scaled by the example's frequency value."
# pseudoExampleFreq is 1 in order to use frequencies in examples file
setObj pseudoExampleFreq 1

# this routine will save weights to the proper path
proc save_weights_hook {} {
    global weights_path
    set epoch [ getObj totalUpdates ]
    saveWeights "${weights_path}/${epoch}.wt.gz"
}
setObj postEpochProc { save_weights_hook }

# Log accuracy throughout training
source "accuracy.tcl"
set loggingInterval 1
setObj postExampleProc { logAccuracyHook }

###
# Examples

# load frequency-dilution vocab and anchors

# replace 0.69314718 with 0.000085750
# n=1 replace 2.484906650 with (6 - (2998*0.000085750)) / 30 = 0.1914307167
# n=2 replace 1.945910149 with (6 - (2998*0.000085750)) / 60 = 0.09571535833
# n=2 replace 1.673976434 with (6 - (2998*0.000085750)) / 90 = 0.06381023889

# n=1 replace 0.1914307167 with 0.001 * 3/3
# n=2 replace 0.09571535833 with 0.001 * 2/3
# n=2 replace 0.06381023889 with 0.001 * 1/3

# "error is injected only for the second unit of time; units receive no direct pressure to be correct for the first unit of time (although back-propagated internal error causes weight changes that encourage units to move towards the appropriate states as early as possible"
# this prevents error from being computed until after the graceTime has passed.
loadExamples $pmsp_example_file -s "vocab_pmsp"
exampleSetMode "vocab_pmsp" PERMUTED
setObj vocab_pmsp.minTime 2.0
setObj vocab_pmsp.maxTime 2.0
setObj vocab_pmsp.graceTime 1.0

loadExamples $cogsci_example_file -s "vocab_cogsci"
exampleSetMode "vocab_cogsci" PERMUTED
setObj vocab_cogsci.minTime 2.0
setObj vocab_cogsci.maxTime 2.0
setObj vocab_cogsci.graceTime 1.0

# Need to view units to be able to access the history arrays.
# This is for inspecting activations
# ensure it updates per example, not per batch
# (updates 3: update after each example)
# viewUnits -updates 3

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

setObj momentum 0.98
train 1800

# reset accumulated evidence
# setObj learningRate 0
# train -a steepest -setOnly
# train 1

###
# Training: CogSci Replication

useTrainingSet "vocab_cogsci"

train -a "deltaBarDelta" -setOnly
# setObj learningRate 0.05
# setObj momentum 0.98
train 2000

saveAccuracyResults "${results_path}/accuracy-training.tsv"

exit
