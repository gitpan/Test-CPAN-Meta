package Test::CPAN::Meta::Version;

use warnings;
use strict;

use vars qw($VERSION);
$VERSION = '0.08';

#----------------------------------------------------------------------------

=head1 NAME

Test::CPAN::Meta::Version - Validation of META.yml specification elements.

=head1 SYNOPSIS

  use Test::CPAN::Meta::Version;

=head1 DESCRIPTION

This module was written to ensure that a META.yml file, provided with a
standard distribution uploaded to CPAN, meets the specifications that are
slowly being introduced to module uploads, via the use of
L<ExtUtils::MakeMaker>, L<Module::Build> and L<Module::Install>.

This module is meant to be used together with L<Test::CPAN::Meta>, however
the code is self contained enough that you can access it directly.

=head1 ABSTRACT

Validation of META.yml specification elements.

=cut

#----------------------------------------------------------------------------

#############################################################################
#Specification Definitions													#
#############################################################################

my $module_map1 = { 'map' => { ':key' => { name => \&module, value => \&exversion } } };
my $module_map2 = { 'map' => { ':key' => { name => \&module, value => \&version   } } };
my $no_index_1_3 = {
    'map'       => { file       => { list => { value => \&string } },
                     directory  => { list => { value => \&string } },
                     'package'  => { list => { value => \&string } },
                     namespace  => { list => { value => \&string } },
    }
};
my $no_index_1_2 = {
    'map'       => { file       => { list => { value => \&string } },
                     dir        => { list => { value => \&string } },
                     'package'  => { list => { value => \&string } },
                     namespace  => { list => { value => \&string } },
    }
};
my $no_index_1_1 = {
    'map'       => { ':key'     => { name => \&word, list => { value => \&string } },
    }
};

