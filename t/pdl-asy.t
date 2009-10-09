#!perl

use Test::More tests => '7';
use strict;
use warnings;

# skip tests if no PDL
# test send_pdl stuff, specifically if it barfs on a non-piddle

SKIP:
{
	eval 'use PDL';
	skip('because PDL is required for PDL::Graphics::Asymptote', 7) if $@;
	
	use_ok( 'PDL::Graphics::Asymptote' );
	
	my $asy = PDL::Graphics::Asymptote->new;
	
	isa_ok($asy, 'PDL::Graphics::Asymptote');

	### Check diagnostic messages ###
	
	# test the parity check
	my $piddle = sequence(10);
	my $high_d = sequence(2,2,2);
	eval {$asy->send_pdl($piddle)};
	like($@, qr/I expected an even number/,
		'send_pdl checks for parity in the number of arguments');
	
	# test the type checking
	eval {$asy->send_pdl(asyvar => 'abcde')};
	like($@, qr/expecting a piddle but I got something else/,
		'send_pdl barfs on bad type');


	### Check what is sent ###


	# create the special file handle that will collect the output
	my $message;
	open (my $fh, '>', \$message);
	select $fh;

	# set verbosity to one
	$asy++;
	$asy->send_pdl(var => $piddle);						# shouldn't display the send results
	$asy++;
	$asy->send_pdl(var => $piddle);						# should display the send results
	$asy->send_pdl(var => $high_d);						# should properly send high-dimensional arrays
	$asy->set_verbosity;

	select STDOUT;
	close $fh;

	$message =~ s/^\*.+\n//;							# Get rid of the first
	$message =~ s/\n*\*.+\n+$//;						# and last lines, 
	my @chunks = split /\n\*.+\n\n\*.+\n/, $message;	# then split the message into chunks

	# Now let's examine the results
	# test a verbose = 1 variable send
	like($chunks[0], qr/pdl with dimensions 10 as var/,
		'verbosity = 1 => tells us its sending a piddle, but does not give contents');

	# test a verbose = 2 variable send
	chomp($chunks[1]);
	is($chunks[1], 'real [] var = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};',
		'verbosity = 2 => tell us the full, sent piddle');

	# test a verbose = 2 variable send
	chomp($chunks[2]);
	is($chunks[2], 'real [][][] var = { {  {0, 1},  {2, 3} }, {  {4, 5},  {6, 7} }};',
		'properly packages higher-dimensional arrays');
}
