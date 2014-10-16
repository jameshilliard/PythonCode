#! /usr/bin/python
# -*- coding: UTF-8 -*-

# Importing pyactiveresource
from activeresource import ActiveResource
#import activeresource 
from pprint import pprint


class Issue(ActiveResource):
    _site = 'http://192.168.20.105/redmine/'
    _user = 'hying'
    _password = '123456'


#ar = ActiveResource(prefix_options={
#                                '_site':'http://192.168.20.105/redmine',
#                                '_user':'hying',
#                                '_password':'123456',
#                                })

limit = '100'
# Get issues
#issues = Issue.find(limit=limit, from_='redmine/issues/29111')
#issues = Issue.find(29111, include='children').to_dict()

#pprint(issues)

#new_issue = {
#        'fixed_version_id' : '1',
#        'tracker_id' : '1',
#        'assigned_to_id' : '1',
#        'estimated_hours' : '1.0',
#        'ignore_estimated_hours_conflict' : '1',
#        'parent_issue_id' : '38480',
#        }
#
#print Issue.create(new_issue)

#pprint(len(issues.to_dict().get('children')))

# Get a specific issue, from its id
#issue = Issue.find(1345)
#count = 0
#while True:
#    count += 1
#    if len(issues) == 100:
#        issues = Issue.find(limit=limit, offset=int(limit) * count)
#        print len(issues)
#    else:
#        issues = Issue.find(limit=limit, offset=int(limit) * count)
#        print len(issues)
#        break

