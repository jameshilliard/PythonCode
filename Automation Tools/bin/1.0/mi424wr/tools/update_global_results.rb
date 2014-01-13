#!/usr/bin/env ruby

# Updates the final result log for passed results
gr = "/root/actiontec/automation/logs/current/result.txt"
gcsv = "/root/actiontec/automation/logs/current/result.csv"
base = "/root/actiontec/automation/logs/current"
# Fix result.txt and result.csv
results = File.open(gr).read
csv_results = File.open(gcsv).read
checking = results.scan(/\[\d+\]\.Testcase FAILED: .*xml$/)

checking.each do |check|
    checkdir = "#{base}/#{check.slice(/tc_sect.*/)}*"
    r_file = "#{Dir.glob(checkdir)[0]}/result.txt"
    checkresults = File.open(r_file).read
    unless checkresults.match(/step_\d+ failed:/i)
        puts "Updating log"
        results.gsub!(check, check.sub(/failed/i, "Passed"))
        puts "Updating csv"
        csv_results.sub!(/(#{check.slice(/tc_sect.*/)};Test page.*)FAIL/) { "#{$1}pass" }
    end
end

File.open(gr, "w+").write(results)
File.open(gcsv, "w+").write(csv_results)






