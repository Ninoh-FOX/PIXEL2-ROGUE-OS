#  Copyright (C) Emlid Limited - All Rights Reserved
#  All information contained in this file is the property of Emlid Limited.
#  The intellectual and technical concepts contained herein are proprietary to
#  Emlid Limited and are protected by copyright law. Distribution of this
#  information or reproduction of this material is strictly forbidden without
#  written permission obtained from Emlid Limited.
#  Written by Denis Chagin <denis.chagin@emlid.com>


import sys
import socket
import select
import threading
from Queue import Queue, Empty
from sink import SinkError, SocketSink
from tcp_server import TCPServer, TCPError


class TCPBridgeError(Exception):
    pass


class TCPBridge(object):
    SELECT_TIMEOUT = 0.1

    def __init__(self, sink, port_in=9000, port_out=None):
        self.tcp_queue, self.sink_queue = Queue(), Queue()
        self.sink = sink
        self.tcp_in = TCPServer(port_in)
        if port_out:
            self.tcp_out = TCPServer(port_out)
        else:
            self.tcp_out = self.tcp_in
        self.workers = []
        self.interrupt = threading.Event()

    def start(self, in_background=True):
        if not self.workers:
            try:
                self.interrupt.clear()

                self.tcp_in.initialize()
                self.workers.append(
                    threading.Thread(target=self._run_tcp, args=(self.tcp_in,)))

                if self.tcp_in != self.tcp_out:
                    self.tcp_out.initialize()
                    self.workers.append(threading.Thread(target=self._run_tcp,
                                                         args=(self.tcp_out,)))

                if in_background:
                    self.workers.append(threading.Thread(target=self._run_sink))

                for worker in self.workers:
                    worker.start()

                if not in_background:
                    self._run_sink()

            except TCPError as error:
                raise TCPBridgeError(str(error))

    def stop(self):
        if self.workers:
            self.interrupt.set()

            for worker in self.workers:
                worker.join()
            self.workers = []

            self.tcp_in.close()
            self.tcp_out.close()
            self.sink.close()

    def _run_tcp(self, endpoint):
        while not self.interrupt.is_set():
            try:
                endpoint.accept_connection()
                while not self.interrupt.is_set():
                    self._process_endpoint_data(endpoint, self.sink_queue)
                    if endpoint == self.tcp_out:
                        self._process_queue(self.tcp_queue, endpoint)
            except TCPError:
                pass
            endpoint.close_client()

    def _run_sink(self):
        while not self.interrupt.is_set():
            try:
                self._process_endpoint_data(self.sink, self.tcp_queue)
                self._process_queue(self.sink_queue, self.sink)
            except SinkError:
                self.interrupt.set()

    def _process_endpoint_data(self, endpoint, queue):
        try:
            r, w, e = select.select([endpoint.fileno], [], [],
                                    self.SELECT_TIMEOUT)

            if not r:
                return

            data = endpoint.read()
            if self.tcp_out.has_connection or endpoint == self.tcp_in:
                queue.put_nowait(data)
        except ValueError as error:
            raise SinkError(str(error))

    @staticmethod
    def _process_queue(queue, endpoint):
        try:
            data = queue.get_nowait()
            endpoint.write(data)
        except Empty:
            pass


if __name__ == '__main__':

    ports = {'port_in': 9000}

    if len(sys.argv) > 1:
        if sys.argv[1] == '--dual':
            ports = {'port_in': 9000, 'port_out': 9001}

    svr_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    svr_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    svr_sock.bind(('localhost', 9002))
    svr_sock.listen(1)

    cli_sock, _ = svr_sock.accept()
    socket_sink = SocketSink(sock=cli_sock)

    bridge = TCPBridge(sink=socket_sink, **ports)
    bridge.start()
