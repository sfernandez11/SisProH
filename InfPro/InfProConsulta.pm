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
	$procdir = "PROCDIR/";
	if (opendir(DIRH,"$procdir")) {
		@dlist=readdir(DIRH);
		closedir(DIRH);
	} else {
		die("No se pudo abrir el directorio de PROCDIR");
	}
	@filesList = [];
	foreach (@dlist) {
		# ignorar . y .. :
		next if ($_ eq "." || $_ eq "..");
		if ( -d "$procdir/$_" ) {
			if (opendir(DIRH, "$procdir/$_")) {
				@flist=readdir(DIRH);
				closedir(DIRH);
			} else {
				next;
			}
			$dir = "$procdir/$_"
			foreach (@flist) {
				open FILE, "<$dir/$_";
				$file_contents = do { local $/; <FILE> };
				push @fileList, $file_contents
			}
		}
	}
	applyFilters(@fileList);
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
	    if ($self->{filters}{$filter} ne '') return false;
	}
	print "\033[2J";    #clear the screen
	print "\033[0;0H"; #jump to 0,0
	print "Necesita elegir al menos un filtro.";
	return true;
}

sub parseDoc {
	my $self = shift;
	my $file = shift;

}

sub applyFilters {
	my $self = shift;
	my @fileList = shift;
	my @filters = keys $self->{filters};
	for my $filter (@filters) {
	    switch ($filter) {
	    	case 'tNorma' {@fileList = applyTNormaFilter(self->{filters}{filter}, @filters)}
	    	case 'año' {@fileList = applyAnioFilter(self->{filters}{filter}, @filters)}
	    	case 'nNorma' {@fileList = applyNNormaFilter(self->{filters}{filter}, @filters)}
	    	case 'gestion' {@fileList = applyGestionFilter(self->{filters}{filter}, @filters)}
	    	case 'emisor' {@fileList = applyEmisorFilter(self->{filters}{filter}, @filters)}
	    }
	}
	return @filters;
}

sub applyTNormaFilter {
	my $self = shift;
	my $filter = shift;
	my @fileList = shift;
	if ($filter eq '') return @fileList;
}

sub applyAnioFilter {
	my $self = shift;
	my $filter = shift;
	my @fileList = shift;
	if ($filter eq '') return @fileList;
}

sub applyNNormaFilter {
	my $self = shift;
	my $filter = shift;
	my @fileList = shift;
	if ($filter eq '') return @fileList;
}

sub appliyGestionFilter {
	my $self = shift;
	my $filter = shift;
	my @fileList = shift;
	if ($filter eq '') return @fileList;
}

sub applyEmisorFilter {
	my $self = shift;
	my $filter = shift;
	my @fileList = shift;
	if ($filter eq '') return @fileList;
}
