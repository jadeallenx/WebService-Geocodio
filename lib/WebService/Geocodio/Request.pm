use strict;
use warnings;

package WebService::Geocodio::Request;

use Moo::Role;
use HTTP::Tiny;
use Carp qw(confess);
use WebService::Geocodio::Location;

with 'WebService::Geocodio::JSON';

# ABSTRACT: A request role for Geocod.io

=attr ua

A user agent object. Default is L<HTTP::Tiny>

=cut

has 'ua' => (
    is => 'ro',
    lazy => 1,
    default => sub { HTTP::Tiny->new(
        agent => "WebService-Geocodio ",
        default_headers => { 'Content-Type' => 'application/json' },
    ) },
);

=attr base_url

The base url to use when connecting to the service. Default is 'http://api.geocod.io'

=cut

has 'base_url' => (
    is => 'ro',
    lazy => 1,
    default => sub { 'http://api.geocod.io/v1/' },
);

=method send_forward

This method POSTs an arrayref of data to the service for processing.  If the
web call is successful, returns an array of L<WebService::Geocodio::Location>
objects.

Any API errors are fatal and reported by C<Carp::confess>.

=cut

sub send_forward {
    my $self = shift;

    $self->_request('geocode', $self->encode(@_));
}

=method send_reverse

This method POSTs an arrayref of data to the service for processing.  If the
web call is successful, returns an array of L<WebService::Geocodio::Location>
objects.

Any API errors are fatal and reported by C<Carp::confess>.

=cut

sub send_reverse {
    my $self = shift;

    $self->_request('reverse', $self->encode(@_));
}

sub _request {
    my ($self, $op, $content) = @_;

    my $response = $self->ua->request('POST', $self->base_url 
        . "$op?api_key=" . $self->api_key, { content => $content });

    if ( $response->{success} ) {
        my $hr = $self->decode($response->{content});
        return map { WebService::Geocodio::Location->new($_) } 
            map {; @{$_->{response}->{results}} } @{$hr->{results}};
    }
    else {
        confess "Request to " . $self->base_url . "$op failed: (" . 
            $response->{status} . ") - " . $response->{content};
    }
}


1;