my %definitions = (
'1.3' => {
#  'header'              => { mandatory => 1, value => \&header },
  'meta-spec'           => { mandatory => 1, 'map' => { version => { mandatory => 1, value => \&version},
                                                        url     => { mandatory => 1, value => \&urlspec } } },

  'name'                => { mandatory => 1, value => \&string  },
  'version'             => { mandatory => 1, value => \&version },
  'abstract'            => { mandatory => 1, value => \&string  },
  'author'              => { mandatory => 1, list  => { value => \&string } },
  'license'             => { mandatory => 1, value => \&license },
  'generated_by'        => { mandatory => 1, value => \&string  },

  'distribution_type'   => { value => \&string  },
  'dynamic_config'      => { value => \&boolean },

  'requires'            => $module_map1,
  'recommends'          => $module_map1,
  'build_requires'      => $module_map1,
  'conflicts'           => $module_map2,

  'optional_features'   => {
    list        => {
        ':key'  => { name => \&word,
            'map'   => { description        => { value => \&string },
                         requires_packages  => { value => \&string },
                         requires_os        => { value => \&string },
                         excludes_os        => { value => \&string },
                         requires           => $module_map1,
                         recommends         => $module_map1,
                         build_requires     => $module_map1,
                         conflicts          => $module_map2,
            }
        }
     }
  },

  'provides'    => {
    'map'       => { ':key' => { name  => \&module,
                                 'map' => { file    => { mandatory => 1, value => \&file },
                                            version => { value => \&version } } } }
  },

  'no_index'    => $no_index_1_3,
  'private'     => $no_index_1_3,

  'keywords'    => { list => { value => \&string } },

  'resources'   => {
    'map'       => { license    => { value => \&url },
                     homepage   => { value => \&url },
                     bugtracker => { value => \&url },
                     repository => { value => \&url },
                     ':key'     => { value => \&string, name => \&resource },
    }
  },

  # additional user defined key/value pairs
  # note we can only validate the key name, as the structure is user defined
  ':key'        => { name => \&word },
},

# v1.2 is misleading, it seems to assume that a number of fields where created
# within v1.1, when they were created within v1.2. This may have been an
# original mistake, and that a v1.1 was retro fitted into the timeline, when
# v1.2 was originally slated as v1.1. But I could be wrong ;)
'1.2' => {
#  'header'              => { mandatory => 1, value => \&header },
  'meta-spec'           => { mandatory => 1, 'map' => { version => { mandatory => 1, value => \&version},
                                                        url     => { mandatory => 1, value => \&urlspec } } },

  'name'                => { mandatory => 1, value => \&string  },
  'version'             => { mandatory => 1, value => \&version },
  'license'             => { mandatory => 1, value => \&license },
  'generated_by'        => { mandatory => 1, value => \&string  },
  'author'              => { mandatory => 1, list => { value => \&string } },
  'abstract'            => { mandatory => 1, value => \&string  },

  'distribution_type'   => { value => \&string  },
  'dynamic_config'      => { value => \&boolean },

  'keywords'            => { list => { value => \&string } },

  'private'             => $no_index_1_2,
  '$no_index'           => $no_index_1_2,

  'requires'            => $module_map1,
  'recommends'          => $module_map1,
  'build_requires'      => $module_map1,
  'conflicts'           => $module_map2,

  'provides'    => {
    'map'       => { ':key' => { name  => \&module,
                                 'map' => { file    => { mandatory => 1, value => \&file },
                                            version => { value => \&version } } } }
  },

  'resources'   => {
    'map'       => { license    => { value => \&url },
                     homepage   => { value => \&url },
                     bugtracker => { value => \&url },
                     repository => { value => \&url },
                     ':key'     => { value => \&string, name => \&resource },
    }
  },

  # additional user defined key/value pairs
  # note we can only validate the key name, as the structure is user defined
  ':key'        => { name => \&word },
},

# note that the 1.1 spec doesn't specify optional or mandatory fields, what
# appears below is assumed from later specifications.
'1.1' => {
#  'header'              => { mandatory => 1, value => \&header },
  'name'                => { mandatory => 1, value => \&string  },
  'version'             => { mandatory => 1, value => \&version },
  'license'             => { mandatory => 1, value => \&license },
  'license_uri'         => { mandatory => 0, value => \&url },
  'generated_by'        => { mandatory => 1, value => \&string  },

  'distribution_type'   => { value => \&string  },
  'dynamic_config'      => { value => \&boolean },

  'private'             => $no_index_1_1,

  'requires'            => $module_map1,
  'recommends'          => $module_map1,
  'build_requires'      => $module_map1,
  'conflicts'           => $module_map2,

  # additional user defined key/value pairs
  # note we can only validate the key name, as the structure is user defined
  ':key'        => { name => \&word },
},

# note that the 1.0 spec doesn't specify optional or mandatory fields, what
# appears below is assumed from later specifications.
'1.0' => {
#  'header'              => { mandatory => 1, value => \&header },
  'name'                => { mandatory => 1, value => \&string  },
  'version'             => { mandatory => 1, value => \&version },
  'license'             => { mandatory => 1, value => \&license },
  'generated_by'        => { mandatory => 1, value => \&string  },

  'distribution_type'   => { value => \&string  },
  'dynamic_config'      => { value => \&boolean },

  'requires'            => $module_map1,
  'recommends'          => $module_map1,
  'build_requires'      => $module_map1,
  'conflicts'           => $module_map2,

  # additional user defined key/value pairs
  # note we can only validate the key name, as the structure is user defined
  ':key'        => { name => \&word },
},
);

#############################################################################
#Code               														#
#############################################################################

=head1 CLASS CONSTRUCTOR

=over

=item * new( yaml => $yaml [, spec => $version] )

The constructor must be passed a valid YAML data structure.

Optionally you may also provide a specification version. This version is then
use to ensure that the given YAML data structure meets the respective
specification definition. If no version is provided the module will attempt to
deduce the appropriate specification version from the data structure itself.

=back

=cut

sub new {
    my ($class,%hash) = @_;

    # create an attributes hash
    my $atts = {
        'spec' => $hash{spec},
        'yaml' => $hash{yaml},
    };

    # create the object
    my $self = bless $atts, $class;
}

=head1 METHODS

=head2 Main Methods

=over

=item * parse()

Using the YAML data structure provided with the constructure, attempts to
parse and validate according to the appropriate specification definition.

Returns 1 if any errors found, otherwise returns 0.

=item * errors()

Returns a list of the errors found during parsing.

=back

=cut

sub parse {
    my $self = shift;
    my $data = $self->{yaml};

    unless($self->{spec}) {
        $self->{spec} = $data->{'meta-spec'} && $data->{'meta-spec'}->{'version'} ? $data->{'meta-spec'}->{'version'} : '1.0';
    }

    $self->check_map($definitions{$self->{spec}},$data);
    return defined $self->{errors} ? 1 : 0;
}

