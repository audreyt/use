package use;
use strict;
use warnings;
use 5.008;
our $VERSION = '0.01';
use base 'rig::engine::base';
use version 0.86 'is_lax';

sub use {
    unshift @_, __PACKAGE__;
    goto &{__PACKAGE__->can('import')};
}

sub import {
    goto &{rig::engine::base->can('import')} if @_;
}

sub build_import {
    shift;

    my @use;
    while (my $arg = shift) {
        if (ref $arg eq 'ARRAY') {
            push @{ $use[-1]->{args} ||= [] }, @$arg;
        }
        elsif (ref $arg eq 'HASH') {
            $use[-1] = { %{$use[-1]}, %$arg };
        }
        elsif (is_lax($arg)) {
            if (@use) {
                $use[-1]{version} = $arg;
                next;
            }

            my $perl_version = version->parse($arg)->numify;
            push @use, { name => $perl_version };
            if ($perl_version >= 5.009003 and $perl_version < 6) {
                my $sub_version = int(($perl_version - 5) * 1000);
                push @use, { name => 'strict' };
                push @use, { name => 'feature', args => [":5.$sub_version"] };
            }
        }
        else {
            push @use, { name => $arg };
        }
    }
    return ({'' => { use => \@use }}, '');
}

1;

__END__

=encoding utf8

=head1 NAME

use - Import several modules with a single use statement

=head1 SYNOPSIS

    # Import several modules at once
    use use qw[ strict warnings methods invoker ];

    # Pass options as array refs
    use use 'strict', 'warnings', 'HTTP::Status' => [':constants'];

    # Pass required versions after module names
    use use '5.12.0', 'HTTP::Status' => '6.00' => [':constants'];

    # ...or in your own module, importing on behalf of its caller:
    package perl5::foo;
    sub import {
        use use;
        local @_ = qw[ methods invoker ];
        goto &use::use;
    }

=head1 DESCRIPTION

This module lets you import several modules at once.

This is almost the same as L<modules>, except that C<caller> is
properly set up so syntax-altering modules based on L<Devel::Declare>,
L<Filter::Simple> or L<Module::Compile> work correctly.

If a Perl version number larger than C<5.9.3> appears as the first argument,
then it's automatically expanded just like a regular C<use VERSION> statement.
For example, C<use use '5.12.0'> expands to C<use strict; use feature ':5.12'>.

=head1 SEE ALSO

L<rig>, L<modules>

=head1 AUTHORS

唐鳳 E<lt>cpan@audreyt.orgE<gt>

=head1 CC0 1.0 Universal

To the extent possible under law, 唐鳳 has waived all copyright and related
or neighboring rights to L<use>.

This work is published from Taiwan.

L<http://creativecommons.org/publicdomain/zero/1.0>

=cut
