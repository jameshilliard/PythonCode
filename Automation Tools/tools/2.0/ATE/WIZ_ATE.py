#!/usr/bin/env python
# -*- coding: utf-8 -*-

r"""

"""
#
#       wiz_ate.py
#
#       Copyright 2011 rayofox <lhu@actiontec.com>
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

from netcli.netcli import NetCLI


class daemonATE(NetCLI):
    """
    """

    def __init__(self):
        """
        """
        pass


def main():
    """
    """
    print 'hello man!'
    # start server
    HOST, PORT = "0.0.0.0", 8023
    ds = daemonATE()
    ds.Run(HOST, PORT)

    return 0


if __name__ == '__main__':
    main()

