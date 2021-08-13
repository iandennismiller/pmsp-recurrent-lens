# pmsp-lens
# Ian Dennis Miller
# 2020-11-07

# the results will be globally available
set accuracyResults {}

set previousError 0

# install hook with 'setObj postExampleProc ...'
proc logAccuracyHook {} {
    # invocation from the hook does not permit passing values
    # thus, loggingInterval is global; it is set in logger.tcl
    global loggingInterval
    set epoch [getObj totalUpdates]

    # skip epoch 0 because nothing has happened yet
    if { [ expr $epoch == 0 ] } {
        return
    }

    # after loggingInterval has elapsed, record some values
    if { [ expr fmod($epoch, $loggingInterval) ] == 0.0 } {
        checkExampleAccuracy
    }
}

proc saveAccuracyResults { loggingFile } {
    global accuracyResults
    set chan [open $loggingFile w]
    puts $chan "epoch\texample_id\torthography\tphonology\tcategory\tcorrect\terror"
    foreach result $accuracyResults {
        puts $chan "${result}"
    }
    close $chan
    puts "Wrote results to ${loggingFile}"
}

# Check whether output is correct, altogether
# This expects the simulator to have a fresh example available,
# as if it were called via postExampleProc
proc checkExampleAccuracy {} {
    global accuracyResults
    global previousError

    set epoch [getObj totalUpdates]
    set exampleName [getObj currentExample.name]
    set isCorrect [ allVowelsCorrect ]
    
    # puts "$exampleName"

    regexp {^(\d+)_(\S+?)_(\S+?)_(.+)$} $exampleName match id orthography phonology category
    # puts "$exampleName $id"

    # get error from phono_vowel output layer
    set runningErrorAmount [getObj group(6).error]
    set errorAmount [ expr $runningErrorAmount - $previousError ]
    set previousError $runningErrorAmount

    set newResult [format "%d\t%d\t%s\t%s\t%s\t%s\t%f" $epoch $id $orthography $phonology $category $isCorrect $errorAmount]
    lappend accuracyResults $newResult
}

proc allVowelsCorrect { } {
    # group(6) corresponds to the vowels in the output group
    for {set idx 0} {$idx < [getObj group(6).numUnits]} {incr idx} {
        set activation [expr round([getObj group(6).unit($idx).output])]
        set target [getObj group(6).unit($idx).target]

        if { $activation != $target } {
            return 0
        }
    }

    return 1
}

# examine target to identify index of correct vowel
proc getIndexOfTargetVowel { } {
    # iterate across all units in phonology vowel layer
    for {set idx 0} {$idx < [getObj group(6).numUnits]} {incr idx} {
        set target [getObj group(6).unit($idx).target]
        # return index of the vowel that is supposed to be active
        if {[expr $target == 1]} {
            return $idx
        }
    }

    # otherwise return 0, I guess
    return 0
}

# examine phono vowel layer to find index of most active unit
proc getIndexOfMostActiveVowel { } {
    set biggest 0
    set biggest_idx 0

    # iterate across all units in phonology vowel layer
    for {set idx 0} {$idx < [getObj group(6).numUnits]} {incr idx} {
        set activation [getObj group(6).unit($idx).output]
        if { [ expr { $activation > $biggest } ] } {
            set biggest $activation
            set biggest_idx $idx
        }
    }

    return $biggest_idx
}

# check whether output is active at target vowel
proc targetVowelCorrect { } {
    # obtain index of correct vowel
    set correctVowelIdx [ getIndexOfTargetVowel ]

    # check same index in output layer
    # group(6) corresponds to the vowels in the output group
    set activation [getObj group(6).unit($correctVowelIdx).output]

    # if value of output vowel unit is above 0.5, return true
    if { [ expr {$activation >= 0.5} ] } {
        return 1
    } else {
        return 0
    }
}

# check whether most active vowel matches target
proc mostActiveVowelCorrect { } {
    # obtain index of correct vowel
    set correctVowelIdx [ getIndexOfTargetVowel ]

    # obtain index of most active vowel
    set mostActiveVowelIdx [ getIndexOfMostActiveVowel ]

    if {[expr {$correctVowelIdx == $mostActiveVowelIdx}]} {
        return 1
    } else {
        return 0
    }
}
