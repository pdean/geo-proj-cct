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
use XML::Simple;
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

sub kmlout {
    my ($self) = @_;
    my ( $Doc, $Style, $Placemark ) = ( [], [], [] );
    push @$Doc,
        {   name      => [ $self->name ],
            Style     => $Style,
            Placemark => $Placemark,
        };
    for my $style ( @{ $self->styles } ) {
        push @$Style,
            {   id        => $style->id,
                IconStyle => [
                    {   Icon  => [ { href => [ $style->href ] } ],
                        color => [ $style->color ]
                    }
                ]
            };
    }
    for my $point ( @{ $self->points } ) {
        push @$Placemark,
            {   name        => [ $point->id ],
                description => [ $point->desc ],
                styleUrl    => [ "#" . $point->style ],
                Point       => [
                    {   coordinates =>
                        [ $point->x . ',' . $point->y . ',' . $point->z ]
                    }
                ],
            };
    }
    my $root = { Document => $Doc };
    return XMLout( $root, RootName => 'kml' );
}

sub tokml {
    my ($self) = @_;
    my $dom    = XML::LibXML::Document->new( '1.0', 'UTF-8' );
    my $kml    = $dom->createElement('kml');
    $kml->setAttribute( 'xmlns', 'http://earth.google.com/kml/2.1' );
    $dom->setDocumentElement($kml);
    my $document = $dom->createElement('Document');
    $kml->appendChild($document);

    my $name = $dom->createElement('name');
    $name->appendTextNode( $self->name );
    $document->appendChild($name);

    for my $pt ( @{ $self->points } ) {
        my $placemark = $dom->createElement('Placemark');
        $document->appendChild($placemark);

        my $name = $dom->createElement('name');
        $name->appendTextNode( $pt->id );
        $placemark->appendChild($name);

        my $point = $dom->createElement('Point');
        $placemark->appendChild($point);

        my $coordinates = $dom->createElement('coordinates');
        $coordinates->appendTextNode( $pt->x . ',' . $pt->y . ',' . $pt->z );
        $point->appendChild($coordinates);

        my $description = $dom->createElement('description');
        $description->appendTextNode( $pt->desc );
        $placemark->appendChild($description);

        my $style_url = $dom->createElement('styleUrl');
        $style_url->appendTextNode( '#' . $pt->style );
        $placemark->appendChild($style_url);
    }

    for my $st ( @{ $self->styles } ) {
        my $style = $dom->createElement('Style');
        $document->appendChild($style);
        $style->setAttribute( id => $st->id );

        my $iconstyle = $dom->createElement('IconStyle');
        $style->appendChild($iconstyle);

        my $icon = $dom->createElement('Icon');
        $iconstyle->appendChild($icon);

        my $href = $dom->createElement('href');
        $href->appendTextNode( $st->href );
        $icon->appendChild($href);

        my $color = $dom->createElement('color');
        $color->appendTextNode( $st->color );
        $iconstyle->appendChild($color);
    }

    return $dom->toString(1);
}

1;
