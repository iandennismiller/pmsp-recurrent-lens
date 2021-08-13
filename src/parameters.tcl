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
