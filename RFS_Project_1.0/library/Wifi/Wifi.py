import os
import sys
import pexpect
import re

class Wifi:

    def __init__(self):
        """"""
        self.wan_ip = os.getenv('G_HOST_IP1')

    def get_Interface(self):
        """Get the wireless Interface on the PC such as wlan0"""
        pass

    def generate_Configfile(self):
        """Generate Wireless config file for wireless card to connect AP"""
        pass

    def scan_SSID(self):
        """ Wireless card can scan all SSIDs to check the specified SSID exist or not"""
        pass

    def wifi_Status(self):
        """ Check the connect status that Wireless card connect AP"""
        pass


