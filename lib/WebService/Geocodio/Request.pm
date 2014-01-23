use strict;
use warnings;

package WebService::Geocodio::Request;

use Moo::Role;
use HTTP::Tiny;
use JSON;
use Carp qw(confess);
use WebService::Geocodio::Location;

# ABSTRACT: A request role for Geocod.io

=attr json

A JSON serializer/deserializer object. Default is JSON.

=cut

has 'json' => (
    is => 'ro',
    lazy => 1,
    default => sub { JSON->new()->allow_blessed->convert_blessed },
);

=attr ua

A user agent object. Default is HTTP::Tiny

=cut

has 'ua' => (
    is => 'ro',
    lazy => 1,
    default => sub { HTTP::Tiny->new(
        agent => 'WebService-Geocodio ',
        default_headers => { 'Content-Type' => 'application/json' },
    ) },
);

=attr base_url

The base url to use when connecting to the service. Default is 'http://api.geocod.io'

=cut

has 'base_url' => (
    is => 'ro',
    lazy => 1,
    default => sub { 'http://api.geocod.io/v1/geocode' },
);

=method send

This method sends an arrayref of data to the service for processing.  If the web call is
successful, returns an array of L<WebService::Geocodio::Location> objects.

Any API errors are fatal and reported by C<Carp::confess>.

=cut

sub send {
    my $self = shift;

    my $data = $self->json->encode(shift);

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
