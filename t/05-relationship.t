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
                [ EnsurePrereqsInstalled => { type => [ qw(requires recommends) ] } ],
                [ Prereqs => RuntimeRequires => { 'I::Am::Not::Installed' => 0 } ],
                [ Prereqs => TestRecommends => { 'Test::More' => '200.0' } ],
                [ Prereqs => BuildSuggests => { 'perl' => '500' } ],
            ),
            path(qw(source lib Foo.pm)) => "package Foo;\n1;\n",
        },
    },
);

$tzil->chrome->logger->set_debug(1);

like(
    exception { $tzil->build },
    qr/^\Q[EnsurePrereqsInstalled] Unsatisfied\E/m,
    'build aborted',
);

# allow for dev releases - Module::Metadata includes _, but $VERSION does not.
my $TM_VERSION = join '_?', split //, $Test::More::VERSION;

cmp_deeply(
    $tzil->log_messages,
    superbagof(
        '[EnsurePrereqsInstalled] checking that all authordeps are satisfied...',
        '[EnsurePrereqsInstalled] checking that all prereqs are satisfied...',
        re(qr/^\Q[EnsurePrereqsInstalled] Unsatisfied prerequisites:
[EnsurePrereqsInstalled]     Module 'I::Am::Not::Installed' is not installed
[EnsurePrereqsInstalled]     Installed version (\E$TM_VERSION\Q) of Test::More is not in range '200.0'
[EnsurePrereqsInstalled] To remedy, do:  cpanm I::Am::Not::Installed Test::More\E$/ms),
    ),
    'build was aborted: custom relationships are checked',
) or diag 'got log messages: ', explain $tzil->log_messages;

done_testing;
