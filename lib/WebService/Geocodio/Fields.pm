use strict;
use warnings;

{
    package WebService::Geocodio::Fields::CongressionalDistrict;

    use Moo::Lax;

    has [qw(name district_number congress_number congress_years)] => (
        is => 'ro',
    );

}

################## State Legislative Districts

{
    package WebService::Geocodio::Fields::StateLegislativeDistrict::House;
    use Moo::Lax;

    has [qw(name district_number)] => (
        is => 'ro',
    );
}

{
    package WebService::Geocodio::Fields::StateLegislativeDistrict::Senate;
    use Moo::Lax;

    has [qw(name district_number)] => (
        is => 'ro',
    );
}

{

    package WebService::Geocodio::Fields::StateLegislativeDistrict;

    use WebService::Geocodio::Fields::StateLegislativeDistrict::House;
    use WebService::Geocodio::Fields::StateLegislativeDistrict::Senate;

    use Moo::Lax;
    use Carp qw(confess);

    has [qw(house senate)] => (
        is => 'ro',
        predicate => 1,
    );

    sub BUILDARGS {
        my ($class, $hr) = @_;

        confess "$class only accepts hashrefs in its constructor" unless ( ref($hr) eq 'HASH' );

        my $out;

        $out->{house} = WebService::Geocodio::Fields::StateLegislativeDistrict::House->new(
            $hr->{house}) if exists $hr->{house};
        $out->{senate} = WebService::Geocodio::Fields::StateLegislativeDistrict::Senate->new(
            $hr->{senate}) if exists $hr->{senate};

        return $out;
    }

}

############### School districts

{
    package WebService::Geocodio::Fields::SchoolDistrict::Unified;
    use Moo::Lax;

    has [qw(name lea_code grade_low grade_high)] => (
        is => 'ro',
    );
}

{
    package WebService::Geocodio::Fields::SchoolDistrict::Elementary;
    use Moo::Lax;

    has [qw(name lea_code grade_low grade_high)] => (
        is => 'ro',
    );
}

{
    package WebService::Geocodio::Fields::SchoolDistrict::Secondary;
    use Moo::Lax;

    has [qw(name lea_code grade_low grade_high)] => (
        is => 'ro',
    );
}

{

    package WebService::Geocodio::Fields::SchoolDistrict;

    use WebService::Geocodio::Fields::SchoolDistrict::Unified;
    use WebService::Geocodio::Fields::SchoolDistrict::Elementary;
    use WebService::Geocodio::Fields::SchoolDistrict::Secondary;

    use Moo::Lax;
    use Carp qw(confess);

    has [qw(unified elementary secondary)] => (
        is => 'ro',
        predicate => 1,
    );

    sub BUILDARGS {
        my ($class, $hr) = @_;

        confess "$class only accepts hashrefs in its constructor" unless ( ref($hr) eq 'HASH' );

        my $out;

        $out->{unified} = WebService::Geocodio::Fields::SchoolDistrict::Unified->new(
            $hr->{unified}) if exists $hr->{unified};
        $out->{elementary} = WebService::Geocodio::Fields::SchoolDistrict::Elementary->new(
            $hr->{elementary}) if exists $hr->{elementary};
        $out->{secondary} = WebService::Geocodio::Fields::SchoolDistrict::Secondary->new(
            $hr->{secondary}) if exists $hr->{secondary};

        return $out;
    }
}

############################ Timezone

{
    package WebService::Geocodio::Fields::Timezone;
    use Moo::Lax;

    has [qw(name utc_offset observes_dst)] => (
        is => 'ro',
    );
}

package WebService::Geocodio::Fields;

use WebService::Geocodio::Fields::CongressionalDistrict;
use WebService::Geocodio::Fields::StateLegislativeDistrict;
use WebService::Geocodio::Fields::SchoolDistrict;
use WebService::Geocodio::Fields::Timezone;

use Moo::Lax;
use Carp qw(confess);

has [qw(cd stateleg school timezone)] => (
    is => 'rw',
    predicate => 1,
);

sub BUILDARGS {
    my ( $class, $hr ) = @_;

    confess "$class only accepts hashrefs in its constructor" unless ( ref($hr) eq 'HASH' );

    my $out;

    $out->{cd} = WebService::Geocodio::Fields::CongressionalDistrict->new(
        $hr->{congressional_district}) if exists $hr->{congressional_district};
    $out->{stateleg} = WebService::Geocodio::Fields::StateLegislativeDistrict->new(
        $hr->{state_legislative_districts}) if exists $hr->{state_legislative_districts};
    $out->{school} = WebService::Geocodio::Fields::SchoolDistrict->new(
        $hr->{school_districts}) if exists $hr->{school_districts};
    $out->{timezone} = WebService::Geocodio::Fields::Timezone->new($hr->{timezone}) 
        if exists $hr->{timezone};

    return $out;
}

1;

