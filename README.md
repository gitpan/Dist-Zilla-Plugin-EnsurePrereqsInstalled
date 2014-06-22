# NAME

Dist::Zilla::Plugin::EnsurePrereqsInstalled - Ensure at build time that all prereqs, including developer, are satisfied

# VERSION

version 0.004

# SYNOPSIS

In your `dist.ini`:

    [EnsurePrereqsInstalled]

# DESCRIPTION

This is a [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) plugin that verifies, during the `dzil build`
process, that all required prerequisites are satisfied, including developer
prereqs.  If any prerequisites are missing, the build is aborted.

Authordeps (developer prerequisites that can be extracted directly from
`dist.ini`) are always checked at the start of the build. This would be
equivalent to calling `dzil authordeps --missing`.

All prerequisites are fetched from the distribution near the end of the build
and a final validation check is performed at that time (unless `build_phase`
is `release`, in which case the check is delayed until just prior to
performing the release).

Only 'requires', 'conflicts' and 'x\_breaks' prerequisites are checked (by
default); other types (e.g. 'recommends' and 'suggests' are ignored).

All prerequisite phases are checked: configure, build, test, runtime, develop
(and any custom x\_ keys that may also be present, given adequate toolchain
support).

# BACKGROUND

This plugin was written for a distribution that does some fiddly work during
file munging time that required the installation of a module, specified as an
`; authordep Module::Name` in `dist.ini`.  When the module is missing, an ugly exception
is printed, without a clear explanation that this module was a developer
prerequisite that ought to have been installed first.

It is this author's opinion that this check out to be performed by
[Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) itself, rather than leaving it to an optional plugin.

# CONFIGURATION OPTIONS

## type (or relationship)

    [EnsurePrereqsInstalled]
    type = requires
    type = recommends

Indicate what type(s) of prereqs are checked (requires, recommends, suggests).
Defaults to 'requires'; can be used more than once.  (Note that 'conflicts'
and 'x\_breaks' prereqs are always checked and this cannot be disabled.)

## build\_phase

    [EnsurePrereqsInstalled]
    build_phase = release

Indicates what [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) phase to perform the check at - either build
(default) or release.

# POTENTIAL FEATURES

...if anyone has an interest:

- option to exclude modules from being checked
- option to prompt to continue instead of dying on unsatisfied prereqs
- option for different treatment (warn? prompt?) for recommended, suggested prereqs

# SUPPORT

Bugs may be submitted through [the RT bug tracker](https://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-Plugin-EnsurePrereqsInstalled)
(or [bug-Dist-Zilla-Plugin-EnsurePrereqsInstalled@rt.cpan.org](mailto:bug-Dist-Zilla-Plugin-EnsurePrereqsInstalled@rt.cpan.org)).
I am also usually active on irc, as 'ether' at `irc.perl.org`.

# SEE ALSO

These plugins all do somewhat similar and overlapping things, but are all useful in their own way:

- [Dist::Zilla::Plugin::PromptIfStale](https://metacpan.org/pod/Dist::Zilla::Plugin::PromptIfStale)
- [Dist::Zilla::Plugin::CheckPrereqsIndexed](https://metacpan.org/pod/Dist::Zilla::Plugin::CheckPrereqsIndexed)
- [Dist::Zilla::Plugin::Test::ReportPrereqs](https://metacpan.org/pod/Dist::Zilla::Plugin::Test::ReportPrereqs)
- [Dist::Zilla::Plugin::Test::CheckDeps](https://metacpan.org/pod/Dist::Zilla::Plugin::Test::CheckDeps)
- [Dist::Zilla::Plugin::Test::CheckBreaks](https://metacpan.org/pod/Dist::Zilla::Plugin::Test::CheckBreaks)

# AUTHOR

Karen Etheridge <ether@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Karen Etheridge.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
