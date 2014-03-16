#!/usr/bin/env python


# A Sample program to configure an AP DUT using the HTTP interface via the command line.
# All interfaces and page references will have to be changed to support the actual web
# interface of the DUT/AP

import sys
import re
import urllib
import urllib2
from BeautifulSoup import BeautifulSoup
import md5
import binascii
import time

# CLIArgs
#
# figure out which command line args we've been passed and
# build up a dictionary to be accessed.  getopt/optparse cannot
# be directly used because we don't know what all options may
# be passed to us beforehand.
#
# Input:
#  argv - arguments
#
# Output:
#  input - dictionary of passed in arguments
#
def CLIArgs(args):
    
    options = {}

    re_short = re.compile('^-(\w)$')
    re_long = re.compile('^--(\w+)$')
    re_long_var = re.compile('^--(\w+)=(.*)$')
    found_short = False
    for arg in args:
        match = re_short.search(arg)
        if match:
            found_short = match.group(1).lower()
            options[match.group(1).lower()] = True
            continue
        match = re_long.search(arg)
        if match:
            found_short = False
            options[match.group(1).lower()] = True
            continue
        match = re_long_var.search(arg)
        if match:
            found_short = False
            options[match.group(1).lower()] = match.group(2)
            continue
        if found_short != False:
            options[found_short] = arg
            found_short = False
        else:    
            print "Warning: Found unknown argument", arg
    
    # the short list of options that must have a default
    if not 'loginproto' in options:
        options['loginproto'] = 'http' 
    if not 'loginaddress' in options:
        options['loginaddress'] = '192.168.10.244'
    if not 'loginport' in options:
        options['loginport'] = '80'
    if not 'loginusername' in options:
        options['loginusername'] = 'admin'
    if not 'loginpassword' in options:
        options['loginpassword'] = 'abc123'

    return options

# PostForm
#
# post an HTML form to the web server
#
# Input:
#  url - the URL to post to
#  data - the dictionary of form data
#
# Output:
#  page - the returned page
def PostForm(url, data):
    
    page_data = urllib.urlencode(data)
    
    page_req = urllib2.Request(url, page_data)
    page_response = urllib2.urlopen(page_req)
    page = page_response.read()
    
    return page


# ParseHTMLForm
#
# takes a BeautifulSoup representation of an HTML form
# and parses all found values into a dictionary.
#
# Input:  
#   page - HTML web page to parse.
#
# Output:
#   data - dictionary of form tags/values.
#
def ParseHTMLForm(page):
    
    info = {}
    data = {}
    
    # BeautifulSoup has a bug in parsing SELECT tags.  Solve it here
    # instead of hacking in a fix directly.
    re_select = re.compile('<select id=\"(\S+)\",', re.IGNORECASE)
    page2 = re_select.sub('<select id=\"\g<1>\" ', page)
    
    # BeautifulSoup is converting everything to unicode.  encode them
    # back to ascii and hope we don't hit a device that needs it.
    soup = BeautifulSoup(page2)
    form = soup.find('form')
    info['action'] = form['action'].encode('ascii')
    info['name'] = form['name'].encode('ascii')
    info['method'] = form['method'].encode('ascii')
    info['enctype'] = form['enctype'].encode('ascii')

    name_tags = form.findAll('input')
    
    for tag in name_tags:
        # name tags
        try:
            key = tag['name'].encode('ascii')
            try:
                data[key] = tag['value'].encode('ascii')
            except UnicodeEncodeError:
                data[key] = tag['value']
            continue
        except KeyError:
            pass
          
        # id tags
        try:
            try:
                data[key] = tag['id'].encode('ascii')
            except UnicodeEncodeError:
                data[key] = tag['id']
            continue
        except KeyError:
            pass

        # buttons - the regex dance is due to unicode
        try:
            if re.compile('button', re.IGNORECASE).match(tag['type']):
                # ignore the button
                #data[tag['value'].encode('ascii')] = ''
                continue
        
        except KeyError:
            print "Unknown form tag:", tag
            sys.exit(-1)

    
    select_tags = form.findAll('select')
    for tag in select_tags:
        #try:
        #    data[tag['name'].encode('ascii')] = 
        options = tag.findAll('option')
        for sel in options:
            try:
                # XXX - a better way?
                junk = sel['selected']
            except:
                pass
            else:
                data[tag['name'].encode('ascii')] = sel['value'].encode('ascii')
                
    return(info, data)


# MY_AP_GetMagic - Search a web page for the cache index id.
#   Every page on the AP web is of the format of /cache/<large integer>/index.cgi
#   While I'm sure the large integer could be computed it is easier to just
#   snarf it out of the web page.
#
# Input:
#  page - the web page to look in.
#
# Output:
#  number - the magic number/URL
def MY_AP_GetMagic(page):

    re_magic = re.compile('^\s+case 0:\n\s+f\.encoding=\".*\";\n\s+f\.action=\"(/cache/\d+/index\.cgi)\";$', re.MULTILINE)
    mag_match = re_magic.search(page)
    if not mag_match:
        print "Error: Did not find an encoding or magic number in page"
        sys.exit(-1)
    
    return mag_match.group(1)
    

