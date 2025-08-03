#  Copyright (C) Emlid Limited - All Rights Reserved
#  All information contained in this file is the property of Emlid Limited.
#  The intellectual and technical concepts contained herein are proprietary to
#  Emlid Limited and are protected by copyright law. Distribution of this
#  information or reproduction of this material is strictly forbidden without
#  written permission obtained from Emlid Limited.
#  Written by Denis Chagin <denis.chagin@emlid.com>


import socket
import select

BUFFER_SIZE = 2048


class TCPError(Exception):
    pass


class TCPServer(object):
    def __init__(self, port=9000):
        self.address = ('localhost', port)
        self.svr_sock = None
        self.cli_sock = None

    def initialize(self):
        try:
            self.svr_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.svr_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.svr_sock.bind(self.address)
            self.svr_sock.listen(1)
        except socket.error as error:
            raise TCPError(str(error))

    def accept_connection(self):
        r, w, e = select.select([self.svr_sock], [], [], 1)

        if not r:
            raise TCPError("Timed out for waiting TCP connection")

        try:
            self.cli_sock, info = self.svr_sock.accept()
        except socket.error as error:
            raise TCPError(str(error))
        return info

    def close(self):
        try:
            self.svr_sock.close()
        except AttributeError:
            pass

    def close_client(self):
        try:
            self.cli_sock.close()
            self.cli_sock = None
        except AttributeError:
            pass

    def read(self):
        try:
            data = self.cli_sock.recv(BUFFER_SIZE)
            if not data:
                raise TCPError('Connection Lost')
            return data
        except socket.error as error:
            raise TCPError(str(error))

    def write(self, data):
        try:
            return self.cli_sock.send(data)
        except socket.error as error:
            raise TCPError(str(error))

    @property
    def fileno(self):
        return self.cli_sock

    @property
    def has_connection(self):
        if self.cli_sock:
            return True
        return False
