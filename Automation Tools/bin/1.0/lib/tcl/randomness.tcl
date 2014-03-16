#
# $Id: randomness.tcl,v 1.1 2006/07/20 17:08:48 manderson Exp $

set cvs_author  [cvs_clean "$Author: manderson $"]
set cvs_ID      [cvs_clean "$Id: randomness.tcl,v 1.1 2006/07/20 17:08:48 manderson Exp $"]
set cvs_file    [cvs_clean "$RCSfile: randomness.tcl,v $"]
set cvs_version [cvs_clean "$Revision: 1.1 $"]
set cvs_date    [cvs_clean "$Date: 2006/07/20 17:08:48 $"]
set cvs_release [cvs_clean "$Name: b2_4_2_rd $"]

debug $::DBLVL_CVS_VERSION "loading $cvs_file $cvs_version $cvs_date"

#
# proc random_ssid {}
#
# random_ssid generates and returns a random ASCII string suitable for
# use as an SSID.  It is useful for those who cannot make up their minds
# or to help test those APs which take a long time to beacon
proc random_ssid {} {

    expr {srand([clock seconds])}
    
    set ssid_len [expr {int(rand()*30)+3}]
   
    set ssid ""
    
    for {set x 0} {$x < $ssid_len} {set x [expr {$x+1}]} {
        append ssid [random_ssid_gen_char]
    }
    
    return $ssid
}


# returns a random character from the set of A-Z,a-z,0-9
proc random_ssid_gen_char {} {
    set i [expr {int(rand()*62)}]
    if {$i < 26} {
        # a-z
        set char [format "%c" [expr {97 + $i}]]
    } elseif {$i < 52} {
        # A-Z
        set char [format "%c" [expr {39 + $i}]]
    } else {
        # 0-9
        set char [format "%c" [expr {$i - 4}]]
    }
    return $char
}

# shuffle5 from http://wiki.tcl.tk/941
proc randomize_list { list } {
    set n 1
    set slist {}
    foreach item $list {
	set index [expr {int(rand()*$n)}]
	set slist [linsert $slist $index $item]
	incr n
    }
    return $slist
}

