# storting

This is a repo for work-in-progress pre-processing of the freely 
accessible data on www.stortinget.no.

## Data, so far

The data extracted and partially manually corrected is in the 'redacted'
folder. It is currently metadata organized as a directory tree, as follows:

    party
     |_speaker
        |_date
          |_time.txt

Where "time.txt" is a file containing the text. Where the time was not
available (or where the processing script failed to retrieve it), text
is aggregated under one file with time "99_99_99"




## Get the html data

To get the raw html data, from the top level directory, call:

    ./scripts/install_raw_data.sh

## Process the data

From the top level directory, call:
    rm -rf data/processed/ ;  python scripts/cleanup.py stortinget data/stortinget.no/no/Saker-og-publikasjoner/Publikasjoner/Referater/Stortinget/
