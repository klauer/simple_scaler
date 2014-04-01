"""
Read the simple_scaler output from the USB serial port (ttyUSB)

Usage
-----

Linux:
    % python count.py /dev/ttyUSB0
Windows (COM22 for example):
    % python count.py 22
"""

from __future__ import print_function
import sys
import serial
import struct
import time

PREFIX = 'STRT'
N_COUNTERS = 16
N_BYTES_COUNTER = 4
PACKET_LEN = N_BYTES_COUNTER * N_COUNTERS

def eval_packet(packet):
    if N_BYTES_COUNTER < 4:
        counts = []
        while packet:
            counts.append(packet[:N_BYTES_COUNTER])
            packet = packet[N_BYTES_COUNTER:]

        pad = '\0' * (4 - N_BYTES_COUNTER)
        counts = [struct.unpack_from('<I', c + pad) for c in counts]
    else:
        counts = struct.unpack_from('<' + 'I' * N_COUNTERS, packet)

    return counts


def main(port):
    ser = serial.Serial(port, 9600)
    print('Port %s opened' % port)
    buf = ''
    try:
        while True:
            inp = buf + ser.read(PACKET_LEN + len(PREFIX))
            if PREFIX in inp:
                packets = inp.split(PREFIX)
                for packet in packets:
                    if len(packet) == PACKET_LEN:
                        print(eval_packet(packet))
                        inp = ''

            buf = inp
            time.sleep(0.2)

    except KeyboardInterrupt:
        pass


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Usage: %s [port]' % sys.argv[0])
        sys.exit(1)

    port = sys.argv[1]

    try:
        # COM port numbers are one off
        port = int(port) - 1
    except:
        pass

    main(port)


