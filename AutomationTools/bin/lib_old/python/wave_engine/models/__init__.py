"""
This package contains the model (as M in Model-View-Controller architecture) 
part of the code for the relevant parts of WaveApps. 
As a rule of thumb, each page in WaveApps GUI has a module e.g.,
clients page has clientSetup.py which generates one or more dictionaries to be
used by the application logic. clientSetup.py must contain primarily the GUI 
logic, all the other part (creating, processing etc of the dictionaries used
by the core WaveApps) should be in their respective model modules, conventionally 
named the same as their view counterparts i.e., WaveAppSuite/clientSetup.py has
corresponding models/clientSetup.py 
"""