#!/usr/bin/perl
#use strict;
use warnings;
#use Switch;
use Data::Dumper;
use Time::Piece;
use Env;


#----- Valido el input -------
my $num_args = $#ARGV + 1;
if ($num_args == 0) {
	die "InfPro necesita, al menos, un argumento. Ejecute 'InfPro.pl -a' para ver informacion al respecto";
}
my %options = ();
foreach (@ARGV) {
	$options{"c"} = 1 if ($_=~m/^-c/);
	$options{"a"} = 1 if ($_=~m/^-a/);
	$options{"e"} = 1 if ($_=~m/^-e/);
	$options{"i"} = 1 if ($_=~m/^-i/);
	$options{"g"} = 1 if ($_=~m/^-g/);
	$options{"keyword"} = $_ if ($_!~m/^-[caeig]/);
}
#----- Formateo inicial --------

$keyword = $options{"keyword"};
@fileList = ();
%estadisticaFileList = ();
%filters = ();

#------ Lanzo la opcion que corresponda ------
if ($options{"c"}) {
	&doConsulta;
} elsif ($options{"a"}) {

} elsif ($options{"i"}) {
	&doInforme();
} elsif ($options{"e"}) {
	&doEstadistica();
}

#-------- Funciones de consulta ---------

sub doConsulta {
	&initConsulta();
	do {
		&showQueryMenu;
	} until (!&isEmptyFilter);
	my $procdir = $ENV{'PROCDIR'};
	my @dlist;
	if (opendir(DIRH,"$procdir")) {
		@dlist=readdir(DIRH);
		closedir(DIRH);
	} else {
		die("No se pudo abrir el directorio de $procdir");
	}
	foreach (@dlist) {
		# ignorar . y .. :
		next if ($_ eq "." || $_ eq ".." || $_ eq "proc");
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
	&applyFilters();
	&sortResults();
	&printResults();
	&saveQuery() if ($options{'g'});
}

sub initConsulta {
	$filters{tNorma}->{code}	= \&applyTNormaFilter;
	$filters{tNorma}->{desc}	= "\n \t- Filtro por tipo de norma: escriba el tipo de norma y presione enter, o solo presione enter si no desea aplicar este filtro.\n";
	$filters{tNorma}->{param}	= undef;
	$filters{tNorma}->{validator}	= \&validateTNorma;
	$filters{tNorma}->{errorMsg}	= "El tipo de norma ingresado no es valido. Ingrese un tipo de norma Valido. \n";
	$filters{anio}->{code}	=  \&applyAnioFilter;
	$filters{anio}->{desc}	= "\n \t- Filtro por año: Ingrese un rango de años de la forma 'xxxx-yyyy', o presione enter si no desea aplicar este filtro.\n";
	$filters{anio}->{param}	= undef;
	$filters{anio}->{validator}	= \&validateYear;
	$filters{anio}->{errorMsg}	= "El rango de años ingresado no es valido. Por favor, ingrese un rango de años valido.\n";
	$filters{nNorma}->{code} 	= \&applyNNormaFilter;
	$filters{nNorma}->{desc} 	= "\n \t- Filtro por numero de norma: Ingrese un rango de numeros de la forma 'xxxx-yyyy', o presione enter si no desea aplicar este filtro.\n";
	$filters{nNorma}->{param}	= undef;
	$filters{nNorma}->{validator}	= \&validateNNorma;
	$filters{nNorma}->{errorMsg}	= "El numero de norma ingresado no es valido. Por favor ingrese un numero de norma valido.\n";
	$filters{gestion}->{code}	= \&applyGestionFilter;
	$filters{gestion}->{desc}	= "\n \t- Filtro por gestion: Ingrese el nombre de una gestion, o presione enter si no desea aplicar este filtro.\n";
	$filters{gestion}->{param}= undef;
	$filters{gestion}->{validator}= \&validateGestion;
	$filters{gestion}->{errorMsg}= "La gestion ingresada no es valida. Por favor, ingrese una gestion valida.\n";
	$filters{emisor}->{code} 	= \&applyEmisorFilter;
	$filters{emisor}->{desc} 	= "\n \t- Filtro por emisor: Ingrese el nombre de un emisor, o presione enter si no desea aplicar este filtro.\n";
	$filters{emisor}->{param} = undef;
	$filters{emisor}->{validator} = \&validateEmisor;
	$filters{emisor}->{errorMsg} = "El emisor ingresado no es valido. Por favor, ingreso un emisor valido. \n";
}

sub parseDoc {
	my $file = shift;
	open(FILE, "$file") or return 0;
	while (my $line = <FILE>) {
		my @splittedLine = split(';', $line);
		chomp($splittedLine[13]);
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
			'peso' => 0,
		);
		push @fileList, \%fileParsed;
	}
}

