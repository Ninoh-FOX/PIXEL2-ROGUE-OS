#  Copyright (C) Emlid Limited - All Rights Reserved
#  All information contained in this file is the property of Emlid Limited.
#  The intellectual and technical concepts contained herein are proprietary to
#  Emlid Limited and are protected by copyright law. Distribution of this
#  information or reproduction of this material is strictly forbidden without
#  written permission obtained from Emlid Limited.
#  Written by Denis Chagin <denis.chagin@emlid.com>


import abc
import socket
import threading
import select

BUFFER_SIZE = 2048


class SinkError(Exception):
    pass


class AbstractSink(object):
    __metaclass__ = abc.ABCMeta

    @abc.abstractmethod
    def read(self):
        pass

    @abc.abstractmethod
    def write(self, data):
        pass

    @abc.abstractmethod
    def close(self):
        pass

    @abc.abstractproperty
    def fileno(self):
        pass


class SocketSink(AbstractSink):
    SELECT_TIMEOUT = 0.1

    def __init__(self, sock):
        self.sock = sock

    def read(self):
        try:
            data = self.sock.recv(BUFFER_SIZE)
            if not data:
                raise SinkError
            return data
        except socket.error as error:
            raise SinkError(str(error))

    def write(self, data):
        try:
            r, w, e = select.select([], [self.fileno], [], self.SELECT_TIMEOUT)
            if w:
                _bytes = self.sock.send(data)
                return _bytes
        except (ValueError, socket.error) as error:
            raise SinkError(str(error))

    def close(self):
        self.sock.close()

    @property
    def fileno(self):
        return self.sock.fileno()


class FileSink(AbstractSink):
    def __init__(self, file_object):
        self.file_object = file_object

    def write(self, data):
        self.file_object.write(data)
        self.file_object.flush()

    def read(self):
        try:
            data = self.file_object.read(BUFFER_SIZE)
            return data
        except ValueError as error:
            raise SinkError(str(error))

    def close(self):
        try:
            self.file_object.close()
        except IOError:
            pass

    @property
    def fileno(self):
        return self.file_object
