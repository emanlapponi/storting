# storting

This is a repo for work-in-progress pre-processing of the freely 
accessible data on www.stortinget.no.

## Current test call:

    rm -rf data/processed/ ; python scripts/cleanup.py stortinget data/www.stortinget.no/no/Saker-og-publikasjoner/Publikasjoner/Referater/Stortinget/2007-2008/080616/2/

## Status

[2016:03:22]
The cleanup script is looking good now! See example output for the current test call under
    data/processed

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


    