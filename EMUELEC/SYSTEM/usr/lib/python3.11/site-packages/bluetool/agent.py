# Bluetool code is placed under the GPL license.
# Written by Aleksandr Aleksandrov (aleksandr.aleksandrov@emlid.com)
# Copyright (c) 2017, Emlid Limited
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

try:
    from gi.repository import GObject
except ImportError:
    import gobject as GObject

from bluetool import Bluetooth
from utils import print_info, print_error


class _Rejected(dbus.DBusException):
    _dbus_error_name = "org.bluez.Error.Rejected"


class Client(object):

    def authorize_service(self, dev_info, *args):
        """Should return None or raise _Rejected"""
        pass

    def request_pin_code(self, dev_info):
        """Should return str or int"""
        pass

    def request_passkey(self, dev_info):
        """Should return int"""
        pass

    def display_passkey(self, dev_info, *args):
        """Should return None or raise _Rejected"""
        pass

    def display_pin_code(self, dev_info, *args):
        """Should return None or raise _Rejected"""
        pass

    def request_confirmation(self, dev_info, *args):
        """Should return bool"""
        pass

    def request_authorization(self, dev_info):
        """Should return bool"""
        pass


_bluetooth = Bluetooth()


class Agent(dbus.service.Object):

    def __init__(
            self, client_class=None, timeout=180,
            path="/org/bluez/my_bluetooth_agent"):
        dbus.service.Object.__init__(self, dbus.SystemBus(), path)

        if client_class is not None:
            self._client = client_class()
        else:
            self._client = Client()

    def _trust(self, dbus_device):
        addr = self._dbus_device2addr(dbus_device)
        return _bluetooth.trust(addr)

    def _dbus_device2addr(self, dbus_device):
        address = str(dbus_device)
        address = address[len(address) - 17:len(address)]
        address = address.replace("_", ":")
        return address

    def _get_device_info(self, dbus_device):
        addr = self._dbus_device2addr(dbus_device)
        name = _bluetooth.get_device_property(addr, "Name")
        name = name.encode("utf-8") if name else "<unknown>"
        return {"mac_address": addr, "name": name}

    @dbus.service.method(
        "org.bluez.Agent1", in_signature="os", out_signature="")
    def AuthorizeService(self, device, uuid):
        print_info("AuthorizeService: {}, {}\n".format(device, uuid))
        dev_info = self._get_device_info(device)
        self._client.authorize_service(dev_info, str(uuid))

    @dbus.service.method(
        "org.bluez.Agent1", in_signature="o", out_signature="s")
    def RequestPinCode(self, device):
        print_info("RequestPinCode: {}\n".format(device))

        if not self._trust(device):
            print_error("RequestPinCode: failed to trust\n")
            raise _Rejected

        dev_info = self._get_device_info(device)

        try:
            pin_code = self._client.request_pin_code(dev_info)
            assert isinstance(pin_code, (str, int))
            return str(pin_code)
        except BaseException as error:
            print_error("RequestPinCode: {}\n".format(error))
            raise _Rejected

    @dbus.service.method(
        "org.bluez.Agent1", in_signature="o", out_signature="u")
    def RequestPasskey(self, device):
        print_info("RequestPasskey: {}\n".format(device))

        if not self._trust(device):
            print_error("RequestPasskey: failed to trust\n")
            raise _Rejected

        dev_info = self._get_device_info(device)

        try:
            passkey = int(self._client.request_passkey(dev_info))
        except BaseException as error:
            print_error("RequestPasskey: {}\n".format(error))
            raise _Rejected

        return dbus.UInt32(passkey)

    @dbus.service.method(
        "org.bluez.Agent1", in_signature="os", out_signature="")
    def DisplayPinCode(self, device, pincode):
        print_info("DisplayPinCode: {}: {}\n".format(device, pincode))
        dev_info = self._get_device_info(device)
        self._client.display_pin_code(dev_info, str(pincode))

    @dbus.service.method(
        "org.bluez.Agent1", in_signature="ouq", out_signature="")
    def DisplayPasskey(self, device, passkey, entered):
        print_info("DisplayPasskey: {}: {} entered {}\n".format(
            device, passkey, entered))
        dev_info = self._get_device_info(device)
        self._client.display_passkey(dev_info, str(passkey), str(entered))

    @dbus.service.method(
        "org.bluez.Agent1", in_signature="ou", out_signature="")
    def RequestConfirmation(self, device, passkey):
        print_info("RequestConfirmation: {}, {}\n".format(device, passkey))

        if not self._trust(device):
            print_error("RequestConfirmation: failed to trust\n")
            raise _Rejected

        dev_info = self._get_device_info(device)

        try:
            result = self._client.request_confirmation(dev_info, str(passkey))
        except BaseException as error:
            print_error("RequestConfirmation: {}\n".format(error))
            raise _Rejected

        print_info("RequestConfirmation: {}: {}\n".format(device, result))

        try:
            assert result == True
        except AssertionError:
            raise _Rejected

    @dbus.service.method(
        "org.bluez.Agent1", in_signature="o", out_signature="")
    def RequestAuthorization(self, device):
        print_info("RequestAuthorization: {}\n".format(device))

        if not self._trust(device):
            print_error("RequestAuthorization: failed to trust\n")
            raise _Rejected

        dev_info = self._get_device_info(device)

        try:
            result = self._client.request_authorization(dev_info)
        except BaseException as error:
            print_error("RequestAuthorization: {}\n".format(error))
            raise _Rejected

        print_info("RequestAuthorization: {}: {}\n".format(device, result))

        try:
            assert result == True
        except AssertionError:
            raise _Rejected


class AgentSvr(object):

    def __init__(
            self, client_class, timeout=180, capability="KeyboardDisplay",
            path="/org/bluez/my_bluetooth_agent"):
        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
        self.client_class = client_class
        self.timeout = timeout
        self.capability = capability
        self.path = path
        self._bus = dbus.SystemBus()
        self._mainloop = GObject.MainLoop()
        _bluetooth.make_discoverable(False)

    def run(self):
        _bluetooth.make_discoverable(True, self.timeout)
        _bluetooth.set_adapter_property("Pairable", dbus.Boolean(1))
        _bluetooth.set_adapter_property("PairableTimeout", dbus.UInt32(0))
        self.agent = Agent(self.client_class, self.timeout, self.path)

        if not self._register():
            self.shutdown()
            return

        self._mainloop.run()

    def _register(self):
        try:
            manager = dbus.Interface(
                self._bus.get_object("org.bluez", "/org/bluez"),
                "org.bluez.AgentManager1")
            manager.RegisterAgent(self.path, self.capability)
            manager.RequestDefaultAgent(self.path)
        except dbus.exceptions.DBusException as error:
            print_error(str(error) + "\n")
            return False

        return True

    def shutdown(self):
        _bluetooth.make_discoverable(False)
        self._mainloop.quit()
        self._unregister()

        try:
            self.agent.remove_from_connection()
            del self.agent
        except AttributeError:
            pass

    def _unregister(self):
        try:
            manager = dbus.Interface(
                self._bus.get_object("org.bluez", "/org/bluez"),
                "org.bluez.AgentManager1")
            manager.UnregisterAgent(self.path)
        except dbus.exceptions.DBusException:
            pass


if __name__ == "__main__":
    pass
