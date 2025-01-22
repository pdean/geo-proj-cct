use v5.36;

# -------------------------------------------

package Point;
use Moo;
has [qw(id x y z )]  => ( is => 'ro', required => 1 );
has [qw(desc style)] => ( is => 'ro' );

# -------------------------------------------

package Style;
use Moo;
has [qw(id color href)] => ( is => 'ro', required => 1 );

# -------------------------------------------

package Project;
use Moo;
use XML::LibXML;

has name                => ( is => 'ro', required => 1 );
has [qw(points styles)] => ( is => 'ro', default  => sub { return [] } );

sub point_add {
    my ( $self, $point ) = @_;
    push @{ $self->points }, $point;
    return $self;
}

sub style_add {
    my ( $self, $style ) = @_;
    push @{ $self->styles }, $style;
    return $self;
}

use subs qw/element attribute text/;

sub tokml {
    my ($self) = @_;
    my $dom    = XML::LibXML::Document->new( '1.0', 'UTF-8' );
    my $kml    = $dom->createElement('kml');
    $kml->setAttribute( 'xmlns', 'http://earth.google.com/kml/2.1' );
    $dom->setDocumentElement($kml);

    my $document = element $dom, $kml => 'Document';
    text $dom, $document, name => $self->name;

    for my $pt ( @{ $self->points } ) {
        my $placemark = element $dom, $document => 'Placemark';
        text $dom, $placemark, name => $pt->id;
        my $point = element $dom, $placemark => 'Point';
        text $dom, $point,
            coordinates => $pt->x . ',' . $pt->y . ',' . $pt->z;
        text $dom, $placemark, description => $pt->desc;
        text $dom, $placemark, styleUrl    => '#' . $pt->style;
    }

    for my $st ( @{ $self->styles } ) {
        my $style     = attribute $dom, $document, Style => ( id => $st->id );
        my $iconstyle = element $dom,   $style     => 'IconStyle';
        my $icon      = element $dom,   $iconstyle => 'Icon';
        text $dom, $icon,      href  => $st->href;
        text $dom, $iconstyle, color => $st->color;
    }

    return $dom->toString(1);
}

sub text {
    my ( $dom, $parent, $name, $text ) = @_;
    my $node = $dom->createElement($name);
    $node->appendTextNode($text);
    $parent->appendChild($node);
    return $node;
}

sub element {
    my ( $dom, $parent, $name ) = @_;
    my $node = $dom->createElement($name);
    $parent->appendChild($node);
    return $node;
}

sub attribute {
    my ( $dom, $parent, $name, $id, $value ) = @_;
    my $node = $dom->createElement($name);
    $parent->appendChild($node);
    $node->setAttribute( $id => $value );
    return $node;
}

1;
