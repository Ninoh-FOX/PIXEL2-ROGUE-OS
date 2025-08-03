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

import sys


def print_error(*objs):
    objs = [str(obj) for obj in objs]
    sys.stderr.write(", ".join(objs))
    sys.stderr.flush()


def print_info(*objs):
    objs = [str(obj) for obj in objs]
    sys.stdout.write(", ".join(objs))
    sys.stdout.flush()
