# Need to set VW_AUTO to point to vw_auto.tcl in your automation directory.
# set VW_AUTO "C:\\work\\WaveAutomate-3-2-2\\automation\\bin\\vw_auto.tcl"
  set VW_AUTO "/home/vinay/waveautomation/WaveAutomate_3.2.2_2008.03.24.04_linux-x86/automation/bin/vw_auto.tcl"
 set f [open testlist]
 while {1} {
     if [eof $f] {
         close $f
         break
     }
     set line [gets $f]
     set trimmedLine [string range $line 0 [expr [string first "-" $line] - 2]]        
     if {$trimmedLine == ""} {
          break
     } else { 
          exec >@stdout tclsh $VW_AUTO -f $trimmedLine
     }     
     
}
