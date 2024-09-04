# vim:ft=c:sts=4:sw=4:et

package Geo::Proj::CCT;

$VERSION = '0.01';
use base 'Exporter';
use strict;

BEGIN { 
    sub linux_conf {(LIBS => '-lproj')} 

    sub mswin_conf {
        (myextlib => 'C:/OSGeo4W/bin/proj_9_4.dll',
         inc      => '-IC:/OSGeo4W/include');
    }

    for ($^O) {
        *my_conf = do {
            /linux/ && \&linux_conf ||
            /MSWin32/ && \&mswin_conf ||
            die "unknown OS $^O, bailing out";
        }
    }
}

sub new {
    my $class = shift;
    my $n = @_;
    my $pj;

    if ($n == 1) {
        my $src = shift;
        $pj = $class->create($src);
    }
    elsif ($n == 2) {
        my ($src, $tgt) = @_;
        $pj = $class->crs2crs($src,$tgt);
    }
    return $pj;
}

use Inline C => Config => my_conf ;

use Inline C => 'DATA',
    version => '0.01',
    name => 'Geo::Proj::CCT';

1;

__DATA__
__C__

#include <proj.h>
//#include <math.h>
# define M_PI 3.14159265358979323846

const char* version(const char *class) {
    PJ_INFO info = proj_info();
    return(info.version);
}
    
const char* definition(SV* p) {
    PJ *P = ((PJ*)SvIV(SvRV(p)));
    PJ_PROJ_INFO info = proj_pj_info(P);
    return(info.definition);
}

SV* create(const char *class, const char *src) {
    PJ *P = proj_create(0,src);
    SV *obj = newSV(0);
    sv_setref_pv(obj, class, (void *)P);
    return obj;
}

SV* crs2crs(const char *class, const char *src, const char* tgt) {
    PJ *P = proj_create_crs_to_crs(0,src,tgt,0);
    SV *obj = newSV(0);
    sv_setref_pv(obj, class, (void *)P);
    return obj;
}

SV* norm(SV* p) {
    char* class = HvNAME(SvSTASH(SvRV(p)));
    PJ *P = ((PJ*)SvIV(SvRV(p)));
    PJ *Q = proj_normalize_for_visualization(0, P);
    SV *obj = newSV(0);
    sv_setref_pv(obj, class, (void *)Q);
    return obj;
}

SV* trans(SV* p, int dirn, SV* coord_ref) {
    int n;
    if ((!SvROK(coord_ref)) || (SvTYPE(SvRV(coord_ref)) != SVt_PVAV)
        || ((n = av_len((AV *)SvRV(coord_ref))) < 0)) {
        return &PL_sv_undef;
    }
    n = n>3 ? 3 : n;    
    AV* coord = (AV*) SvRV(coord_ref);
    PJ *P = ((PJ*)SvIV(SvRV(p)));
    PJ_COORD a = {{0.0, 0.0, 0.0, 0.0}};
    for (int i=0; i<=n; i++) {
        a.v[i] = SvNV(*av_fetch(coord, i, 0)); 
    }
    PJ_COORD b = proj_trans(P, dirn, a);
    AV* res = newAV();
    for (int i=0; i<=n; i++) {
        av_push(res, newSVnv(b.v[i]));
    }
    return newRV_noinc((SV*) res);
}

SV* fwd(SV* p, SV* coord_ref) {
    return(trans(p,1,coord_ref));
}

SV* inv(SV* p, SV* coord_ref) {
    return(trans(p,-1,coord_ref));
}

SV* geod(SV* p, SV* a_ref, SV* b_ref) {
    int n;
    AV* coord;

    PJ *P = ((PJ*)SvIV(SvRV(p)));

    if ((!SvROK(a_ref)) || (SvTYPE(SvRV(a_ref)) != SVt_PVAV)
        || ((n = av_len((AV *)SvRV(a_ref))) < 0)) {
        return &PL_sv_undef;
    }
    n = n>3 ? 3 : n;    
    coord = (AV*) SvRV(a_ref);
    PJ_COORD a = {{0.0, 0.0, 0.0, 0.0}};
    for (int i=0; i<=n; i++) {
        a.v[i] = SvNV(*av_fetch(coord, i, 0)) * M_PI / 180;
    }

    if ((!SvROK(b_ref)) || (SvTYPE(SvRV(b_ref)) != SVt_PVAV)
        || ((n = av_len((AV *)SvRV(b_ref))) < 0)) {
        return &PL_sv_undef;
    }
    n = n>3 ? 3 : n;    
    coord = (AV*) SvRV(b_ref);
    PJ_COORD b = {{0.0, 0.0, 0.0, 0.0}};
    for (int i=0; i<=n; i++) {
        b.v[i] = SvNV(*av_fetch(coord, i, 0)) * M_PI / 180;
    }

    PJ_COORD c = proj_geod(P, a, b);
    AV* res = newAV();
    for (int i=0; i<3; i++) {
        av_push(res, newSVnv(c.v[i]));
    }
    return newRV_noinc((SV*) res);
}

void DESTROY(SV* obj) {
    PJ* P = (PJ*)SvIV(SvRV(obj));
    proj_destroy(P);
}
