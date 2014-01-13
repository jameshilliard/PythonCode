
set VW_AUTO=C:\work\automation_4.0.0-WT-3.4_2008.07.25.06_win32\automation\bin\vw_auto.tcl


FOR /F "tokens=1,*" %%f IN (testlist) DO tclsh %VW_AUTO% -f %%f %%g