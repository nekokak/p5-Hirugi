use inc::Module::Install;
name 'Hirugi';
all_from 'lib/Hirugi.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
