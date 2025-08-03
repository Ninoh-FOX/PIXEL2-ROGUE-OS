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
import dbus.mainloop.glib
import threading
import time
import bluezutils
from utils import print_error


class Bluetooth(object):

    def __init__(self):
        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
        self._bus = dbus.SystemBus()
        self._scan_thread = None

    def start_scanning(self, timeout=10):
        if self._scan_thread is None:
            self._scan_thread = threading.Thread(
                target=self.scan, args=(timeout,))
            self._scan_thread.daemon = True
            self._scan_thread.start()

    def scan(self, timeout=10):
        try:
            adapter = bluezutils.find_adapter()
        except (bluezutils.BluezUtilError,
                dbus.exceptions.DBusException) as error:
            print_error(str(error) + "\n")
        else:
            try:
                adapter.StartDiscovery()
                time.sleep(timeout)
                adapter.StopDiscovery()
            except dbus.exceptions.DBusException as error:
                print_error(str(error) + "\n")

        self._scan_thread = None

    def get_devices_to_pair(self):
        devices = self.get_available_devices()

        for key in self.get_paired_devices():
            devices.remove(key)

        return devices

    def get_available_devices(self):
        return self._get_devices("Available")

    def get_paired_devices(self):
        return self._get_devices("Paired")

    def get_connected_devices(self):
        return self._get_devices("Connected")

    def _get_devices(self, condition):
        devices = []
        conditions = ("Available", "Paired", "Connected")

        if condition not in conditions:
            print_error("_get_devices: unknown condition - {}\n".format(
                condition))
            return devices

        try:
            man = dbus.Interface(
                self._bus.get_object("org.bluez", "/"),
                "org.freedesktop.DBus.ObjectManager")
            objects = man.GetManagedObjects()

            for path, interfaces in objects.items():
                if "org.bluez.Device1" in interfaces:
                    dev = interfaces["org.bluez.Device1"]

                    if condition == "Available":
                        if "Address" not in dev:
                            continue

                        if "Name" not in dev:
                            dev["Name"] = "<unknown>"

                        device = {
                            "mac_address": dev["Address"].encode("utf-8"),
                            "name": dev["Name"].encode("utf-8")
                        }

                        devices.append(device)
                    else:
                        props = dbus.Interface(
                            self._bus.get_object("org.bluez", path),
                            "org.freedesktop.DBus.Properties")

                        if props.Get("org.bluez.Device1", condition):
                            if "Address" not in dev:
                                continue

                            if "Name" not in dev:
                                dev["Name"] = "<unknown>"

                            device = {
                                "mac_address": dev["Address"].encode("utf-8"),
                                "name": dev["Name"].encode("utf-8")
                            }

                            devices.append(device)
        except dbus.exceptions.DBusException as error:
            print_error(str(error) + "\n")

        return devices

    def make_discoverable(self, value=True, timeout=180):
        try:
            adapter = bluezutils.find_adapter()
        except (bluezutils.BluezUtilError,
                dbus.exceptions.DBusException) as error:
            print_error(str(error) + "\n")
            return False

        try:
            props = dbus.Interface(
                self._bus.get_object("org.bluez", adapter.object_path),
                "org.freedesktop.DBus.Properties")

            timeout = int(timeout)
            value = int(value)

            if int(props.Get(
                    "org.bluez.Adapter1", "DiscoverableTimeout")) != timeout:
                props.Set(
                    "org.bluez.Adapter1", "DiscoverableTimeout",
                    dbus.UInt32(timeout))

            if int(props.Get("org.bluez.Adapter1", "Discoverable")) != value:
                props.Set(
                    "org.bluez.Adapter1", "Discoverable", dbus.Boolean(value))
        except dbus.exceptions.DBusException as error:
            print_error(str(error) + "\n")
            return False

        return True

    def start_pairing(self, address, callback=None, args=()):
        pair_thread = threading.Thread(
            target=self._pair_trust_and_notify,
            args=(address, callback, args))
        pair_thread.daemon = True
        pair_thread.start()

    def _pair_trust_and_notify(self, address, callback=None, args=()):
        result = self.pair(address)

        if callback is not None:
            if result:
                result = self.trust(address)
            callback(result, *args)

    def pair(self, address):
        try:
            device = bluezutils.find_device(address)
        except (bluezutils.BluezUtilError,
                dbus.exceptions.DBusException) as error:
            print_error(str(error) + "\n")
            return False

        try:
            props = dbus.Interface(
                self._bus.get_object("org.bluez", device.object_path),
                "org.freedesktop.DBus.Properties")

            if not props.Get("org.bluez.Device1", "Paired"):
                device.Pair()
        except dbus.exceptions.DBusException as error:
            print_error(str(error) + "\n")
            return False

        return True

    def connect(self, address):
        try:
            device = bluezutils.find_device(address)
        except (bluezutils.BluezUtilError,
                dbus.exceptions.DBusException) as error:
            print_error(str(error) + "\n")
            return False

        try:
            props = dbus.Interface(
                self._bus.get_object("org.bluez", device.object_path),
                "org.freedesktop.DBus.Properties")

            if not props.Get("org.bluez.Device1", "Connected"):
                device.Connect()
        except dbus.exceptions.DBusException as error:
            print_error(str(error) + "\n")
            return False

        return True

    def disconnect(self, address):
        try:
            device = bluezutils.find_device(address)
        except (bluezutils.BluezUtilError,
                dbus.exceptions.DBusException) as error:
            print_error(str(error) + "\n")
            return False

        try:
            props = dbus.Interface(
                self._bus.get_object("org.bluez", device.object_path),
                "org.freedesktop.DBus.Properties")

            if props.Get("org.bluez.Device1", "Connected"):
                device.Disconnect()
        except dbus.exceptions.DBusException as error:
            print_error(str(error) + "\n")
            return False

        return True

    def trust(self, address):
        try:
            device = bluezutils.find_device(address)
        except (bluezutils.BluezUtilError,
                dbus.exceptions.DBusException) as error:
            print_error(str(error) + "\n")
            return False

        try:
            props = dbus.Interface(
                self._bus.get_object("org.bluez", device.object_path),
                "org.freedesktop.DBus.Properties")

            if not props.Get("org.bluez.Device1", "Trusted"):
                props.Set("org.bluez.Device1", "Trusted", dbus.Boolean(1))
        except dbus.exceptions.DBusException as error:
            print_error(str(error) + "\n")
            return False

        return True

    def remove(self, address):
        try:
            adapter = bluezutils.find_adapter()
            dev = bluezutils.find_device(address)
        except (bluezutils.BluezUtilError,
                dbus.exceptions.DBusException) as error:
            print_error(str(error) + "\n")
            return False

        try:
            adapter.RemoveDevice(dev.object_path)
        except dbus.exceptions.DBusException as error:
            print_error(str(error) + "\n")
            return False

        return True

    def set_adapter_property(self, prop, value):
        try:
            adapter = bluezutils.find_adapter()
        except (bluezutils.BluezUtilError,
                dbus.exceptions.DBusException) as error:
            print_error(str(error) + "\n")
            return False

        try:
            props = dbus.Interface(
                self._bus.get_object("org.bluez", adapter.object_path),
                "org.freedesktop.DBus.Properties")

            if props.Get("org.bluez.Adapter1", prop) != value:
                props.Set("org.bluez.Adapter1", prop, value)
        except dbus.exceptions.DBusException as error:
            print_error(str(error) + "\n")
            return False

        return True

    def get_adapter_property(self, prop):
        try:
            adapter = bluezutils.find_adapter()
        except (bluezutils.BluezUtilError,
                dbus.exceptions.DBusException) as error:
            print_error(str(error) + "\n")
            return None

        try:
            props = dbus.Interface(
                self._bus.get_object("org.bluez", adapter.object_path),
                "org.freedesktop.DBus.Properties")

            return props.Get("org.bluez.Adapter1", prop)
        except dbus.exceptions.DBusException as error:
            print_error(str(error) + "\n")
            return None

    def set_device_property(self, address, prop, value):
        try:
            device = bluezutils.find_device(address)
        except (bluezutils.BluezUtilError,
                dbus.exceptions.DBusException) as error:
            print_error(str(error) + "\n")
            return False

        try:
            props = dbus.Interface(
                self._bus.get_object("org.bluez", device.object_path),
                "org.freedesktop.DBus.Properties")

            if props.Get("org.bluez.Device1", prop) != value:
                props.Set("org.bluez.Device1", prop, value)
        except dbus.exceptions.DBusException as error:
            print_error(str(error) + "\n")
            return False

        return True

    def get_device_property(self, address, prop):
        try:
            device = bluezutils.find_device(address)
        except (bluezutils.BluezUtilError,
                dbus.exceptions.DBusException) as error:
            print_error(str(error) + "\n")
            return None

        try:
            props = dbus.Interface(
                self._bus.get_object("org.bluez", device.object_path),
                "org.freedesktop.DBus.Properties")

            return props.Get("org.bluez.Device1", prop)
        except dbus.exceptions.DBusException as error:
            print_error(str(error) + "\n")
            return None
