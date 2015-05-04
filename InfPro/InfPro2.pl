#!/usr/bin/perl
#use strict;
use warnings;
use Switch;
use Data::Dumper;

my $num_args = $#ARGV + 1;
if ($num_args == 0) {
	die "InfPro necesita, al menos, un argumento. Ejecute 'InfPro.pl -a' para ver informacion al respecto";
}

$keyword = $ARGV[1];
@fileList = ();
%filters = ();
$filters{tNorma}->{code}	= \&{applyTNormaFilter};
$filters{tNorma}->{desc}	= "\n \tFiltro por tipo de norma: escriba el tipo de norma y presione enter, o solo presione enter si no desea aplicar este filtro.\n";
$filters{tNorma}->{param}	= undef; #to show this is expected eventually
$filters{anio}->{code}	=  \&{applyAnioFilter};
$filters{anio}->{desc}	= "\n \t- Filtro por año: Ingrese un rango de años de la forma 'xxxx-yyyy', o presione enter si no desea aplicar este filtro.\n";
$filters{anio}->{param}	= undef; 
$filters{nNorma}->{code} 	= \&{applyNNormaFilter};
$filters{nNorma}->{desc} 	= "\n \t- Filtro por numero de norma: Ingrese un rango de numeros de la forma 'xxxx-yyyy', o presione enter si no desea aplicar este filtro.\n";
$filters{nNorma}->{param}	= undef;
$filters{gestion}->{code}	= \&{applyGestionFilter};
$filters{gestion}->{desc}	= "\n \t- Filtro por gestion: Ingrese el nombre de una gestion, o presione enter si no desea aplicar este filtro.\n";
$filters{gestion}->{param}= undef; 
$filters{emisor}->{code} 	= \&{applyEmisorFilter};
$filters{emisor}->{desc} 	= "\n \t- Filtro por emisor: Ingrese el nombre de un emisor, o presione enter si no desea aplicar este filtro.\n";
$filters{emisor}->{param} = undef;


switch ($ARGV[0]) {
	case 'a' {}
	case 'c' {
		&doConsulta;
	}
	case 'i' {}
	case 'e' {}
}


sub doConsulta {
	do {
		&showQueryMenu;
	} until (!&isEmptyFilter);
	my $procdir = "PROCDIR";
	my @dlist;
	if (opendir(DIRH,"$procdir")) {
		@dlist=readdir(DIRH);
		closedir(DIRH);
	} else {
		die("No se pudo abrir el directorio de PROCDIR");
	}
	foreach (@dlist) {
		# ignorar . y .. :
		next if ($_ eq "." || $_ eq "..");
		if ( -d "$procdir/$_" ) {
			my @flist;
			if (opendir(DIRH, "$procdir/$_")) {
				@flist=readdir(DIRH);
				closedir(DIRH);
			} else {
				next;
			}
			my $dir = "$procdir/$_";
			foreach (@flist) {
				#open FILE, "<$dir/$_";
				if ($_ eq '.' or $_ eq '..') {
					next;
				}
				my @file_contents = &parseDoc("$dir/$_");
			}
		}
	}
	@fileList = &applyFilters();
	&sortResults('');
	&printResults();
}

sub showQueryMenu {
	print "Seleccione los filtros que desee.  \n";
    foreach my $filter ( keys %filters  ) {
    	print $filters{ $filter }->{desc} . "\n"; #printing description
    	my $aux = <STDIN>;
    	$filters{ $filter }->{param} = chomp($aux);
	}
}

sub isEmptyFilter {
	foreach my $filter ( keys %filters  ) {
	    if (chomp(${filters}{$filter}->{param}) ne '') {
	    	return 0;
	    }
	}
	print "\033[2J";    #clear the screen
	print "\033[0;0H"; #jump to 0,0
	print "Necesita elegir al menos un filtro.";
	return 1;
}

sub parseDoc {
	my $file = shift;
	open(FILE, "$file") or return 0;
	while (my $line = <FILE>) {
		my @splittedLine = split(';', $line);
		my %fileParsed = (
			'fuente' => $splittedLine[0],
			'fecha_norma' => $splittedLine[1],
			'nro_norma' => $splittedLine[2],
			'anio_norma' => $splittedLine[3],
			'causante' => $splittedLine[4],
			'extracto' => $splittedLine[5],
			'cod_tema' => $splittedLine[6],
			'expedienteId' => $splittedLine[7],
			'expedienteAnio' => $splittedLine[8],
			'cod_firma' => $splittedLine[9],
			'idRegistro' => $splittedLine[10],
			'cod_gestion' => $splittedLine[11],
			'cod_norma' => $splittedLine[12],
			'cod_emisor' => $splittedLine[13],
		);
		push @fileList, \%fileParsed;
	}
}