#-----------Funciones de Informe -----------

sub doInforme {
	&initConsulta();
	do {
		&showQueryMenu;
	} until (!&isEmptyFilter);

	my $INFODIR = $ENV{"INFODIR"};
	my @flist;

	if (opendir(DIRH, "$INFODIR")) {
		@flist=readdir(DIRH);
		closedir(DIRH);
	}  else {
		die("No se pudo abrir el directorio de $INFODIR");
	}
	foreach (@flist) {
		if ($_ eq '.' or $_ eq '..') {
			next;
		}
		&parseDocInforme("$INFODIR/$_");
	}

	&applyFilters();
	&sortResults();
	&printResults();
	&saveInforme();
}

sub parseDocInforme {
	my $file = shift;
	open(FILE, "$file") or return 0;
	while (my $line = <FILE>) {
		my @splittedLine = split(';', $line);
		chomp($splittedLine[9]);
		my %fileParsed = (
			'cod_norma' => $splittedLine[0],
			'emisor' => $splittedLine[1],
			'cod_emisor' => $splittedLine[2],
			'nro_norma' => $splittedLine[3],
			'anio_norma' => $splittedLine[4],
			'cod_gestion' => $splittedLine[5],
			'fecha_norma' => $splittedLine[6],
			'causante' => $splittedLine[7],
			'extracto' => $splittedLine[8],
			'id_registro' => $splittedLine[9],
			'peso' => 0,
		);
		push @fileList, \%fileParsed;
	}
}

sub saveInforme {
	my $INFODIR = $ENV{"INFODIR"};
	opendir(DIR, $INFODIR);
	@files = grep(/^informe_/,readdir(DIR));
	closedir(DIR);
	my $counter = sprintf("%03d", $#files +1);
	my $filename = $INFODIR . '/informe_' . $counter;
	open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
	foreach (@fileList) {
		 print $fh "$_->{'cod_norma'};$_->{'emisor'};$_->{'cod_emisor'};$_->{'nro_norma'};$_->{'anio_norma'};$_->{'cod_gestion'};$_->{'fecha_norma'};$_->{'causante'};$_->{'extracto'};$_->{'idRegistro'}\n";
	}
	close $fh;
	print "Salida guardada en $INFODIR/resultado_$counter";
}

#----------- Funciones de Estadistica -------------

sub doEstadistica {
	&initEstadistica();
	do {
		&showQueryMenu;
	} until (!&isEmptyFilter);
	my $procdir = $ENV{'PROCDIR'};
	my @dlist;
	if (opendir(DIRH,"$procdir")) {
		@dlist=readdir(DIRH);
		closedir(DIRH);
	} else {
		die("No se pudo abrir el directorio de $procdir");
	}
	foreach (@dlist) {
		# ignorar . y .. :
		next if ($_ eq "." || $_ eq ".." || $_ eq "proc");
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
				my @file_contents = &parseDocEstadistica("$dir/$_");
			}
		}
	}
	&joinEstadisticas();
	&applyFilters();
	&sortResultsByDate();
	&printResultsEstadisticas();
	&saveQueryEstadisticas();
}

sub initEstadistica {
	$filters{anio}->{code}	=  \&applyAnioFilter;
	$filters{anio}->{desc}	= "\n \t- Filtro por año: Ingrese un rango de años de la forma 'xxxx-yyyy', o presione enter si no desea aplicar este filtro.\n";
	$filters{anio}->{param}	= undef;
	$filters{anio}->{validator}	= \&validateYear;
	$filters{anio}->{errorMsg}	= "El rango de años ingresado no es valido. Por favor, ingrese un rango de años valido.\n";
	$filters{gestion}->{code}	= \&applyGestionFilter;
	$filters{gestion}->{desc}	= "\n \t- Filtro por gestion: Ingrese el nombre de una gestion, o presione enter si no desea aplicar este filtro.\n";
	$filters{gestion}->{param}= undef;
	$filters{gestion}->{validator}= \&validateGestion;
	$filters{gestion}->{errorMsg}= "La gestion ingresada no es valida. Por favor, ingrese una gestion valida.\n";
}

