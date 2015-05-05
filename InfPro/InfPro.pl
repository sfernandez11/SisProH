#!/usr/bin/perl
use strict;
use warnings;
use Switch;
do 'InfProConsulta.pm';

my $num_args = $#ARGV + 1;
if ($num_args == 0) {
	die "InfPro necesita, al menos, un argumento. Ejecute 'InfPro.pl -a' para ver informacion al respecto";
}

my $keyword = $ARGV[1];

switch ($ARGV[0]) {
	case 'a' {}
	case 'c' {
		my $query = InfProQuery->new('', $keyword);
		$query->runQueryMode();
	}
	case 'i' {}
	case 'e' {}
}
