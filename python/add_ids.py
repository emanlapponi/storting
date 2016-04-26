import csv
import sys

if len(sys.argv) != 3:
    "Usage: python python/add_ids.py input_file output_file"

infname = sys.argv[1]
outfname = sys.argv[2]

cr = csv.DictReader(open(infname))

with open(outfname, 'w') as of:
    fn = cr.fieldnames[:]
    fn.insert(0, 'id')
    cw = csv.DictWriter(of, fieldnames=fn, lineterminator='\n')
    cw.writeheader()
    for i, l in enumerate(cr):
        l['id'] = 'tale%s' % (str(i).zfill(6))
        cw.writerow(l)