sub parseDocEstadistica {
	my $file = shift;
	open(FILE, "$file") or return 0;
	my %procesedFile = ();
	$procesedFile{'cod_gestion'} = '';
	$procesedFile{'anio_norma'} = '';
	$procesedFile{'convenios'} = 0;
	$procesedFile{'resoluciones'} = 0;
	$procesedFile{'disposiciones'} = 0;
	$procesedFile{'fecha_norma'} = '';
	@emisores = ();

	while (my $line = <FILE>) {
		my @splittedLine = split(';', $line);
		print $#splittedLine;
		if (!length $procesedFile{'cod_gestion'}) {
			$procesedFile{'cod_gestion'} = $splittedLine[11];
		}
		if ($procesedFile{'anio_norma'} eq '') {
			$procesedFile{'anio_norma'} = $splittedLine[3];
		}
		if ($procesedFile{'fecha_norma'} eq '') {
			$procesedFile{'fecha_norma'} = $splittedLine[1];
		}
		$procesedFile{'convenios'}++ if ($splittedLine[12] eq 'CON');
		$procesedFile{'resoluciones'}++ if ($splittedLine[12] eq 'RES');
		$procesedFile{'disposiciones'}++ if ($splittedLine[12] eq 'DIS');
		chomp($splittedLine[13]);
		my $found = 0;
		foreach my $emisor (@emisores) {
			if ( $emisor eq $splittedLine[13] ) {
				$found = 1;
				last;
			}
		}
		push(@emisores, $splittedLine[13]) if (!$found);
	}
	@{$procesedFile{'emisores'}} = @emisores;
	push @fileList, \%procesedFile;
}

sub printResultsEstadisticas {
	my $i = 1;
	foreach (@fileList) {
		my $emisoresList = $_->{'emisores'};
		my $emisores = join(', ', @$emisoresList);
		print "$i) Gestion: $_->{'cod_gestion'} Año: $_->{'anio_norma'} Emisores: $emisores \n";
		print "\tCantidad de resoluciones: $_->{'resoluciones'} \n";
		print "\tCantidad de disposiciones: $_->{'disposiciones'} \n";
		print "\tCantidad de convenios: $_->{'convenios'} \n";
		$i++;
	}
}

