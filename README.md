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
available (or where the processing script failed to retrieve it), text is
aggregated under one file with time "99_99_99". The president gets its own
party ("pres"), same for "statsråd", statsminister and utenriksminister.
"unknown" is a default category for errors in the extraction process, where we
weren't able to extract metadata automatically (on a brief inspection, this
seems to be mostly from the president or from other html files that don't
follow the format of the ordinary storting sessions, like meetings).

Some rough word counts per party:

| party            | # words  |
|:----------------:| --------:|
| pres             | 47174495 |
| statsrad         |  5084266 |
| a                |  1915604 |
| h                |  1735730 |
| frp              |  1669400 |
| krf              |   876603 |
| sv               |   870413 |   
| sp               |   609380 |
| utenriksminister |   539487 |
| v                |   504627 |
| unknown          |   132060 |
| statsminister    |   109873 | 
| tf               |    25531 |
| mdg              |    23198 |
| kp               |    22320 |
| uav              |     8847 |

## Get the html data

To get the raw html data, from the top level directory, call:

    ./scripts/install_raw_data.sh

## Process the data

From the top level directory, call:
    rm -rf data/processed/ ;  python scripts/cleanup.py stortinget data/stortinget.no/no/Saker-og-publikasjoner/Publikasjoner/Referater/Stortinget/
