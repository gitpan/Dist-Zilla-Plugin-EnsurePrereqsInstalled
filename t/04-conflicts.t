use strict;
use warnings FATAL => 'all';

use Test::More;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';
use Test::DZil;
use Test::Fatal;
use Test::Deep;
use Path::Tiny;

my $tzil = Builder->from_config(
    { dist_root => 't/does-not-exist' },
    {
        add_files => {
            path(qw(source dist.ini)) => simple_ini(
                [ GatherDir => ],
                [ EnsurePrereqsInstalled => ],
                [ Prereqs => 'RuntimeConflicts' => { 'Test::More' => '<= 200.0' },
                ],
            ),
            path(qw(source lib Foo.pm)) => "package Foo;\n1;\n",
        },
    },
);

$tzil->chrome->logger->set_debug(1);

like(
    exception { $tzil->build },
    qr/^\Q[EnsurePrereqsInstalled] Conflicts found\E/m,
    'build aborted',
);

cmp_deeply(
    $tzil->log_messages,
    superbagof(
        '[EnsurePrereqsInstalled] checking that all authordeps are satisfied...',
        '[EnsurePrereqsInstalled] checking that all prereqs are satisfied...',
        "[EnsurePrereqsInstalled] Conflicts found:
[EnsurePrereqsInstalled]     Installed version ($Test::More::VERSION) of Test::More is in range '<= 200.0'
[EnsurePrereqsInstalled] To remedy, do:  pm-uninstall Test::More",
    ),
    'build was aborted, with remedy instructions',
) or diag 'got: ', explain $tzil->log_messages;

done_testing;
