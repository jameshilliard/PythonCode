
#
# range functions for TCL
#
# $Id: range.tcl,v 1.2 2006/04/13 04:55:55 manderson Exp $
#

#
# source:
#	http://www.tcl.tk/cgi-bin/tct/tip/225
#
# authors:
#	Salvatore Sanfilippo <antirez at invece dot org>
#	Miguel Sofer <msofer at users dot sf dot net>
#
# copyright:
#	this code, and the document cited above which contains this code
#	have been placed in the public domain
#

# RangeLen(start, end, step)
# 1. if step = 0
# 2.     then ERROR
# 3. if start = end
# 4.     then return 0
# 5. if step > 0 AND start > end
# 6.     then ERROR
# 7. if setp < 0 AND end > start
# 8.     then ERROR
# 9. return 1+((ABS(end-start))/ABS(step))
proc rangeLen {start end step} {
    if {$step == 0} {return -1}
    if {$start == $end} {return 0}
    if {$step > 0 && $start > $end} {return -1}
    if {$step < 0 && $end > $start} {return -1}
    expr {1+((abs($end-$start))/abs($step))}
}

# Range(start, end, step)
# 1. result <- EMPTY LIST
# 2. len <- RangeLen(start, end, step)
# 3. for i <- 0 to len - 1
# 4.     result.append(start+(i*step))
# 6. return result
proc range args {
    # Check arity
    set l [llength $args]
    if {$l == 1} {
        set start 0
        set step 1
        set end [lindex $args 0]
    } elseif {$l == 2} {
        set step 1
        foreach {start end} $args break
    } elseif {$l == 3} {
        foreach {start end step} $args break
    } else {
        error {wrong # of args: should be "range ?start? end ?step?"}
    }

    # Generate the range
    set rlen [rangeLen $start $end $step]
    if {$rlen == -1} {
        error {invalid (infinite?) range specified}
    }
    set result {}
    for {set i 0} {$i < $rlen} {incr i} {
        lappend result [expr {$start+($i*$step)}]
    }
    return $result
}

