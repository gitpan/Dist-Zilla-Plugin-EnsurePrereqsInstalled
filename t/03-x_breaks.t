use strict;
use warnings FATAL => 'all';

use Test::More;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';
use Test::DZil;
use Test::Fatal;
use Test::Deep;
use Path::Tiny;

use lib 't/lib';

my $tzil = Builder->from_config(
    { dist_root => 't/does-not-exist' },
    {
        add_files => {
            path(qw(source dist.ini)) => simple_ini(
                [ GatherDir => ],
                [ EnsurePrereqsInstalled => ],
                [ '=Breaks' => {
                    'Test::More' => '<= 200.0',  # fails
                  }
                ],
            ),
            path(qw(source lib Foo.pm)) => "package Foo;\n1;\n",
        },
    },
);

$tzil->chrome->logger->set_debug(1);

like(
    exception { $tzil->build },
    qr/^\Q[EnsurePrereqsInstalled] Breakages found\E/m,
    'build aborted',
);

# allow for dev releases - Module::Metadata includes _, but $VERSION does not.
my $TM_VERSION = join '_?', split //, $Test::More::VERSION;

cmp_deeply(
    $tzil->log_messages,
    superbagof(
        '[EnsurePrereqsInstalled] checking that all authordeps are satisfied...',
        '[EnsurePrereqsInstalled] checking that all prereqs are satisfied...',
        '[EnsurePrereqsInstalled] checking x_breaks...',
        re(qr/^\Q[EnsurePrereqsInstalled] Breakages found:
[EnsurePrereqsInstalled]     Installed version (\E$TM_VERSION\Q) of Test::More is in range '<= 200.0'
[EnsurePrereqsInstalled] To remedy, do:  cpanm Test::More\E$/ms),
    ),
    'build was aborted: x_breaks entries were checked',
) or diag 'got log messages: ', explain $tzil->log_messages;

done_testing;
