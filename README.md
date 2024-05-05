# Geo::Proj::CCT
perl interface to proj.org library conversions and transformations

This is a work in progress but already quite usable.  See examples folder.
Manpage in lib/Geo/Proj/CCT.pod

Installation

On linux  

proj needs to be installed including development library  

perl Makefile.pl  && make &&  make test  && make install  

On Windows  

If the proj library is installed using OSGeo4W, it may just work with Strawberry
perl.  Otherwise check out lib/Proj.pm and edit the sub mswin_conf.  
