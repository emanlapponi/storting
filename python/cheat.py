import sys
import csv
import codecs
import os

"""
This is the script used to extract the text bit so that it
can be fed directly to behind-the-scene LAP. In principle,
we should go directly to the LAPSTORE and work on the
database itself, This will have to do for now.

"""


infile = sys.argv[1]
outfolder = sys.argv[2]

for i, l in enumerate(csv.reader(open(infile))):
    if i > 0:
        outfile = codecs.open(os.path.join(outfolder, l[0]), 'w', 'utf8')
        outfile.write(l[-1].decode('utf8'))
        outfile.close()
