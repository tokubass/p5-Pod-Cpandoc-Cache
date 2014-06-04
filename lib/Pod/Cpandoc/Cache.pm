package Pod::Cpandoc::Cache;
use 5.008005;
use strict;
use warnings;
use Carp;
use parent 'Pod::Cpandoc';
use File::Spec::Functions qw(catfile catdir);
use File::Basename qw(dirname);
use File::Path qw(mkpath);
use File::Copy;
use Class::Method::Modifiers;
use Time::Piece 1.16;

our $VERSION = "0.01";
use constant DEBUG => $ENV{POD_CPANDOC_CACHE_DEBUG};
use constant TTL => 3600*24;

sub live_cpan_url {
    my $self   = shift;
    my $module = shift;
    if ($self->opt_c) {
        return $self->SUPER::live_cpan_url($module);
    }
    "http://api.metacpan.org/v0/source/$module";
}

around 'searchfor' => sub {
    my $orig = shift;
    my ($self, undef, $module_name) = @_;

    if ( my $found = $self->search_from_cache($module_name)) {
        return ($found);
    }

    my @found = $orig->(@_) or return;

    warn "found number: ", scalar @found if DEBUG;
    warn "found file: " . $found[0] if DEBUG;

    $self->put_cache_file($found[0],$module_name);

    return @found;
};

sub search_from_cache {
    my $self = shift;
    my $module_name = shift;
    my $path = $self->module2path($module_name);
    return unless (-f $path);

    my $mtime = (stat($path))[9];

    if ( (localtime->epoch - localtime($mtime)->epoch) > TTL() ) {
        warn 'expire cache' if DEBUG;
        return;
    }else{
        warn 'search from cache' if DEBUG;
        return $path;
    }
}

sub is_tempfile {
    my $self = shift;
    my $file_name = shift;
    my $module_name = shift;

    my $hyphenated_module_name = sprintf("%s", join('-',split('::',$module_name)) );
    $file_name =~ /${hyphenated_module_name}-[a-zA-Z0-9]{4}\.pm\z/;
}

sub cache_root_dir {
    my $self = shift;
    $self->{cache_root_dir} ||=
        $ENV{POD_CPANDOC_CACHE_ROOT} || catdir($ENV{HOME}, '.pod_cpandoc_cache');
}

sub module2path {
    my $self = shift;
    my $module_name = shift;
    my $cache_file = catfile($self->cache_root_dir,split('::',$module_name)) . '.pm';
    return $cache_file;
}

sub put_cache_file {
    my $self = shift;
    my $tempfile_name = shift;
    my $module_name = shift;

    if ($self->is_tempfile($tempfile_name,$module_name)) {
        warn "put cache file: " . $self->module2path($module_name) if DEBUG;
        my $path = $self->module2path($module_name);
        mkpath(dirname($path));
        copy($tempfile_name,$path) or die "Copy failed: $!";
    }
}


1;
__END__

=encoding utf-8

=head1 NAME

Pod::Cpandoc::Cache - It's new $module

=head1 SYNOPSIS

    use Pod::Cpandoc::Cache;

=head1 DESCRIPTION

Pod::Cpandoc::Cache is ...

=head1 LICENSE

Copyright (C) tokubass.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

tokubass E<lt>tomi21110@gmail.comE<gt>

=cut

