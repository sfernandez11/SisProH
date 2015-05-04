package InfProQuery;

use strict;
use warnings;
use Data::Dumper;

sub new {
	my $this	= shift; 
	my $save = shift;
	my $keyword = shift;
 #    my $class 	= ref($this) || $this; 	
	my $self 	= {};
	# $self->{filters} = ();
	bless($self, $this);
	$self->{save}	= $save;
	$self->{keyword} = $keyword;
	$self->{filters}->{tNorma}->{code}	= \&{$self->applyTNormaFilter};
    $self->{filters}->{tNorma}->{desc}	= "\n \tFiltro por tipo de norma: escriba el tipo de norma y presione enter, o solo presione enter si no desea aplicar este filtro.\n";
    $self->{filters}->{tNorma}->{param}	= undef; #to show this is expected eventually
    $self->{filters}->{anio}->{code}	= \&{$self->applyAnioFilter};
    $self->{filters}->{anio}->{desc}	= "\n \t- Filtro por año: Ingrese un rango de años de la forma 'xxxx-yyyy', o presione enter si no desea aplicar este filtro.\n";
    $self->{filters}->{anio}->{param}	= undef; 
    $self->{filters}->{nNorma}->{code} 	= \&{$self->applyNNormaFilter};
    $self->{filters}->{nNorma}->{desc} 	= "\n \t- Filtro por numero de norma: Ingrese un rango de numeros de la forma 'xxxx-yyyy', o presione enter si no desea aplicar este filtro.\n";
    $self->{filters}->{nNorma}->{param}	= undef;
    $self->{filters}->{gestion}->{code}	= \&{$self->applyGestionFilter};
    $self->{filters}->{gestion}->{desc}	= "\n \t- Filtro por gestion: Ingrese el nombre de una gestion, o presione enter si no desea aplicar este filtro.\n";
    $self->{filters}->{gestion}->{param}= undef; 
    $self->{filters}->{emisor}->{code} 	= \&{$self->applyEmisorFilter};
    $self->{filters}->{emisor}->{desc} 	= "\n \t- Filtro por emisor: Ingrese el nombre de un emisor, o presione enter si no desea aplicar este filtro.\n";
    $self->{filters}->{emisor}->{param} = undef;
    return $self;
    #return(bless($self, $class));
}

sub runQueryMode {
	my $self = shift;
	do {
		$self->showQueryMenu();
	} until (!$self->isEmptyFilter());
	my $procdir = "PROCDIR";
	my @dlist;
	if (opendir(DIRH,"$procdir")) {
		@dlist=readdir(DIRH);
		closedir(DIRH);
	} else {
		die("No se pudo abrir el directorio de PROCDIR");
	}
	my @fileList = ();
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
				my @file_contents = $self->parseDoc("$dir/$_");
				push(@fileList, @file_contents);
			}
		}
	}
	#@fileList = $self->applyFilters(\@fileList);
	$self->sortResults('', \@fileList);
	$self->printResults(\@fileList);
}

sub showQueryMenu {
	my $self = shift;
	print "Seleccione los filtros que desee.  \n";
    foreach my $filter ( keys %{ $self->{filters} } ) {
    	print $self->{filters}->{ $filter }->{desc} . "\n"; #printing description
    	my $aux = <STDIN>;
    	$self->{filters}->{ $filter }->{param} = chomp($aux);
	}
}

sub isEmptyFilter {
	my $self = shift;
	my @filtersKeys = keys($self->{filters});
	for my $filter (@filtersKeys) {
	    if (chomp($self->{filters}{$filter}) ne '') {
	    	return 0;
	    }
	}
	print "\033[2J";    #clear the screen
	print "\033[0;0H"; #jump to 0,0
	print "Necesita elegir al menos un filtro.";
	return 1;
}

sub parseDoc {
	my $self = shift;
	my $file = shift;
	my @fileList = ();
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

	return @fileList;
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
	my $self 		= shift;
	my @file_list 	= shift;
    #print "La lista de archivos es:\n";
    #print Dumper \@file_list;
    
	for my $filter ( keys($self->{filters}) )  {
		print "Voy a aplicar el filtro $filter en la lista de archivos con el parametro: (" 
      		.  $self->{filters}->{ $filter }->{param} . ")\n"; 
            
        my $coderef = $self->{filters}->{ $filter }->{code}; #code reference
        #&$coderef->( \@file_list, chomp($self->{filters}->{ $filter }->{param}) ); #calling the code ref
       # &$coderef->();
	}
	return @file_list;
}