sub errors {
    my $self = shift;
    return ()   unless($self->{errors});
    return @{$self->{errors}};
}

=head2 Check Methods

=over

=item * check_map($spec,$data)

Checks whether a map (or hash) part of the YAML data structure conforms to the
appropriate specification definition.

=item * check_list($spec,$data)

Checks whether a list (or array) part of the YAML data structure conforms to
the appropriate specification definition.

=back

=cut

sub check_map {
    my ($self,$spec,$data) = @_;

    if(ref($data) ne 'HASH') {
        $self->_error( "Expected a map structure from YAML string or file" );
        return;
    }

    for my $key (keys %$spec) {
        next    unless($spec->{$key}->{mandatory});
        next    if(defined $data->{$key});
        push @{$self->{stack}}, $key;
        $self->_error( "Missing mandatory field, '$key'" );
        pop @{$self->{stack}};
    }

    for my $key (keys %$data) {
        push @{$self->{stack}}, $key;
        if($spec->{$key}) {
            if($spec->{$key}{value}) {
                $spec->{$key}{value}->($self,$key,$data->{$key});
            } elsif($spec->{$key}{'map'}) {
                $self->check_map($spec->{$key}{'map'},$data->{$key});
            } elsif($spec->{$key}{'list'}) {
                $self->check_list($spec->{$key}{'list'},$data->{$key});
            }

        } elsif ($spec->{':key'}) {
            $spec->{':key'}{name}->($self,$key,$key);
            if($spec->{':key'}{value}) {
                $spec->{':key'}{value}->($self,$key,$data->{$key});
            } elsif($spec->{':key'}{'map'}) {
                $self->check_map($spec->{':key'}{'map'},$data->{$key});
            } elsif($spec->{':key'}{'list'}) {
                $self->check_list($spec->{':key'}{'list'},$data->{$key});
            }


        } else {
            $self->_error( "Unknown key, '$key', found in map structure" );
        }
        pop @{$self->{stack}};
    }
}

sub check_list {
    my ($self,$spec,$data) = @_;

    if(ref($data) ne 'ARRAY') {
        $self->_error( "Expected a list structure" );
        return;
    }

    if(defined $spec->{mandatory}) {
        if(!defined $data->[0]) {
            $self->_error( "Missing entries from mandatory list" );
        }
    }

    for my $value (@$data) {
        push @{$self->{stack}}, $value;
        if(defined $spec->{value}) {
            $spec->{value}->($self,'list',$value);
        } elsif(defined $spec->{'map'}) {
            $self->check_map($spec->{'map'},$value);
        } elsif(defined $spec->{'list'}) {
            $self->check_list($spec->{'list'},$value);

        } elsif ($spec->{':key'}) {
            $self->check_map($spec,$value);

        } else {
            $self->_error( "Unknown value type, '$value', found in list structure" );
        }
        pop @{$self->{stack}};
    }
}

=head2 Validator Methods

=over

=item * header($self,$key,$value)

Validates that the YAML header is valid.

Note: No longer used as we now read the YAML data structure, not the file.

=item * url($self,$key,$value)

Validates that a given value is in an acceptable URL format

=item * urlspec($self,$key,$value)

Validates that the URL to a META.yml specification is a known one.

=item * string_or_undef($self,$key,$value)

Validates that the value is either a string or an undef value. Bit of a
catchall function for parts of the data structure that are completely user
defined.

=item * string($self,$key,$value)

Validates that a string exists for the given key.

=item * file($self,$key,$value)

Validate that a file is passed for the given key. This may be made more
thorough in the future. For now it acts like \&string.

=item * exversion($self,$key,$value)

Validates a list of versions, e.g. '<= 5, >=2, ==3, !=4, >1, <6, 0'.

=item * version($self,$key,$value)

Validates a single version string. Versions of the type '5.8.8' and '0.00_00'
are both valid.

=item * boolean($self,$key,$value)

Validates for a boolean value. Currently these values are '1', '0', 'true',
'false', however the latter 2 may be removed.

=item * license($self,$key,$value)

Validates that a value is given for the license. Returns 1 if an known license
type, or 2 if a value is given but the license type is not a recommended one.