sub saveQueryEstadisticas {
	my $INFODIR = $ENV{"INFODIR"};
	opendir(DIR, $INFODIR);
	@files = grep(/^estadistica_/,readdir(DIR));
	closedir(DIR);
	my $counter = sprintf("%03d", $#files +1);
	my $filename = $INFODIR . '/estadistica_' . $counter;
	open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
	foreach (@fileList) {
		my $emisoresList = $_->{'emisores'};
		my $emisores = join(', ', @$emisoresList);
		print $fh "Gestion: $_->{'cod_gestion'} Año: $_->{'anio_norma'} Emisores: $emisores \n";
		print $fh "\tCantidad de resoluciones: $_->{'resoluciones'} \n";
		print $fh "\tCantidad de disposiciones: $_->{'disposiciones'} \n";
		print $fh "\tCantidad de convenios: $_->{'convenios'} \n";
	}
	close $fh;
	print "Salida guardada en $INFODIR/estadistica_$counter\n\n";
}

sub joinEstadisticas {
	foreach my $file (@fileList) {
		$estadisticaFileList{$file->{'cod_gestion'} . $file->{'anio_norma'}}->{'cod_gestion'} = $file->{'cod_gestion'};
		$estadisticaFileList{$file->{'cod_gestion'} . $file->{'anio_norma'}}->{'anio_norma'} = $file->{'anio_norma'};
		$estadisticaFileList{$file->{'cod_gestion'} . $file->{'anio_norma'}}->{'fecha_norma'} = $file->{'fecha_norma'};
		
		my @emisores = ();
		if (defined $estadisticaFileList{$file->{'cod_gestion'} . $file->{'anio_norma'}}->{'emisores'}) {
			@emisores = @{$estadisticaFileList{$file->{'cod_gestion'} . $file->{'anio_norma'}}->{'emisores'}};
			foreach my $emisor (@{$file->{'emisores'}}) {
				my $found = 0;
				foreach (@emisores) {
					$found = 1 if ($_ eq $emisor);
				}
				push(@emisores, $emisor) if ($found);
			}
		} else {
			@emisores = @{$file->{'emisores'}};
		}
		$estadisticaFileList{$file->{'cod_gestion'} . $file->{'anio_norma'}}->{'emisores'} = \@emisores; #TODO: Hacer un buen merge...
		$estadisticaFileList{$file->{'cod_gestion'} . $file->{'anio_norma'}}->{'convenios'} += $file->{'convenios'};
		$estadisticaFileList{$file->{'cod_gestion'} . $file->{'anio_norma'}}->{'resoluciones'} += $file->{'resoluciones'};
		$estadisticaFileList{$file->{'cod_gestion'} . $file->{'anio_norma'}}->{'disposiciones'} += $file->{'disposiciones'};
	}
	@fileList = ();
	foreach my $key (keys %estadisticaFileList) {
	   push @fileList, $estadisticaFileList{$key};
	}
}

#-------- Funciones Generales ---------
sub showQueryMenu {
	print "Seleccione los filtros que desee.  \n";
    foreach my $filter ( keys %filters  ) {
    	my $coderef = $filters{ $filter }->{validator}; #code reference
    	my $valid = 0;
    	do {
	    	print $filters{ $filter }->{desc} . "\n"; #printing description
	    	my $aux = <STDIN>;
	    	chomp($aux);
	    	$filters{ $filter }->{param} = $aux;
	    	$valid = $coderef->( $filters{ $filter }->{param} );
	    	if (!$valid) {
	    		print $filters{ $filter }->{errorMsg};
	    	}
    	} until ($valid);
	}
}

sub isEmptyFilter {
	foreach my $filter ( keys %filters  ) {
	    if (${filters}{$filter}->{param} ne '') {
	    	return 0;
	    }
	}
	print "\033[2J";    #clear the screen
	print "\033[0;0H"; #jump to 0,0
	print "Necesita elegir al menos un filtro.";
	return 1;
}



sub applyFilters {
	for my $filter ( keys(%filters) )  {
        my $coderef = $filters{ $filter }->{code}; #code reference
        $coderef->( $filters{ $filter }->{param} ); #calling the code ref
	}
}

sub applyTNormaFilter {
	my $filter = shift;
	if (not defined $filter or $filter eq '') {
		return;
	}
	my $fileCount = scalar @fileList;
	my $i = 0;
	while ($i < $fileCount) {
		if ($fileList[$i]{cod_norma} ne $filter) {
			splice(@fileList, $i, 1);
			$fileCount = scalar @fileList;
		} else {
			$i++;	
		}
	}
}

sub applyAnioFilter {
	my $filter = shift;
	if (not defined $filter or $filter eq '') {
		return;
	}
	my $fileCount = scalar(@fileList);
	my $i = 0;
	my @filterSplitted = split('-', $filter);
	print $fileCount;
	while ($i < $fileCount) {
		if ($fileList[$i]{anio_norma} <= $filterSplitted[0] || $fileList[$i]{anio_norma} >= $filterSplitted[1]) {
			splice(@fileList, $i, 1);
			$fileCount = scalar @fileList;
		} else {
			$i++;
		}
	}
}

sub applyNNormaFilter {
	my $filter = shift;
	if (not defined $filter or $filter eq '') {
		return;
	}
	my $fileCount = scalar(@fileList);
	my $i = 0;
	my @filterSplitted = split('-', $filter);
	while ($i < $fileCount) {
		if ($fileList[$i]{nro_norma} < $filterSplitted[0] || $fileList[$i]{nro_norma} > $filterSplitted[1]) {
			splice(@fileList, $i, 1);
			$fileCount = scalar(@fileList);
		} else {
			$i++;	
		}
		
	}
}

sub applyGestionFilter {
	my $filter = shift;
	if (not defined $filter or $filter eq '') {
		return;
	}
	my $fileCount = scalar(@fileList);
	my $i = 0;
	while ($i < $fileCount) {
		if ($fileList[$i]{cod_gestion} ne $filter) {
			splice(@fileList, $i, 1);
			$fileCount = scalar(@fileList);
		} else {
			$i++;	
		}
	}
}

sub applyEmisorFilter {
	my $filter = shift;
	if (not defined $filter or $filter eq '') {
		return;
	}
	my $fileCount = scalar(@fileList);
	my $i = 0;
	while ($i < $fileCount) {
		if ($fileList[$i]{cod_emisor} ne $filter) {
			splice(@fileList, $i, 1);
			$fileCount = scalar(@fileList);
		} else {
			$i++;	
		}
	}
}

sub sortResults {
	if (not defined $keyword or $keyword eq '') {
		return &sortResultsByDate();
	} else {
		return &sortResultsByWeigth();
	}
}

sub sortResultsByWeigth {
	my $arrayLength = scalar (@fileList);
	foreach my $i (0..$arrayLength -1 ) {
		my $causante = $fileList[$i]->{causante};
		my $causanteCount = () = $causante =~ /$keyword/g;
		my $extracto = $fileList[$i]->{extracto};
		my $extractoCount = () = $extracto =~ /$keyword/g;
		$fileList[$i]->{peso} = $causanteCount * 10 + $extractoCount;
	}
	foreach my $i (0..$arrayLength-2) {
		foreach my $j ($i+1 .. $arrayLength-1) {
			if ($fileList[$i]->{peso} < $fileList[$j]->{peso}) {
				&swapFiles( $i, $j);
			} elsif ($fileList[$i]->{peso} == $fileList[$j]->{peso}) {
				if (&formatDate($fileList[$i]->{fecha_norma}) > &formatDate($fileList[$j]->{fecha_norma})) {
					&swapFiles( $i, $j);
				}
			}
		}
	}

}

sub sortResultsByDate {
	my $arrayLength = scalar (@fileList);
	foreach my $i (0..$arrayLength-2) {
		foreach my $j ($i+1 .. $arrayLength-1) {
			if (&formatDate($fileList[$i]->{fecha_norma}) < &formatDate($fileList[$j]->{fecha_norma})) {
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
		 print "$i) $_->{'cod_norma'} $_->{'cod_emisor'} $_->{'nro_norma'}/$_->{'anio_norma'} $_->{'cod_gestion'} $_->{'fecha_norma'} $_->{'peso'} \n
		 	\t $_->{'causante'} \n
		 	\t $_->{'extracto'} \n\n";
		 $i++;
	}
}

sub saveQuery {
	my $INFODIR = $ENV{"INFODIR"};
	opendir(DIR, $INFODIR);
	@files = grep(/^resultado_/,readdir(DIR));
	closedir(DIR);
	my $counter = sprintf("%03d", $#files +1);
	my $filename = $INFODIR . '/resultado_' . $counter;
	open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
	foreach (@fileList) {
		 print $fh "$_->{'cod_norma'};$_->{'emisor'};$_->{'cod_emisor'};$_->{'nro_norma'};$_->{'anio_norma'};$_->{'cod_gestion'};$_->{'fecha_norma'};$_->{'causante'};$_->{'extracto'};$_->{'idRegistro'}\n";
	}
	close $fh;
	print "Salida guardada en $INFODIR/resultado_$counter\n\n";
}


#-------------- VALIDATION FUNCTIONS ---------------------

sub validateYear {
	my $year = shift;
	return 1 if ($year eq '');
	return 0 if ($year!~m/[0-9]+-[0-9]+$/);
	my @splittedYear = split('-', $year);
	return 0 if ($splittedYear[0] > $splittedYear[1]);
	return 0 if ($splittedYear[0] < 0);
	my $t = Time::Piece->new();
	return 0 if ($splittedYear[1] > $t->year);
	return 1;
}

sub validateNNorma {
	my $nNorma = shift;
	return 1 if ($nNorma eq '');
	return 0 if ($nNorma!~m/[0-9]+-[0-9]+$/);
	my @splittedNNorma = split('-', $nNorma);
	return 0 if ($splittedNNorma[0] > $splittedNNorma[1]);
	return 0 if ($splittedNNorma[0] < 0);
	return 1;
}

sub validateTNorma {
	my $tNorma = shift;
	return 1 if ($tNorma eq '');
	my $MAEDIR = "MAEDIR";
	my $filename = $MAEDIR . '/normas.mae';
	open(FILE, "$filename") or die "Could not open file '$filename' $!";
	while (my $line = <FILE>) {
		my @splittedLine = split(';', $line);
		return 1 if ($tNorma eq $splittedLine[0]);
	}
	return 0;
}

sub validateGestion {
	my $gestion = shift;
	return 1 if ($gestion eq '');
	my $MAEDIR = "MAEDIR";
	my $filename = $MAEDIR . '/gestiones.mae';
	open(FILE, "$filename") or die "Could not open file '$filename' $!";
	while (my $line = <FILE>) {
		my @splittedLine = split(';', $line);
		return 1 if ($gestion eq $splittedLine[0]);
	}
	return 0;
}

sub validateEmisor {
	my $emisor = shift;
	return 1 if ($emisor eq '');
	my $MAEDIR = "MAEDIR";
	my $filename = $MAEDIR . '/emisores.mae';
	open(FILE, "$filename") or die "Could not open file '$filename' $!";
	while (my $line = <FILE>) {
		my @splittedLine = split(';', $line);
		return 1 if ($emisor eq $splittedLine[0]);
	}
	return 0;
}