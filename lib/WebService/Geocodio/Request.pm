use strict;
use warnings;

package WebService::Geocodio::Request;

use Moo::Role;
use HTTP::Tiny;
use JSON;
use Carp qw(confess);
use WebService::Geocodio::Location;

has 'json' => (
    is => 'ro',
    lazy => 1,
    default => sub { JSON->new() },
);

has 'ua' => (
    is => 'ro',
    lazy => 1,
    default => sub { HTTP::Tiny->new(
        agent => 'WebService-Geocodio ',
        default_headers => { 'Content-Type' => 'application/json' },
    ) },
);

has 'base_url' => (
    is => 'ro',
    lazy => 1,
    default => sub { 'http://api.geocod.io/v1/geocode' },
);

sub send {
    my $self = shift;

    my $data = $self->json->encode(@_);

    my $response = $self->ua->request('POST', $self->base_url . "?api_key=" . $self->api_key, { content => $data });

    if ( $response->{success} ) {
        my $hr = $self->json->decode($response->{content});
        return map { WebService::Geocodio::Location->new($_) } 
            map {; @{$_->{response}->{results}} } @{$hr->{results}};
    }
    else {
        confess "Request to " . $self->base_url . " failed: (" . $response->{status} . ") - " . $response->{content};
    }
}

1;
