#
# paths.tcl - define variables containing paths to other parts of the
#   VeriWave automation infrastructure
#
# this file is sourced by automation programs found in $VW_TEST_ROOT/bin
#
# $Id: paths.tcl,v 1.5 2007/01/11 21:49:02 wpoxon Exp $
#

set BENCHMARK_TEST_DIR [file join $VW_TEST_ROOT ".." apps benchmark]
set CONF_DIR [file join $VW_TEST_ROOT conf]
set LIB_DIR [file join $VW_TEST_ROOT lib]
set TCL_LIB_DIR [file join $LIB_DIR tcl]
set VCL_LIB_DIR [file join $VW_TEST_ROOT ".." lib tcl vcl]
set LOG_DIR [file join $VW_TEST_ROOT log]