sub applyFilters {
	# my $self = shift;
	# my @fileList = shift;
	# my @filters = keys($self->{filters});
	# for my $filter (@filters) {
	# 	print Dumper $filter;
	# 	if ($filter eq 'tNorma') {@fileList = $self->applyTNormaFilter($filter, \@fileList);}
	# 	elsif ($filter eq 'año') {@fileList = $self->applyAnioFilter($filter, \@fileList);}
	# 	elsif ($filter eq 'nNorma') {@fileList = $self->applyNNormaFilter($filter, \@fileList);}
	# 	elsif ($filter eq 'gestion') {@fileList = $self->applyGestionFilter($filter, \@fileList);}
	# 	elsif ($filter eq 'emisor') {@fileList = $self->applyEmisorFilter($filter, \@fileList);}
	# }
	# return @filters;
    
	for my $filter ( keys(%filters) )  {
		print "Voy a aplicar el filtro $filter en la lista de archivos con el parametro: (" 
      		.  $filters{ $filter }->{param} . ")\n"; 
            
        my $coderef = $filters{ $filter }->{code}; #code reference
        print Dumper $filters{ $filter }->{code};
        chomp($filters{ $filter }->{param});
        print Dumper $filters{ $filter }->{param} . "elooo";
        &$coderef->( $filters{ $filter }->{param} ); #calling the code ref
       # &$coderef->();
	}
}

sub applyTNormaFilter {
	print "aplicando filtro tnorma :D";
	my $filter = shift;
	if (not defined $filter) {
		return;
	}
	foreach my $i (0 .. $#fileList) {
		if ($self->{fileList}[$i]{cod_norma} ne $filter) {
			splice($self->{fileList}, $i, 1);
		}
	}
}

sub applyAnioFilter {
	my $filter = shift;
	if (not defined $filter) {
		return;
	}
	my @filterSplitted = split('-', $filter);
	foreach my $i (0 .. $#fileList) {
		if ($fileList[$i]{anio_norma} < $filterSplitted[0] || $fileList[$i]{anio_norma} > $filterSplitted[1]) {
			splice(@fileList, $i, 1); 
		}
	}
}

sub applyNNormaFilter {
	my $filter = shift;
	if (not defined $filter) {
		return;
	}
	my @filterSplitted = split('-', $filter);
	foreach my $i (0 .. $#fileList) {
		if ($fileList[$i]{nro_norma} < $filterSplitted[0] || $fileList[$i]{nro_norma} > $filterSplitted[1]) {
			splice(@fileList, $i, 1); 
		}
	}
}

sub applyGestionFilter {
	my $filter = shift;
	if (not defined $filter) {
		return;
	}
	foreach my $i (0 .. $#fileList) {
		if ($fileList[$i]{cod_gestion} ne $filter) {
			splice(@fileList, $i, 1);
		}
	}
}

sub applyEmisorFilter {
	my $filter = shift;
	if (not defined $filter) {
		return;
	}
	foreach my $i (0 .. $#fileList) {
		if ($fileList[$i]{cod_emisor} ne $filter) {
			splice(@fileList, $i, 1);
		}
	}
}

sub sortResults {
	my $keyWord = shift;
	if (defined $keyWord and chomp($keyWord) ne '') {
		return &sortResultsByDate();
	} else {
		return &sortResultsByWeigth($keyWord);
	}
}

sub sortResultsByWeigth {
}

sub sortResultsByDate {
	my $arrayLength = scalar (@fileList);
	foreach my $i (0..$arrayLength-2) {
		foreach my $j ($i+1 .. $arrayLength-1) {
			if (&formatDate($fileList[$i]->{fecha_norma}) > &formatDate($fileList[$j]->{fecha_norma})) {
				&swapFiles( $i, $j);
			}
		}
	}
}

sub formatDate {
	my $date = shift;
	my @splittedDate = split '/', $date ;
	my $formattedDate = join '', reverse @splittedDate;
	return $formattedDate;
}

sub swapFiles {
	my $aux = @fileList[$_[0]];
	@fileList[$_[0]] = @fileList[$_[1]];
	@fileList[$_[1]] = $aux;
}

sub printResults {
	my $i = 1;
	foreach (@fileList) {
		 print "$i) $_->{'cod_norma'} $_->{'cod_emisor'} $_->{'nro_norma'}/$_->{'anio_norma'} $_->{'cod_gestion'} $_->{'fecha_norma'} peso \n
		 	\t $_->{'causante'} \n
		 	\t $_->{'extracto'} \n\n";
		 $i++;
	}
}