# MY_AP_GetSessionId - Search a web page for the session id
#
# Input:
#  page - the web page to look in.
#
# Output:
#  session_id - session identification number
def MY_AP_GetSessionId(page):

    re_session = re.compile('name=\"session_id\" value=\"(\d+)\"')
    ses_match = re_session.search(page)

    if not ses_match:
        print "Error: Did not find a session ID in page"
        sys.exit(-1)

    return ses_match.group(1)
    

# MY_AP_RetrievePage - grab a web page off of the AP.
#
# Input:
#  base_url - the start of the URL for this AP.
#  in_page - the previous HTML web page we viewed.  Needed to retrieve
#            the magic number we need to continue on.
#  page_id - the number of the page to grab
#
# Output:
#  out_page - the HTML source of the page
def MY_AP_RetrievePage(base_url, page, page_id):
    
    magic = MY_AP_GetMagic(page)
    session_id = MY_AP_GetSessionId(page)

    form = {}
    form['active_page'] = '6000'
    form['session_id'] = session_id
    form['prev_page'] = '9062'
    form['page_title'] = ''
    form['nav_stack_0'] = '6000'
    form['nav_6000_button_value'] = 'ap_topbar_main'
    form['mimic_button_field'] = 'goto: %s..' % page_id
    form['button_value'] = ''
    form['transaction_id'] = 0
    
    form_data = urllib.urlencode(form)
    form_url = url + magic
    
    page_req = urllib2.Request(form_url, form_data)
    page_response = urllib2.urlopen(page_req)
    page = page_response.read()

    # did we get it?
    re_found = re.compile('Page\(%s\)' % page_id)
    if not re_found.search(page):
        print page
        print "Error: Did not find page %s in HTML" % page_id
        sys.exit(-1)

    return page
    
    
# MY_AP_CheckActivePage - All AP web pages have an internal page ID.
# Make sure it matches what we expect.
#
# Input:
#  data - soup'd HTML web page
#  page - page ID we expect
#
# Output:
#   None
#
def MY_AP_CheckActivePage(data, page):
    
    if data['active_page'] != page:
        print "Error: Found wrong page %s, expecting %s" % (data['active_page'], page)
        sys.exit(-1)


# MY_AP_Login() - Pull the main page from an AP and log in.
#
# Input:
#  url - the URL of the AP
#  options - a dict containing all the info we need
#
# Output:
#  page - the web page we get after logging in
#
def MY_AP_Login(url, options):
    
    page_id = '9062'
    
    try:
        main_req = urllib2.urlopen(url + "/")
        main_data = main_req.read()
        main_req.close()
    except:
        print "Unable to connect to", url
        sys.exit(-1)

    (info, data) = ParseHTMLForm(main_data)

    MY_AP_CheckActivePage(data, '9062')
    
    # sub in the username and password info
    data['user_name'] = options['loginusername']
    data['password_mask'] = options['loginpassword']
    
    # compute the md5
    m = md5.new(options['loginpassword']+data['auth_key'])
    data['md5_pass'] = m.hexdigest()

    return PostForm(url + info['action'], data)


# MY_AP_Logout() - Deauth this session.
#
# Input:
#  base_url - the start of the URL for this AP.
#  page - the previous HTML web page we viewed.  Needed to retrieve
#         the magic number we need to continue on.
#
# Output:
#  the returned web page after logout
def MY_AP_Logout(base_url, page):

     return MY_AP_RetrievePage(base_url, page, '840')


# MY_AP_WirelessSettings
#
# Input:
#  base_url - the start of the URL for this AP.
#  page - the previous HTML web page
#  options - the dictionary of command line arguments
#
# Output:
#  the returned web page after form submission
#
def MY_AP_WirelessSettings(base_url, page, options):
    
    (info, data) = ParseHTMLForm(page)
    
    # wireless should probably always be enabled
    data['wireless_enable_type'] = 1
    
    if 'ssid' in options:
        data['pref_conn_set_ssid'] = options['ssid']

    if 'channel' in options:
        data['pref_conn_set_channel'] = options['channel']

    kname = "wepkey"
    if 'method' in options:
        method = options['method']
        if method == 'None':
            data['wireless_wep_enable_type'] = 0
        elif method[:4] == 'WEP-':
            data['wireless_wep_enable_type'] = 1
            if method[-2:] == '40' or method[-2:] == '64':
                data['pref_conn_set_8021x_key_len'] = 40
                klen = 40
            elif method[-3:] == '128' or method[-3:] == '104':
                data['pref_conn_set_8021x_key_len'] = 104
                klen = 128
            kname = "%s%d" % (kname, klen)

    # default is hex/0
    data['pref_conn_set_8021x_key_mode'] = '0'
    key_ascii = "%sascii" % (kname)
    key_hex   = "%shex"   % (kname)
    key = ''
    if key_ascii in options:
        data['pref_conn_set_8021x_key_mode'] = '1'
        key = options[key_ascii]
    elif key_hex in options:
        key = options[key_hex]
    elif 'method' in options:
        method = options['method']
        if method[:4] == 'WEP-':
            key = data['ap_default_wep_key_ascii']

    if data['pref_conn_set_8021x_key_mode'] == '0':
        data['ap_default_wep_key'] = key
        data['ap_default_wep_key_ascii'] = ''
        data['ap_default_wep_key_128'] = key
        data['ap_default_wep_key_ascii_128'] = ''
    else:
        data['ap_default_wep_key_ascii'] = key
        data['ap_default_wep_key'] = binascii.hexlify(key)
        data['ap_default_wep_key_ascii_128'] = key
        data['ap_default_wep_key_128'] = binascii.hexlify(key)
        
    page = PostForm(base_url + info['action'], data)
    (info, data) = ParseHTMLForm(page)
	
    # sometimes we're asked for confirmation.  when and why
	# this happens is as yet unknown.
    if data['active_page'] == '801':
        page = PostForm(base_url + info['action'], data)

    return page


