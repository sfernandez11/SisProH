#!/usr/bin/perl
use strict;
use warnings;
use Switch;
use InfProConsulta;

$num_args = $#ARGV + 1;
if ($num_args == 0) die "InfPro necesita, al menos, un argumento. Ejecute 'InfPro.pl -a' para ver informacion al respecto";

$keyword = $argv[1];

switch ($argv[0]) {
	case a {}
	case c {
		$query = InfProConsulta->new(false, $keyword);
		$query->runQueryMode();
	}
	case i {}
	case e {}
}


sub 

