#!/usr/bin/env python

usage = """
Usage : python server.py
"""

import gobject
import time
import dbus
import dbus.service
import dbus.mainloop.glib

Dbus_PATH = '/com/example/TestService/object/automation'
Dbus_IFACE = 'com.example.TestService.automation'
Dbus_NAME = 'com.example.TestService.automation'


class DbusServer(dbus.service.Object):
    def __init__(self, bus, object_path):
        dbus.service.Object.__init__(self, bus, object_path)

    @dbus.service.signal(dbus_interface=Dbus_IFACE, signature='a{sv}')
    def ATESignal(self, msg):
        pass

    @dbus.service.method(dbus_interface=Dbus_IFACE, in_signature='s', out_signature='')
    def emit_ATE_signal(self, msg):
        msg = eval(msg)
        self.ATESignal(msg)

    @dbus.service.method(dbus_interface=Dbus_IFACE, in_signature='', out_signature='')
    def Exit(self):
        loop.quit()


if __name__ == '__main__':
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

    bus = dbus.SessionBus()

    name = dbus.service.BusName(Dbus_NAME, bus)

    service = DbusServer(bus, Dbus_PATH)
    #gobject.timeout_add(1000,service.emit_ATE_signal)
    loop = gobject.MainLoop()
    print 'server is working...'
    loop.run()
