use strict;
use warnings;

package WebService::Geocodio::Location;

use WebService::Geocodio::Fields;
use Moo::Lax;
use Carp qw(confess);

# ABSTRACT: Location object for use with Geocod.io service.

=attr number

Buiding number

=attr street

A street name identifier

=attr postdirection

A address direction like 'SW' or 'S'

=attr suffix

The type of street 'Ave', 'St', etc.

=attr city

The city where the streets have no name.

=attr state

State wherein city is located

=attr zip

The postal zip code

You B<must> have either a zip code OR a city/state pair.

=attr lat

The latitude of the location

=attr lng

The longitude of the location

=attr accuracy

A float from 0 -> 1 representing the confidence of the lookup results

=attr formatted

The full address as formatted by the service.

=attr fields

Any requested fields are available here.

=cut

has [qw(number street suffix postdirection city state zip formatted lat lng accuracy fields)] => (
    is => 'ro',
    predicate => 1,
);

=method new

The constructor accepts either a bare string OR a list of key/value pairs where
the keys are the attribute names.

=cut

sub BUILDARGS {
    my ( $class, @args ) = @_;

    my $out;
    if (ref($args[0]) eq "HASH") {
        my $hr = $args[0];
        $out->{accuracy} = $hr->{accuracy} if exists $hr->{accuracy};
        $out->{formatted} = $hr->{formatted_address} if exists $hr->{formatted_address};
        $out->{fields} = WebService::Geocodio::Fields->new($hr->{fields}) if exists $hr->{fields};
        map { $out->{$_} = $hr->{address_components}->{$_} if exists $hr->{address_components}->{$_} } qw(number street suffix postdirection city state zip);
        map { $out->{$_} = $hr->{location}->{$_} if exists $hr->{location}->{$_} } qw(lat lng);
    }
    elsif ( @args % 2 == 1 ) {
        $out->{formatted} = $args[0];
    }
    else {
        $out = { @args };
    }

    return $out;
}

sub _forward_formatting {
    my $self = shift;

    return $self->formatted if $self->has_formatted;

    if ( ( not $self->has_zip ) && ( not ( $self->has_city && $self->has_state ) ) ) {
        confess "A zip or city-state pair is required.\n";
    }

    my $s;
    if ( $self->has_number && $self->has_street && $self->suffix ) {
        my @f;
        if ( $self->has_postdirection ) {
            @f = qw(number postdirection street suffix);
        }
        else {
            @f = qw(number street suffix);
        }

        $s .= join " ", (map {; $self->$_ } @f);
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


1;
