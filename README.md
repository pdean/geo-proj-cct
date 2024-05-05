# Geo::Proj::CCT

perl interface to proj.org library conversions and transformations

## INSTALLATION

To install this module type the following:

   perl Makefile.PL  
   make   
   make test  
   make install 

## DEPENDENCIES

This module requires these other modules and libraries:

Inline::C  
proj shared library and headers.   

eg on Debian - apt install proj-bin proj-data libproj-dev

On Windows via OSGeo4W, the make should just work with Strawberry perl.
Otherwise need to tweak mswin_conf in CCT.pm

## COPYRIGHT AND LICENCE

Copyright 2024 by Peter Dean

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.38.2 or,
at your option, any later version of Perl 5 you may have available.