# MY_AP_AdvancedSecuritySettings
#
# Input:
#  base_url - the start of the URL for this AP.
#  page - the previous HTML web page
#  options - the dictionary of command line arguments
#
# Output:
#  the returned web page after form submission
#
def MY_AP_AdvancedSecuritySettings(base_url, page, options):
    
    (info, data) = ParseHTMLForm(page)
    
    if 'method' in options:
        meth = options['method']
        if meth[:4] == 'WEP-':
            data['wireless_advanced'] = 1
        if meth[:7] == 'WPA-PSK':
            data['wireless_advanced'] = 3
        if meth[:8] == 'WPA2-PSK':
            data['wireless_advanced'] = 4
        data['mimic_button_field'] = 'submit_button_wireless_next: ..'
        
        page = PostForm(base_url + info['action'], data)
        (info, data) = ParseHTMLForm(page)

        keytype = 1
        key = 'unspecified'
        if 'pskascii' in options:
            key = options['pskascii']
        elif 'pskhex' in options:
            keytype = 0
            key = options['pskhex']
            
        if meth[:7] == 'WPA-PSK':
            # always preshared key (for now)        
            data['pref_conn_set_wpa_sta_auth_type']=1

            data['pref_conn_set_psk_representation'] = keytype
            data['pref_conn_set_wpa_sta_auth_shared_key'] = key
            if meth == 'WPA-PSK':
                cipher=1
            else:
                cipher=2
            data['pref_conn_set_wpa_cipher'] = cipher
            
            
        if meth[:8] == 'WPA2-PSK':
            # always preshared key (for now)        
            data['pref_conn_set_wpa_sta_auth_type']=1
            data['pref_conn_set_psk_representation'] = keytype
            data['pref_conn_set_wpa_sta_auth_shared_key'] = key

            if meth == 'WPA2-PSK':
                cipher = '2'
            else:
                cipher = '1'
            data['pref_conn_set_wpa_cipher'] = cipher
        
        if meth[:3] == 'WEP':
            # use the key we set on the basic security page
            data['pref_conn_set_wep_active'] = '0'
            auth = '0'
            if meth[:13] == 'WEP-SharedKey':
                auth = '1'
            data['pref_conn_set_wl_auth'] = auth
        
        data['mimic_button_field'] = 'submit_button_wireless_apply: ..'
        data['button_value'] = '9074'
        page = PostForm(base_url + info['action'], data)
        (info, data) = ParseHTMLForm(page)
        
        # sometimes we're asked for confirmation.  when and why
	    # this happens is as yet unknown.
        if data['active_page'] == '801':
            page = PostForm(base_url + info['action'], data)

        # just like watching the little hourglass spin
        time.sleep(8)
        
        
    return page
    
    
if __name__ == "__main__":

    options = CLIArgs(sys.argv[1:])

    url="%s://%s:%s" % (options['loginproto'],
        options['loginaddress'],
        options['loginport'])

    # login
    page = MY_AP_Login(url, options)

    # get the basic wireless settings page
    page = MY_AP_RetrievePage(url, page, '9072')
    
    # set the basic wireless settings
    page = MY_AP_WirelessSettings(url, page, options)

    if 'method' in options:
        meth = options['method']
        if meth[:7] == 'WPA-PSK' or meth[:8] == 'WPA2-PSK' or \
           meth[:13] == 'WEP-SharedKey' or meth[:8] == 'WEP-Open':
            page = MY_AP_RetrievePage(url, page, '9074')
            page = MY_AP_AdvancedSecuritySettings(url, page, options)

    # the AP can only have 5 sessions.  logging out is necessary
    page = MY_AP_Logout(url, page)
    
    #auth_handler = urllib2.HTTPBasicAuthHandler()
    #auth_handler.add_password(realm=options['realm'],
    #    uri = url,
    #    user = options['username'],
    #    passwd = options['password'])
    #opener = urllib2.build_opener(auth_handler)
    #urllib2.install_opener(opener)

    

