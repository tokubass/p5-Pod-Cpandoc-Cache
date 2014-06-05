use Test::More;
use strict;
use warnings;
use Pod::Cpandoc::Cache;
use File::Spec::Functions qw(catfile catdir);
use Capture::Tiny qw/ capture /;
use Cwd();
use File::Temp qw/ tempdir /;

$ENV{POD_CPANDOC_CACHE_ROOT} = tempdir( CLEANUP => 1 );

eval { require Acme::No};
if ($@) {
    @ARGV = ('Acme::No');
    capture {
        Pod::Cpandoc::Cache->run();
    };
    ok( -f catfile($ENV{POD_CPANDOC_CACHE_ROOT}, 'Acme', 'No.pm'), '-f cache_path'  );
}else{
    ok(1);
    warn 'Hmm....this test use Acme::No, but you already installed Acme::No.';
}

ok(Pod::Cpandoc::Cache->new->search_from_cache('Acme::No'), 'serach_from_cache');


done_testing;
