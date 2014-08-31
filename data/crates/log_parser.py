#!/usr/bin/python

import os, sys
from optparse import OptionParser

def parse_tr(dtype, out_f, in_flist):
    if (os.path.isfile(out_f)):
        of = open(out_f, "a") 
    else:
        of = open(out_f, "w") 
        of.write("id, run, sent, received\n") 
    data = { } 
    for in_f in in_flist:
        f = open(in_f, "r")
        run_data = { } 
        largest_tx = 0; 
        for line in f:
            record = line.split(',')
            if record[0] == 'run':
                continue
            record = [ int (r) for r in record ]
            if record[0] not in run_data or run_data[record[0]][0] < record[1]:
                run_data[record[0]] = record[1:]
        for k,v in run_data.iteritems():
            if k not in data:
                data[k] = v
            else:
                data[k][0] += v[0]
                data[k][1] += v[1]
    for k,v in data.iteritems():
        of.write("{0}, {1}, {2}, {3}\n".format(dtype, k, v[0], v[1]))

def parse_com_log(dtype, out_f, in_f):
    f = open(in_f, "r")
    if (os.path.isfile(out_f)):
        of = open(out_f, "a") 
    else:
        of = open(out_f, "w") 
        of.write("id, run, distance, success\n") 
    run = 0 
    prev_is_new = False
    for line in f:
        if line[0] == '=':
            if not prev_is_new: 
                run += 1
            prev_is_new = True
            continue
        of.write("{0}, {1}, {2}".format(dtype, run, line))
        prev_is_new = False
    f.close()
    of.close()

def main():
    if (len(sys.argv) < 3):
        print "Call this: python log_parser.py <identifier> communication.log UAV*.tr"
        sys.exit()
    parse_com_log(sys.argv[1], "prr_data.csv", sys.argv[2])
    parse_tr(sys.argv[1], "collection_data.csv", sys.argv[3:])

if __name__ == "__main__":
    main()
