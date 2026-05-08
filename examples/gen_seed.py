#!/bin/env python

import datetime
import sys
import math
import struct

def main(argv):
    fh = open('gen_seed.opal', 'w')
    now = datetime.datetime.now()

    timestamp = datetime.datetime.now().timestamp() * math.pow(10, 9)
    itimestamp = struct.unpack('!Q', struct.pack('!d', timestamp))[0]
    timestamp = datetime.datetime(now.year, now.month, now.day).timestamp() * math.pow(10, 9)
    itimestamp = itimestamp - struct.unpack('!Q', struct.pack('!d', timestamp))[0]
    sitimestamp = (itimestamp >> 25) << 25
    itimestamp = itimestamp - sitimestamp

    fh.write('REAL genseed = %d;\n' % itimestamp)

    fh.close()

if __name__ == "__main__":
    main(sys.argv[1:])