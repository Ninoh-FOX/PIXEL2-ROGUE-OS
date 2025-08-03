# Bluetool code is placed under the GPL license.
# Written by Aleksandr Aleksandrov (aleksandr.aleksandrov@emlid.com)
# Copyright (c) 2016-2017, Emlid Limited
# All rights reserved.

# If you are interested in using Bluetool code as a part of a
# closed source project, please contact Emlid Limited (info@emlid.com).

# This file is part of Bluetool.

# Bluetool is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Bluetool is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Bluetool.  If not, see <http://www.gnu.org/licenses/>.

import dbus
import dbus.service
import dbus.mainloop.glib
import socket

try:
    from gi.repository import GObject
except ImportError:
    import gobject as GObject

from tcpbridge import TCPBridge, SocketSink, TCPBridgeError
from bluetool import Bluetooth
from utils import print_error, print_info


class SerialPort(object):
    profile_path = "/org/bluez/myprofile"

    def __init__(self, channel=1):
        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
        self.bus = dbus.SystemBus()
        self.uuid = "1101"
        self.opts = {
            "Name": "Reach SPP",
            "Channel": dbus.UInt16(channel),
            "AutoConnect": False
        }

        self.manager = dbus.Interface(
            self.bus.get_object("org.bluez", "/org/bluez"),
            "org.bluez.ProfileManager1")

    def register(self):
        try:
            self.manager.RegisterProfile(
                self.profile_path, self.uuid, self.opts)
        except dbus.exceptions.DBusException as error:
            print_error(str(error) + "\n")
            return False

        return True

    def unregister(self):
        try:
            self.manager.UnregisterProfile(self.profile_path)
        except dbus.exceptions.DBusException:
            pass


class BluetoothServer(dbus.service.Object):
    def __init__(self, tcp_port_in=8043, tcp_port_out=None, channel=1):
        self._spp = SerialPort(channel)
        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
        dbus.service.Object.__init__(
            self, dbus.SystemBus(), self._spp.profile_path)
        self.tcp_port_in = tcp_port_in
        self.tcp_port_out = tcp_port_out
        self._mainloop = GObject.MainLoop()

    def run(self):
        if not self._spp.register():
            return

        self._mainloop.run()

    def shutdown(self):
        try:
            self.bridge.stop()
        except AttributeError:
            pass

        self._mainloop.quit()
        self._spp.unregister()

    @dbus.service.method(
        "org.bluez.Profile1", in_signature="oha{sv}", out_signature="")
    def NewConnection(self, path, fd, properties):
        address = str(path)
        address = address[len(address) - 17:len(address)]
        address = address.replace("_", ":")
        print_info("Connected: {}\n".format(address))

        blue_socket = socket.fromfd(
            fd.take(), socket.AF_UNIX, socket.SOCK_STREAM)

        socket_sink = SocketSink(sock=blue_socket)
        self.bridge = TCPBridge(
            sink=socket_sink,
            port_in=self.tcp_port_in,
            port_out=self.tcp_port_out)

        try:
            self.bridge.start(in_background=False)
        except TCPBridgeError as error:
            print_error(str(error) + "\n")

        self.bridge.stop()
        blue_socket.close()

        print_info("Disconnected: {}\n".format(address))
        Bluetooth().disconnect(address)
