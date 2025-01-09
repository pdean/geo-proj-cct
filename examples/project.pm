use v5.36;

# -------------------------------------------

package Point;
use Moo;
use namespace::autoclean;
use Types::Standard qw( Str Num );

has id    => ( is => 'ro', isa => Str, required => 1 );
has x     => ( is => 'ro', isa => Num, required => 1 );
has y     => ( is => 'ro', isa => Num, required => 1 );
has z     => ( is => 'ro', isa => Num, required => 1 );
has desc  => ( is => 'ro', isa => Str, default  => '' );
has style => ( is => 'ro', isa => Str, default  => '' );

# -------------------------------------------

package Style;
use Moo;
use namespace::autoclean;
use Types::Standard qw( Str );

has id    => ( is => 'ro', isa => Str, required => 1 );
has color => ( is => 'ro', isa => Str, required => 1 );
has href  => ( is => 'ro', isa => Str, required => 1 );

# -------------------------------------------

package Project;
use Moo;
use namespace::autoclean;
use Types::Standard qw( Str ArrayRef InstanceOf );
use Type::Params    qw( signature );
use XML::Simple;

has name => ( is => 'ro', isa => Str, required => 1 );

has points => (
    is      => 'ro',
    isa     => ArrayRef [ InstanceOf ["Point"] ],
    default => sub { return [] },
);

has styles => (
    is      => 'ro',
    isa     => ArrayRef [ InstanceOf ["Style"] ],
    default => sub { return [] },
);

sub point_add {
    state $check = signature(
        method     => 1,
        positional => [ InstanceOf ['Point'] ]
    );

    my ( $self, $point ) = $check->(@_);
    push @{ $self->points }, $point;

    return $self;
}

sub style_add {
    state $check = signature(
        method     => 1,
        positional => [ InstanceOf ['Style'] ]
    );

    my ( $self, $style ) = $check->(@_);
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
