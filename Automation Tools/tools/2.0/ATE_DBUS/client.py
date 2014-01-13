#!/usr/bin/env python

usage = """Usage:
import client
1.emit signal
    client.emit_signal(bus_name,bus_interface,bus_path,msg={...})
2.receive signal
    client.receive_signal(receive_handle_function,receive_signal_name)
3.exit server
    client.exit_server(bus_name,bus_interface,bus_path)

Note :Please make sure server is online before you use them.
"""

import sys
import traceback
import thread
import gobject
import time
import dbus
import dbus.decorators
import gobject
import dbus.mainloop.glib


Dbus = None
Dbus_name = None
Dbus_interface = None
Dbus_path = None
receive_Dbus_signal_name = None
receive_Dbus_name = None
receive_Dbus_interface = None
receive_Dbus_path = None
receive_handle_function = None
loop = gobject.MainLoop()


def receive_handle_function(msg):
    print msg


def emit_signal(bus_name='com.example.TestService.automation',
                bus_interface='com.example.TestService.automation',
                bus_path='/com/example/TestService/object/automation',
                msg={},
                receive_handle_function=receive_handle_function,
                receive_signal_name=None,
                receive_bus_name=None,
                receive_bus_interface=None,
                receive_bus_path=None):
    """
    emit signal
    """

    print 'Entry emit_signal'
    global Dbus
    global Dbus_name
    global Dbus_interface
    global Dbus_path
    global receive_Dbus_signal_name
    global receive_Dbus_name
    global receive_Dbus_interface
    global receive_Dbus_path

    Dbus = None
    Dbus_name = bus_name
    Dbus_interface = bus_interface
    Dbus_path = bus_path
    receive_Dbus_signal_name = receive_signal_name
    receive_Dbus_name = receive_bus_name
    receive_Dbus_interface = receive_bus_interface
    receive_Dbus_path = receive_bus_path

    print 'bus name :' + str(Dbus_name)
    print 'bus path :' + str(Dbus_path)
    print 'bus interface :' + str(Dbus_interface)

    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

    Dbus = dbus.SessionBus()
    try:
        proxy = Dbus.get_object(Dbus_name, Dbus_path);
    except dbus.DBusException:
        print "Can not connect to service!"
        exit(1)
    iface = dbus.Interface(proxy, dbus_interface=Dbus_interface)
    try:
        #Dbus.add_signal_receiver(receive_handle_function, dbus_interface = receive_Dbus_interface, signal_name = receive_Dbus_signal_name)
        #gobject.timeout_add(1000,iface.emit_ATE_signal)
        msg = str(msg)
        #        print type(msg)
        #        print msg
        #iface.emit_ATE_signal(msg,reply_handler=handle_reply,error_handler=handle_error)
        iface.emit_ATE_signal(msg)
        return True
        #iface.emit_ATE_signal(msg)
    except dbus.DBusException, e:
        print e
    except Exception, e:
        print e

    loop.run()
    pass


def receive_signal(receive_handle_function=None, receive_signal_name=None,
                   receive_bus_name=None,
                   receive_bus_interface=None,
                   receive_bus_path=None):
    """
    receive signal
    """
    print 'Entry receive_signal'

    global receive_Dbus_signal_name
    global receive_Dbus_name
    global receive_Dbus_interface
    global receive_Dbus_path

    receive_Dbus_signal_name = receive_signal_name
    receive_Dbus_name = receive_bus_name
    receive_Dbus_interface = receive_bus_interface
    receive_Dbus_path = receive_bus_path

    print 'signal name :' + str(receive_Dbus_signal_name)
    print 'bus name :' + str(receive_Dbus_name)
    print 'bus path :' + str(receive_Dbus_path)
    print 'bus interface :' + str(receive_Dbus_interface)

    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

    Dbus = dbus.SessionBus()
    if not receive_Dbus_signal_name:
        print 'No SignalName!'
        exit(1)
    Dbus.add_signal_receiver(receive_handle_function, dbus_interface=receive_Dbus_interface,
                             signal_name=receive_Dbus_signal_name)
    loop.run()


def exit_server(bus_name='com.example.TestService.automation',
                bus_interface='com.example.TestService.automation',
                bus_path='/com/example/TestService/object/automation'):
    """
    exit server
    """
    print 'Entry exit_server'
    global Dbus
    global Dbus_name
    global Dbus_interface
    global Dbus_path
    Dbus = None
    Dbus_name = bus_name
    Dbus_interface = bus_interface
    Dbus_path = bus_path
    print 'bus name :' + str(Dbus_name)
    print 'bus path :' + str(Dbus_path)
    print 'bus interface :' + str(Dbus_interface)

    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

    Dbus = dbus.SessionBus()
    try:
        proxy = Dbus.get_object(Dbus_name, Dbus_path)
    except dbus.DBusException:
        print "Can not connect to service!"
        exit(1)

    #msg = {'function':'quit'}
    #emit_signal(msg=msg)
    proxy.Exit(dbus_interface=Dbus_interface)
    
