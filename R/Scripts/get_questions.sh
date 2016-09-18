#!/bin/bash
session_start=(`seq 1998 1 2016`)
session_end=(`seq 1999 1 2017`)
index=(`seq 1 1 19`)

for i in ${index[@]}; do
session[$i]=${session_start[$i]}-${session_end[$i]}
done
echo ${session[@]}

for i in ${session[@]}; do
wget "http://data.stortinget.no/eksport/sporretimesporsmal?sesjonid="$i
done

# beacuse of non-standard link the 1998/1999 session is downloaded manually
wget "http://data.stortinget.no/eksport/sporretimesporsmal?sesjonid=1998-99"

# and reanaming
mv sporretimesporsmal\?sesjonid=1998-99 sporretimesporsmal\?sesjonid=1998-1999
