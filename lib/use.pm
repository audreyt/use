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
        elsif (is_lax($arg) and @use) {
            $use[-1]{version} = $arg;
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

This module imports several modules at once into its caller's package.

This is almost the same as the L<modules> module, except that C<caller>
is properly set up so syntax-altering modules based on L<Devel::Declare>,
L<Filter::Simple> or L<Module::Compile> can work corrcetly.

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
