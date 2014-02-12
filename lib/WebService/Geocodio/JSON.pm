use strict;
use warnings;

package WebService::Geocodio::JSON;

use Moo::Role;
use JSON;
use Carp qw(confess);

=attr json

A JSON serializer/deserializer instance. Default is L<JSON>.

=cut

has 'json' => (
    is => 'ro',
    lazy => 1,
    default => sub { JSON->new() },
);

sub _forward_formatting {
    my $self = shift;

    return $self->formatted if $self->has_formatted;

    if ( ( not $self->has_zip ) && ( not ( $self->has_city && $self->has_state ) ) ) {
        confess "A zip or city-state pair is required.\n";
    }

    my $s;
    if ( $self->has_number && $self->has_street && $self->suffix ) {
        $s .= join " ", (map {; $self->$_ } qw(number street suffix));
        $s .= ", ";
    }

    if ( $self->has_zip ) {
        $s .= $self->zip
    }
    else {
        $s .= join ", ", (map {; $self->$_ } qw(city state));
    }

    return $s;
}

sub _reverse_formatting {
    my $self = shift;

    if ( not ( $self->has_lat && $self->has_lng ) ) {
        confess "lat-lng pair is required\n";
    }

    return join ",", ( map {; $self->$_ } qw(lat lng) );
}
    
sub encode {
    my ($self, $direction, $aref) = @_;

    my @r;
    if ( $direction eq 'f' ) {
        @r = map {; $self->_forward_formatting($_) } @$aref;
    }
    elsif ( $direction eq 'r' ) {
        @r = map {; $self->_reverse_formatting($_) } @$aref;
    }

    $self->json->encode(\@r);
}

1;
