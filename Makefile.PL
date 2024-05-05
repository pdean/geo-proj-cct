use v5.36;
use Inline::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Geo::Proj::CCT',
    VERSION_FROM      => 'lib/Geo/Proj/CCT.pm', # finds $VERSION, requires EU::MM from perl >= 5.5
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ABSTRACT_FROM     => 'lib/Geo/Proj/CCT.pm', # retrieve abstract from module
    AUTHOR            => 'A. U. Thor <peter@nonet>',
    #LICENSE           => 'perl',
    #Value must be from legacy list of licenses here
    #https://metacpan.org/pod/Module::Build::API
    CONFIGURE_REQUIRES => {
        'Inline::MakeMaker' => 0.45,
        'ExtUtils::MakeMaker' => 6.52,
    },
);
