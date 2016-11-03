# Storting
A repository for the code behind the [Talk of Norway data](https://github.com/emanlapponi/talk-of-norway) -- an ongoing collaberation project between the Department of Informatics and Department of Political Science, at the University of Oslo. The project aims at analyzing parliamentary debates from the Norwegian Storting in various ways. Our data builds on the brilliant work done by [Holder de ord](https://github.com/holderdeord).

## Status
[2016-11-03] The data are now released on the new [Talk of Norway data](https://github.com/emanlapponi/talk-of-norway) repository. This repository will mainly be used for maintaining and updating the data.

[2016-09-06] Have started to download and structure data for meeting and issue metadata, such as name of the committee that treated the bill under question.

[2016-09-02] Included committee membership, date interval of committee membership, and role in the committee for each reprepresentative in each parliamentary period.

[2016-08] Have fixed a couple of bugs in the dataset where the parliamentary session was misspecified, giving some unexpected missing data. Follow the link below to get the new dataset.

[2016-05-25] There has been some major changes because we found a lot of missing data on representatives in the previous commit. These were typically deputy representatives. Thus, we downloaded the biografies from [stortinget.no](https://www.stortinget.no/no/Representanter-og-komiteer/Representantene/Biografier/), and structure these. The complete data -- also with ids from add\_ids.py -- in its current state is called [id\_taler\_meta.csv](http://folk.uio.no/martigso/storting). ~~About 250 speeches still lack big parts of meta data, and these will probably need to be coded manually.~~

[2016-04-27] R code is now functional for producing metadata for the speeches. All scripts will run with "./R/" as root. The main script -- "./R/Scripts/wrap\_up.R" will produce the file [taler\_meta.csv](http://folk.uio.no/martigso/storting/). But, be aware that parts of this script, such as source call on "taler_prep.R", builds on external data; it will not work without these.
