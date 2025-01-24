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
    $dom->setDocumentElement($kml);
    $kml->setAttribute( xmlns => 'http://earth.google.com/kml/2.1' );

    my $document = element $kml => 'Document';
    text $document, name => $self->name;

    for my $pt ( @{ $self->points } ) {
        my $placemark = element $document => 'Placemark';
        text $placemark, name => $pt->id;
        my $point = element $placemark => 'Point';
        text $point,     coordinates => $pt->x . ',' . $pt->y . ',' . $pt->z;
        text $placemark, description => $pt->desc;
        text $placemark, styleUrl    => '#' . $pt->style;
    }

    for my $st ( @{ $self->styles } ) {
        my $style     = attribute $document, Style => ( id => $st->id );
        my $iconstyle = element $style     => 'IconStyle';
        my $icon      = element $iconstyle => 'Icon';
        text $icon,      href  => $st->href;
        text $iconstyle, color => $st->color;
    }

    return $dom->toString(1);
}

sub element {
    my ( $parent, $name ) = @_;
    my $node = $parent->ownerDocument->createElement($name);
    $parent->appendChild($node);
    return $node;
}

sub text {
    my ( $parent, $name, $text ) = @_;
    my $node = $parent->ownerDocument->createElement($name);
    $parent->appendChild($node);
    $node->appendTextNode($text);
    return $node;
}

sub attribute {
    my ( $parent, $name, $id, $value ) = @_;
    my $node = $parent->ownerDocument->createElement($name);
    $parent->appendChild($node);
    $node->setAttribute( $id => $value );
    return $node;
}

1;
