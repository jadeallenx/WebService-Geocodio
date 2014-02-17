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

=method encode

Serialize a Perl data structure to a JSON string

=cut

sub encode {
    my ($self, $aref) = @_;

    return $self->json->encode($aref);
}

=method decode

Deserialize a JSON string to a Perl data structure

=cut

sub decode {
    my ($self, $data) = @_;

    return $self->json->decode($data);
}

1;
