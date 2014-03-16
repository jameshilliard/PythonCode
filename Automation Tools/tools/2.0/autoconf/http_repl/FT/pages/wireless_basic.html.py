#       wireless_basic.py
#       
#       Copyright 2011 rayofox <rayofox@rayofox-test>
#       
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.
#       
#       

# form information
form_type = "POST"
form_fmt_unique = True
form_hashmap = True
form_has_order = False

form_sample = """
		wep_active=4&
		wireless_vap_name=ath0&
		wireless_enable_type=1&
		wireless_ssid=bensonfiber&
		wireless_channel=0&
		wireless_keep_channel=1&
		wireless_wep_enable_type=1&
		wep_key_len=0&
		wep_key_mode=0&
		wep_key_code=1A2B3C4D5E
		"""

form_fmt = {
    "wep_active": 4,
    "wireless_vap_name": "ath0",
    "wireless_enable_type": "1",
    "wireless_ssid": "bensonfiber",
    "wireless_channel": "0",
    "wireless_keep_channel": "1",
    "wireless_wep_enable_type": "1",
    "wep_key_len": "0",
    "wep_key_mode": "0",
    "wep_key_code": "1A2B3C4D5E",

}


def check(frm):
    """
    1. the unique format
    2. hashmap without index(no order,keyword unique)
    """
    if form_hashmap:
        check_hashmap(frm)
    else:
        check_string(frm)

    pass


def replace(frm):
    """
    """
    pass