=item * resource($self,$key,$value)

Validates that the given key is in CamelCase, to indicate a user defined
keyword.

=item * word($self,$key,$value)

Validates that key is in an acceptable format for the META.yml specification,
i.e. any in the character class [-_a-z].

=item * module($self,$key,$value)

Validates that a given key is in an acceptable module name format, e.g.
'Test::CPAN::Meta::Version'.

=back

=cut

sub header {
    my ($self,$key,$value) = @_;
    if(defined $value) {
        return 1    if($value && $value =~ /^--- #YAML:1.0/);
    }
    $self->_error( "file does not have a valid YAML header." );
    return 0;
}

#my $protocol = qr�(?:http|https|ftp|afs|news|nntp|mid|cid|mailto|wais|prospero|telnet|gopher)�;
my $protocol = qr�(?:ftp|http|https)�;
my $badproto = qr�(\w+)://�;
my $proto    = qr�$protocol://(?:[\w]+:\w+@)?�;
my $atom     = qr�[a-z\d]�i;
my $domain   = qr�((($atom(($atom|-)*$atom)?)\.)*([a-zA-Z](($atom|-)*$atom)?))�;
my $ip       = qr�((\d+)(\.(\d+)){3})(:(\d+))?�;
my $enc      = qr�%[a-fA-F\d]{2}�;
my $legal1   = qr�[a-zA-Z\d\$\-_.+!*'(),]�; #' - this comment is to avoid syntax highlighting issues
my $legal2   = qr�[;:@&=]�;
my $legal3   = qr�((($legal1|$enc)|$legal2)*)�;
my $path     = qr�\/$legal3(\/$legal3)*�;
my $query    = qr�\?$legal3�;
my $urlregex = qr�(($proto)?($domain|$ip)(($path)?($query)?)?)�;

sub url {
    my ($self,$key,$value) = @_;
    if(defined $value) {
        if($value && $value =~ /^$badproto$/) {
            $self->_error( "Domain name required for a valid URL." );
            return 0;
        }
        if($value && $value =~ /^$badproto/ && $1 !~ $protocol) {
            $self->_error( "Unknown protocol used in URL." );
            return 0;
        }
        return 1    if($value && $value =~ /^$urlregex$/);
    }
    $value ||= '';
    $self->_error( "'$value' for '$key' is not a valid URL." );
    return 0;
}

my %known_specs = (
    '1.3' => 'http://module-build.sourceforge.net/META-spec-v1.3.html',
    '1.2' => 'http://module-build.sourceforge.net/META-spec-v1.2.html',
    '1.1' => 'http://module-build.sourceforge.net/META-spec-v1.1.html',
    '1.0' => 'http://module-build.sourceforge.net/META-spec-v1.0.html'
);
my %known_urls = map {$known_specs{$_} => $_} keys %known_specs;

sub urlspec {
    my ($self,$key,$value) = @_;
    if(defined $value) {
        return 1    if($value && $known_specs{$self->{spec}} eq $value);
        if($value && $known_urls{$value}) {
            $self->_error( 'META.yml specification URL does not match version' );
            return 0;
        }
    }
    $self->_error( 'Unknown META.yml specification' );
    return 0;
}

sub string {
    my ($self,$key,$value) = @_;
    if(defined $value) {
        return 1    if($value || $value =~ /^0$/);
    }
    $self->_error( "value is an undefined string" );
    return 0;
}

sub string_or_undef {
    my ($self,$key,$value) = @_;
    return 1    unless(defined $value);
    return 1    if($value || $value =~ /^0$/);
    $self->_error( "No string defined for '$key'" );
    return 0;
}

sub file {
    my ($self,$key,$value) = @_;
    return 1    if(defined $value);
    $self->_error( "No file defined for '$key'" );
    return 0;
}

sub exversion {
    my ($self,$key,$value) = @_;
    if(defined $value && ($value || $value =~ /0/)) {
        my $pass = 1;
        for(split(",",$value)) { $self->version($key,$_) or ($pass = 0); }
        return $pass;
    }
    $value = '<undef>'  unless(defined $value);
    $self->_error( "'$value' for '$key' is not a valid version." );
    return 0;
}

sub version {
    my ($self,$key,$value) = @_;
    if(defined $value) {
        return 0    unless($value || $value =~ /0/);
        return 1    if($value =~ /^\s*((<|<=|>=|>|!=|==)\s*)?\d+((\.\d+((_|\.)\d+)?)?)/);
    } else {
        $value = '<undef>';
    }
    $self->_error( "'$value' for '$key' is not a valid version." );
    return 0;
}

sub boolean {
    my ($self,$key,$value) = @_;
    if(defined $value) {
        return 1    if($value =~ /^(0|1|true|false)$/);
    } else {
        $value = '<undef>';
    }
    $self->_error( "'$value' for '$key' is not a boolean value." );
    return 0;
}

my %licenses = (
    'perl'         => 'http://dev.perl.org/licenses/',
    'gpl'          => 'http://www.opensource.org/licenses/gpl-license.php',
    'apache'       => 'http://apache.org/licenses/LICENSE-2.0',
    'artistic'     => 'http://opensource.org/licenses/artistic-license.php',
    'artistic2'    => 'http://opensource.org/licenses/artistic-license-2.0.php',
    'artistic-2.0' => 'http://opensource.org/licenses/artistic-license-2.0.php',
    'lgpl'         => 'http://www.opensource.org/licenses/lgpl-license.phpt',
    'bsd'          => 'http://www.opensource.org/licenses/bsd-license.php',
    'gpl'          => 'http://www.opensource.org/licenses/gpl-license.php',
    'mit'          => 'http://opensource.org/licenses/mit-license.php',
    'mozilla'      => 'http://opensource.org/licenses/mozilla1.1.php',
    'open_source'  => undef,
    'unrestricted' => undef,
    'restrictive'  => undef,
    'unknown'      => undef,
);

sub license {
    my ($self,$key,$value) = @_;
    if(defined $value) {
        return 1    if($value && exists $licenses{$value});
        return 2    if($value);
    } else {
        $value = '<undef>';
    }
    $self->_error( "License '$value' is unknown" );
    return 0;
}

sub resource {
    my ($self,$key) = @_;
    if(defined $key) {
        return 1    if($key && $key =~ /^([A-Z][a-z]+)+$/);
    } else {
        $key = '<undef>';
    }
    $self->_error( "Resource '$key' must be in CamelCase." );
    return 0;
}

sub word {
    my ($self,$key) = @_;
    if(defined $key) {
        return 1    if($key && $key =~ /^([-_a-z]+)$/);
    } else {
        $key = '<undef>';
    }
    $self->_error( "Key '$key' is not a legal keyword." );
    return 0;
}

sub module {
    my ($self,$key) = @_;
    if(defined $key) {
        return 1    if($key && $key =~ /^[A-Za-z0-9_]+(::[A-Za-z0-9_]+)*$/);
    } else {
        $key = '<undef>';
    }
    $self->_error( "Key '$key' is not a legal module name." );
    return 0;
}

sub _error {
    my $self = shift;
    my $mess = shift;

    $mess .= ' ('.join(' -> ',@{$self->{stack}}).')'  if($self->{stack});
    $mess .= " [Validation: $self->{spec}]";

    push @{$self->{errors}}, $mess;
}

q( Currently Listening To: Gary Numan - "This Wreckage" from 'Scarred');

__END__

#----------------------------------------------------------------------------

=head1 BUGS, PATCHES & FIXES

There are no known bugs at the time of this release. However, if you spot a
bug or are experiencing difficulties that are not explained within the POD
documentation, please send an email to barbie@cpan.org or submit a bug to the
RT system (http://rt.cpan.org/Public/Dist/Display.html?Name=Test-YAML-Meta).
However, it would help greatly if you are able to pinpoint problems or even
supply a patch.

Fixes are dependant upon their severity and my availablity. Should a fix not
be forthcoming, please feel free to (politely) remind me.

=head1 DSLIP

  b - Beta testing
  d - Developer
  p - Perl-only
  O - Object oriented
  p - Standard-Perl: user may choose between GPL and Artistic

=head1 AUTHOR

Barbie, <barbie@cpan.org>
for Miss Barbell Productions, L<http://www.missbarbell.co.uk>

=head1 COPYRIGHT AND LICENSE

  Copyright (C) 2007 Barbie for Miss Barbell Productions

  This module is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.

=cut
