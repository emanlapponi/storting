#!/bin/bash
sessions=(2013-2017 2009-2013 2005-2009 2001-2005 1997-2001)
session_start=(`seq 1998 1 2016`)
session_end=(`seq 1999 1 2017`)
index=(`seq 1 1 19`)

for i in ${index[@]}; do
  session[$i]=${session_start[$i]}-${session_end[$i]}
done
echo ${session[@]}

for i in ${session[@]}; do
  wget "https://data.stortinget.no/eksport/moter?sesjonid="$i
done
