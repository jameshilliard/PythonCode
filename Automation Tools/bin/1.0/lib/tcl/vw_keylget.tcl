#
# proc vw_keylget
#
# $Id: vw_keylget.tcl,v 1.1.16.1 2007/11/20 20:11:48 manderson Exp $
#

# a replacement for extended TCL's keylget.  this version will try to search the keyed list
# 'where' for various permutations of the passed in value of 'what'
proc vw_keylget {where what} {

    debug $::DBLVL_TRACE "vw_keylget $what $where"

    upvar 1 $where keyed_list
    if {! [info exists keyed_list]} {
        upvar #0 $where keyed_list
    }
    
    # SomeThing -> SOME_THING
    set other_name ""
    set last_char ""
    for {set x 0} {$x <[string length $what]} {incr x} {
        set char [string index $what $x]
        if { $x != 0 && $char >= "A" && $char <= "Z" } {
            append other_name "_"
        } elseif { $x != 0 && $char >= "0" && $char <= "9" && ($last_char < "0" || $last_char > "9")} {
            append other_name "_"
        } else {
            set char [string toupper $char]
        }
        append other_name $char
        set last_char $char
    }

    if {![catch {set val [keylget keyed_list $other_name]}]} {
        return $val
    }
    debug $::DBLVL_TRACE "vw_keylget $other_name not found"

    # SomeThing -> something
    if {![catch {set val [keylget keyed_list [string tolower $what]]}]} {
        return $val
    }
    debug $::DBLVL_TRACE "vw_keylget [string tolower $what] not found"

    # SomeThing -> SOMETHING
    if {![catch {set val [keylget keyed_list [string toupper $what]]}]} {
        return $val
    }
    debug $::DBLVL_TRACE "vw_keylget [string toupper $what] not found"

    # SomeThing -> SomeThing
    # let this one fail so that the caller can do any needed error handling
    set val [keylget keyed_list $what]

    # if it starts and ends with %% and we are actually trying to run a test,
    # grab the value out of the variable passed in.
    if {[info exists ::configurator::run_time]} {
        if  {[regexp {%%(.+)\.(.+)%%} $val junk klist path]} {
            set val "<unknown reference \"$val\">"
            # try for it at the group level too
            set grp_klist "grp_$klist"
            foreach list_name "$klist $grp_klist" {
                upvar 1 $list_name keyed_list
                if {![info exists keyed_list]} {
                    upvar #0 $list_name keyed_list
                }
                catch {set val [vw_keylget keyed_list $what]}
            }
        }
    }

    return $val
}
