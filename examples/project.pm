use v5.36;

# -------------------------------------------

package Point;
use Moo;

has id    => ( is => 'ro', required => 1 );
has x     => ( is => 'ro', required => 1 );
has y     => ( is => 'ro', required => 1 );
has z     => ( is => 'ro', required => 1 );
has desc  => ( is => 'ro', default  => '' );
has style => ( is => 'ro', default  => '' );

# -------------------------------------------

package Style;
use Moo;

has id    => ( is => 'ro', required => 1 );
has color => ( is => 'ro', required => 1 );
has href  => ( is => 'ro', required => 1 );

# -------------------------------------------

package Project;
use Moo;
use XML::Simple;

has name   => ( is => 'ro', required => 1 );
has points => ( is => 'ro', default  => sub { return [] } );
has styles => ( is => 'ro', default  => sub { return [] } );

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

1;
