# storting

This is a repo for work-in-progress pre-processing of the freely 
accessible data on www.stortinget.no.

## Status

[2016:03:17] 
I've done some initial testing with possibly bonkers extraction 
heuristics, but still expose some challanges with preprocessing,
namely:
    - both party names (a, ap) and speaker names (Carl I. Hagen, Carl I Hagen, Carl l. Hagen) are inconsistent
    - the actual speech seems to non-deterministically span across several tags in some cases
    - conversations break abruptly, so we are probably not seeing some data

See scripts/cleanup.py for the WIP scripts and data/processed/ 
for the WIP output
