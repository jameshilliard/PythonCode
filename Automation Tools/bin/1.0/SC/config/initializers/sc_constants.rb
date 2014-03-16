# Set to true if running as a testing environment, this will do everything in 1 minute intervals
SC_TESTING = TRUE

# Server must be restarted for any of these changes take affect!
# Status states
SERVER_STATES = ["Unknown", "Available", "Busy", "Reserved", "Pending", "Setup"]
TEST_STATES = ["Unknown", "Failed", "Passed", "Force Stopped", "Force Passed", "Force Failed", "Queued", "Processing"]
OVERRIDE_STATES = ["Force Stopped", "Force Passed", "Force Failed"]

# Server specifics
# State to change server to once the wait time is hit
SERVER_FALLBACK_STATE = 0
# If at any point we need to actually do a real DNS lookup then this needs to be
# set to true
SERVER_REVERSE_DNS_LOOKUP = FALSE
# Require server keys to update data?
# If this is false, then the update must include the actual database server ID
# *or* the update must come from a valid IP address that has already been added.
SERVER_REQUIRE_KEY = FALSE
# Default server state on creation; Regardless of what this is set to, the state
# will be changed to "Setup" during the server setup process
SERVER_DEFAULT_STATE = 0

# Test suite specifics
# Sets the maximum amount of individual steps that can reside in a test suite
# This prevents combining extremely long tests together in large amounts
TESTSUITE_MAX_STEPS = 1500
# Minimum steps needed before we create a test suite for testing
TESTSUITE_MIN_STEPS = 1
# Default test suite creation state
TESTSUITE_DEFAULT_STATE = 7
# Steps needed before assigning to a server (wait time before force assignment is
# the same as the wait time for force creation)
TESTSUITE_MIN_STEPS_FOR_SERVER_ASSIGNMENT = 300
# Wait for entire suite to be done before pushing results
TESTSUITE_WAIT_FOR_ALL_BEFORE_RESULT_PUSH = false

# Test case specifics
# Default creation state
TESTCASE_DEFAULT_STATE = 7
# Default state after being assigned to a test suite
TESTCASE_DEFAULT_TESTSUITE_STATE = 6
# Enable/Disable automatic result pushes
TESTCASE_AUTOMATIC_RESULT_PUSHING = true

# Timers
# Maximum time to wait for new test cases before creating a test suite below the minimum step count.
# This will override the minimum suite steps required for a test suite only after this time period has passed.
# Wait time is based off the creation time of the test case in the database.
WAIT_TIME_BEFORE_FORCE_SUITE_CREATION = 15.minutes
# Maximum time to wait for a server to update before its status gets changed automatically.
WAIT_TIME_BEFORE_SERVER_STATE_CHANGE = 2.hours
# Wait time before checking for new test cases (periodic)
WAIT_TIME_TEST_CASE_UPDATE = 10.minutes
# Wait time before creating a new test suite (periodic)
# Note: Server assignment is done after test suite creation is finished unless
# the test suite is reserved/held, or the test suite contains a low amount of test cases.
WAIT_TIME_BEFORE_TEST_SUITE_CREATION = 15.minutes
# Wait time before automatically updating TestLink with results.
# Note: This only matters if automatic result pushes are enabled.
WAIT_TIME_BEFORE_TEST_RESULT_PUSH = 10.minutes
# Server assignment wait time
WAIT_TIME_BEFORE_SUITES_ASSIGNED_TO_SERVER = 10.minutes

# Other stuff
# Application general information
APP_VERSION = "0.8.9"
APP_CONTACT = "Chris Born (cborn@actiontec.com)"
APP_COPYRIGHT = "Copyright (c) 2011 Actiontec Electronics Inc., Confidential. All rights reserved."
APP_TITLE = "Server Control UI"

# Icons
ACTION_EDIT="action_edit.png"
ACTION_DELETE="action_delete.png"
ACTION_SETTINGS="action_settings.png"
ACTION_DBCHECK="action_dbcheck.png"
ACTION_DEFAULT="action_default.png"
ACTION_DBCHECK2="action_dbcheck2.png"
