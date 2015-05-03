package InfProQuery;

use strict;
use warnings;
use Data::Dumper;

sub new {
	my $this	= shift; 
	my $save = shift;
	my $keyword = shift;
    my $class 	= ref($this) || $this; 	
	my $self 	= {};
	$self->{save}	= $save;
	$self->{filters} = {};
	return(bless($self, $class));
}

sub runQueryMode {
	do {
		showQueryMenu();
	} until (!isEmptyFilter());
	my $procdir = "PROCDIR/";
	my @dlist;
	if (opendir(DIRH,"$procdir")) {
		@dlist=readdir(DIRH);
		closedir(DIRH);
	} else {
		die("No se pudo abrir el directorio de PROCDIR");
	}
	my @fileList = [];
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
				open FILE, "<$dir/$_";
				my $file_contents = paseDoc("$dir/$_");
				push @fileList, $file_contents;
			}
		}
	}
	@fileList = applyFilters(@fileList);
	@fileList = sortResults('', @fileList);
}

sub showQueryMenu {
	my $self = shift;
	print "Seleccione los filtros que desee.  \n
	\t - Filtro por tipo de norma: escriba el tipo de norma y presione enter, o solo presione enter si no desea aplicar este filtro.\n 
	\t \t";
	$self->{filters}{"tNorma"} = <STDIN>;
	print "\n \t- Filtro por año: Ingrese un rango de años de la forma 'xxxx-yyyy', o presione enter si no desea aplicar este filtro.\n
	\t \t";
	$self->{filters}{"año"} = <STDIN>;
	print "\n \t- Filtro por numero de norma: Ingrese un rango de numeros de la forma 'xxxx-yyyy', o presione enter si no desea aplicar este filtro.\n
	\t \t";
	$self->{filters}{"nNorma"} = <STDIN>;
	print "\n \t- Filtro por gestion: Ingrese el nombre de una gestion, o presione enter si no desea aplicar este filtro.\n
	\t \t";
	$self->{filters}{"gestion"} = <STDIN>;
	print "\n \t- Filtro por emisor: Ingrese el nombre de un emisor, o presione enter si no desea aplicar este filtro.\n
	\t \t";
	$self->{filters}{"emisor"} = <STDIN>;
}

sub isEmptyFilter {
	my $self = shift;
	my @filters = keys $self->{filters};
	for my $filter (@filters) {
	    if ($self->{filters}{$filter} ne '') {
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
	my @fileList = [];
	open FILE, "$file" or print "No pude abrir el archivo $file";
	while (my $line = <FILE>) {
		my @splittedLine = split(';', $line);
		my %fileParsed = {
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
		};
		push @fileList, %fileParsed;
	}
	return @fileList;
}

sub applyFilters {
	my $self = shift;
	my @fileList = shift;
	my @filters = keys $self->{filters};
	for my $filter (@filters) {
		if ($filter eq 'tNorma') {@fileList = applyTNormaFilter($self->{filters}{filter}, @filters);}
		elsif ($filter eq 'año') {@fileList = applyAnioFilter($self->{filters}{filter}, @filters);}
		elsif ($filter eq 'nNorma') {@fileList = applyNNormaFilter($self->{filters}{filter}, @filters);}
		elsif ($filter eq 'gestion') {@fileList = applyGestionFilter($self->{filters}{filter}, @filters);}
		elsif ($filter eq 'emisor') {@fileList = applyEmisorFilter($self->{filters}{filter}, @filters);}
	}
	return @filters;
}

sub applyTNormaFilter {
	my $self = shift;
	my $filter = shift;
	my @fileList = shift;
	if ($filter eq '') {
		return @fileList;
	}
	foreach my $i (0 .. $#fileList) {
		if (@fileList[$i]->{cod_norma} ne $filter) {
			splice @fileList, $i, 1;
		}
	}
	return @fileList;

}

sub applyAnioFilter {
	my $self = shift;
	my $filter = shift;
	my @fileList = shift;
	my @filterSplitted = split $filter, '-';
	if ($filter eq '') {
		return @fileList;
	}
	foreach my $i (0 .. $#fileList) {
		if (@fileList[$i]->{anio_norma} < $filterSplitted[0] || @fileList[$i]->{anio_norma} > $filterSplitted[1]) {
			splice @fileList, $i, 1; 
		}
	}
	return @fileList;
}

sub applyNNormaFilter {
	my $self = shift;
	my $filter = shift;
	my @fileList = shift;
	if ($filter eq '') {
		return @fileList;
	}
	my @filterSplitted = split $filter, '-';
	foreach my $i (0 .. $#fileList) {
		if (@fileList[$i]->{nro_norma} < $filterSplitted[0] || @fileList[$i]->{nro_norma} > $filterSplitted[1]) {
			splice @fileList, $i, 1; 
		}
	}
	return @fileList;
}

sub appliyGestionFilter {
	my $self = shift;
	my $filter = shift;
	my @fileList = shift;
	if ($filter eq '') {
		return @fileList;
	}
	foreach my $i (0 .. $#fileList) {
		if (@fileList[$i]->{cod_gestion} ne $filter) {
			splice @fileList, $i, 1;
		}
	}
	return @fileList;
}

sub applyEmisorFilter {
	my $self = shift;
	my $filter = shift;
	my @fileList = shift;
	if ($filter eq '') {
		return @fileList;
	}
	foreach my $i (0 .. $#fileList) {
		if (@fileList[$i]->{cod_emisor} ne $filter) {
			splice @fileList, $i, 1;
		}
	}
	return @fileList;
}

sub sortResults {
	my $self = shift;
	my $keyWord = shift;
	my @fileList = shift;
	if ($keyWord ne '') {
		return sortResultsByDate(@fileList);
	} else {
		return sortResultsByWeigth(@fileList, $keyWord);
	}
}

sub sortResultsByWeigth {

}

sub sortResultsByDate {
	my $self = shift;
	my @filesList = shift;
	foreach my $i (0..$#filesList) {
		foreach my $j ($i+1 .. $#filesList) {
			if (formatDate(@filesList[$i]->{fecha_norma}) > formatDate(@filesList[$j]->{fecha_norma})) {
				swapFiles(@filesList, $i, $j);
			}
		}
	}
	return @filesList;
}

sub formatDate {
	my $date = shift;
	my $splittedDate = split $date, '-';
	return join '', reverse $splittedDate;
}

sub swapFiles {
	my %aux = {};
	%aux = $_[0][$_[1]];
	$_[0][$_[1]] = $_[0][$_[2]];
	$_[0][$_[2]] = %aux;
}

sub printResults {
	my $self = shift;
	my @fileList = shift;
	my $i = 1;
	foreach (@fileList) {
		print "$i) $_{'cod_norma'} $_{'cod_emisor'} $_{'nro_norma'}/$_{'anio_norma'} $_{'cod_gestion'} $_{'fecha_norma'} peso \n
			\t $_{'causante'} \n
			\t $_{'extracto'} \n\n";
		$i++;
	}
}

return 1;