use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Graphics::Asymptote',
    license             => 'perl',
    dist_author         => 'David Mertens <dcmertens.perl+Asymptote@gmail.com>',
    dist_version_from   => 'lib/Graphics/Asymptote.pm',
    requires => {
        'Test::More'  => 0,
        'version'     => 0,
		'Time::HiRes' => 0,
    },
	recommends => {
		'PDL'         => 0,
	},
	
    add_to_cleanup      => [ 'Graphics-Asymptote-*' ],
);

$builder->create_build_script();