sub applyTNormaFilter {
	my $self = shift;
	my $filter = shift;
	my @fileList = shift;
	if (not defined $filter) {
		return @fileList;
	}
	foreach my $i (0 .. $#fileList) {
		if ($fileList[$i]{cod_norma} ne $filter) {
			splice(@fileList, $i, 1);
		}
	}
	return @fileList;
}

sub applyAnioFilter {
	my $self = shift;
	my $filter = shift;
	my @fileList = shift;
	if (not defined $filter) {
		return @fileList;
	}
	my @filterSplitted = split('-', $filter);
	foreach my $i (0 .. $#fileList) {
		if ($fileList[$i]{anio_norma} < $filterSplitted[0] || $fileList[$i]{anio_norma} > $filterSplitted[1]) {
			splice(@fileList, $i, 1); 
		}
	}
	return @fileList;
}

sub applyNNormaFilter {
	my $self = shift;
	my $filter = shift;
	my @fileList = shift;
	if (not defined $filter) {
		return @fileList;
	}
	my @filterSplitted = split('-', $filter);
	foreach my $i (0 .. $#fileList) {
		if ($fileList[$i]{nro_norma} < $filterSplitted[0] || $fileList[$i]{nro_norma} > $filterSplitted[1]) {
			splice(@fileList, $i, 1); 
		}
	}
	return @fileList;
}

sub applyGestionFilter {
	my $self = shift;
	my $filter = shift;
	my @fileList = shift;
	if (not defined $filter) {
		return @fileList;
	}
	foreach my $i (0 .. $#fileList) {
		if ($fileList[$i]{cod_gestion} ne $filter) {
			splice(@fileList, $i, 1);
		}
	}
	return @fileList;
}

sub applyEmisorFilter {
	my $self = shift;
	my $filter = shift;
	my @fileList = shift;
	if (not defined $filter) {
		return @fileList;
	}
	foreach my $i (0 .. $#fileList) {
		if ($fileList[$i]{cod_emisor} ne $filter) {
			splice(@fileList, $i, 1);
		}
	}
	return @fileList;
}

sub sortResults {
	my $self = shift;
	my $keyWord = shift;
	my $fileList = shift;
	if (defined $keyWord and chomp($keyWord) ne '') {
		return $self->sortResultsByDate($fileList);
	} else {
		return $self->sortResultsByWeigth($fileList, $keyWord);
	}
}

sub sortResultsByWeigth {
}

sub sortResultsByDate {
	my $self = shift;
	my $filesList = shift;
	print Dumper $fileList;
	#print "tengo: $#@{$fileList}";
	# foreach my $i (0..$#filesList) {
	# 	foreach my $j ($i+1 .. $#filesList) {
	# 			print formatDate($filesList[$i]->{fecha_norma});
	# 		if ($self->formatDate($filesList[$i]->{fecha_norma}) > $self->formatDate($filesList[$j]->{fecha_norma})) {
	# 			$self->swapFiles(\@filesList, $i, $j);
	# 		}
	# 	}
	# }
	#return @filesList;
}

sub formatDate {
	my $self = shift;
	my $date = shift;
	print $date;
	my $splittedDate = split $date, '-';
	return join '', reverse $splittedDate;
}

sub swapFiles {
	print "entre aca :D";
	my %aux = ();
	%aux = $_[0][$_[1]];
	$_[0][$_[1]] = $_[0][$_[2]];
	$_[0][$_[2]] = %aux;
}

sub printResults {
	my $self = shift;
	my $fileList = shift;
	my $i = 1;
	#print Dumper @fileList;
	foreach (@{$fileList}) {
		 print "$i) $_->{'cod_norma'} $_->{'cod_emisor'} $_->{'nro_norma'}/$_->{'anio_norma'} $_->{'cod_gestion'} $_->{'fecha_norma'} peso \n
		 	\t $_->{'causante'} \n
		 	\t $_->{'extracto'} \n\n";
		 $i++;
	}
}

return 1;