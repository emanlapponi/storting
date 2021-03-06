# old readme.md

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


# storting

This is a repo for work-in-progress pre-processing of the freely 
accessible data on www.stortinget.no.

[2016:04:15]

This readme is now outdated, moving it to notes.

## Current test call:

    rm -rf data/processed/ ; python scripts/cleanup.py stortinget data/stortinget.no/no/Saker-og-publikasjoner/Publikasjoner/Referater/Stortinget/2007-2008/080616/2/

## Status

[2016:03:22]
The cleanup script is looking good now! See example output for the current test call under
    
    data/processed/

[2016:03:17] 
I've done some initial testing with possibly bonkers extraction 
heuristics, but still expose some challanges with preprocessing,
namely:


- both party names (a, ap) and speaker names (Carl I. Hagen, Carl I Hagen, Carl l. Hagen) are inconsistent
- the actual speech seems to non-deterministically span across several tags in some cases
- conversations break abruptly, so we are probably not seeing some data

See scripts/cleanup.py for the WIP scripts and data/processed/ 
for the WIP output

## Easter meeting

## Example 1

data/www.stortinget.no/no/Saker-og-publikasjoner/Publikasjoner/Referater/Stortinget/2009-2010/100616/index.html

First clue / start of the debate:

A div box with info about the president:

    <div class="large-7 large-offset-2 medium-8 columns">
        <h1>
            Stortinget - Møte onsdag den 16. juni 2010 kl. 10</h1>
        <p>
            
                <strong>Dato:</strong> 16.06.2010<br />
            
            
                <strong>President:</strong> Marit Nybakk
            
            <br />
            <strong>Dokumenter:</strong> (<a href="/no/Saker-og-publikasjoner/Publikasjoner/Innstillinger/Stortinget/2009-2010/inns-200910-345/">Innst. 345 S (2009–2010)</a>, jf. <a href="http://www.regjeringen.no/id/PRP200920100124000DDDEPIS">Prop. 124 S (2009–2010)</a>)
            
        </p>
    </div>

Most importantly: each speaker starts with this comment / name / party string:

    </p><p class="ref-uinnrykk"><a id="a3.2" class="ref-innlegg-navn"><!-- TALERINITIALER="TROH", TALETIDSPUNKT="10:56:33" -->Trond Helleland (H) [10:56:33]:</a> Jeg brukte ganske store deler av mitt innlegg på å forklare nettopp det, men jeg kan godt gjenta det.

a non-deterministic number of paragraphs follows, until the next speaker comes in with the same string.
