#!/usr/local/bin/wpy24

import os,sys
for item in sys.path:
    if item.count("PIL") > 0:
        parts = item.split("\\")
        item = "/".join(parts)
        sys.stdout.write(item)
        sys.exit(0)

sys.stdout.write("None")
sys.exit(0)

