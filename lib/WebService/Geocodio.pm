use strict;
use warnings;

package WebService::Geocodio;

use Moo;
use Carp qw(confess);
with('WebService::Geocodio::Request');

has 'api_key' => (
    is => 'ro',
    isa => sub { confess "$_[0] doesn't look like a valid api key\n" unless $_[0] =~ /[0-9a-f]+/ },
    required => 1,
);

has 'addresses' => (
    is => 'rw',
    default => sub { [] },
);

sub add {
    my $self = shift;

    push @{ $self->addresses }, @_;
}

sub show {
    my $self = shift;

    return @{ $self->addresses };
}

sub geocode {
    my $self = shift;

    $self->send(@{ $self->addresses });
}

1;
