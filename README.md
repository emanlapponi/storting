# storting

This is a repo for work-in-progress pre-processing of the freely 
accessible data on www.stortinget.no.

## Get the data

To get the raw html data, from the top level directory, call:

    ./scripts/install_raw_data.sh

## Process the data

From the top level directory, call:
  rm -rf data/processed/ ;  python scripts/cleanup.py stortinget data/stortinget.no/no/Saker-og-publikasjoner/Publikasjoner/Referater/Stortinget/

