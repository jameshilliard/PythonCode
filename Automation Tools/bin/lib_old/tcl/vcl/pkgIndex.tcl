if {[catch {package require Tcl 8.4}]} return
package ifneeded vcl 1.0 [list eval puts {[} load [file join $dir [join [list "vclapi" [info sharedlibextension]] "" ]] ";" source [file join $dir vclinit.tcl] {]} ]
