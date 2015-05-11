########################################################################################

README.txt para version 1.0 de SisProH

Este archivo explica la instalación del sistema SisProH y su modo de uso.

########################################################################################

QUE ES SisProH

Sistema para la protocolización de archivos, o sea el sistema se encarga de 
efectuar las validaciones de los campos del documento a protocolizar y si 
corresponde, asignarle un número de norma creando con todo ello un documento protocolizado.

########################################################################################

COMO COPIAR INSTALADOR DESDE UN MEDIO EXTERNO
	
Para poder instalar el sistema, primero debe descomprimir el archivador
descargado:

	DESCOMPRESION:
		Insertar el dispositivo de almacenamiento con el contenido del tp.

		Crear un directorio de trabajo en el cual se realizará la instalación.

		Copiar el archivo grupo02.tar.gz en ese directorio. Para realizar esto puede copiarlo 
		a mano o desde el terminal, haciendo uso del comando:
  					mv ./grupo02.tar.gz [DIRECTORIO DESTINO]

		Descomprimir el archivo grupo02.tar.gz de manera de generar grupo02.tar Para realizar esto 
		puede ingresar el siguiente comando en el terminal (ubicándose en el directorio de trabajo):
  					tar -zxf grupo02.tar.gz

		Extraer los archivos del tar.

Una vez descomprimido el paquete, se generará una carpeta grupo02, en el directorio de destino. La misma
contará con los siguientes Directorios:
	pruebas
	conf
	Datos
	RecPro
	ProPro
	InfPro

Además encontrará los scripts necesarios para la instalacion, inicialización y demás para la ejecución del programa.
########################################################################################

REQUISITOS DE INSTALACIÓN

	Contar con Bash versión 3 o superior.
	Contar con Perl versión 5 o superior.
	Contar con un espacio mínimo superior al especificado para almacenar el flujo de novedades.

########################################################################################

COMO INSTALAR

1) Colocarse en el directorio descomprimido anteriormente:
	cd grupo02
	
2) Ejecutar el comando de instalación desde el terminal:
	./InsPro.sh

3) Proveer los paths de directorios a crear y datos pedidos:
	Directorio de Archivos Maestros y Tablas
    Directorio de Novedades
    Tamaño mínimo libre para el Directorio de Novedades
    Directorio de Novedades Aceptadas
    Directorio de grabación de Consultas, Informes y estadisticas
    Directorio de Archivos Rechazados
    Directorio de logs
    SubDirectorio de Resguardo de Archivos Duplicados
    Directorio de Ejecutables

ACLARACIÓN: El usuario puede presionar la tecla Enter si no desea especificar cada uno de estos
directorios, con lo cual el sistema creará los directorios con los nombres especificados por defecto.

4) Luego se desplegarán los paths especificados por el usuario para que el mismo los pueda chequear.

5) Confirmar el incio de la instalación.

6) Instalacion COMPLETA.


########################################################################################

RESULTADO DE LA INSTALACIÓN

Una vez completada la instalación, tendremos en el directorio grupo02 los siguientes elementos:

	Directorios especificados por el usuario (con sus correspondientes subdirectorios)

	Se habrán movido los archivos de datos contenidos en la carpeta donde se van a tener los maestros
	y las tablas al Directorio de Archivos Maestros y Tablas.

	Se habrán movido todos los scripts ejecutables al directorio Directorio de ejecutables.

########################################################################################

PRIMEROS PASOS PARA PODER EJECUTAR EL PROGRAMA

Ubicarse en el directorio de ejecutables indicado en el paso anterior, por ejemplo si se utilizó la ubicación default, desde el contenedor del directorio de grupo ejecutar:
	$ cd grupo02/bin

Eecutar el siguiente comando para inicializar la sesión de terminal:
	$ . IniPro.sh

[Es importante poner el '.' previo al comando en sí mismo]

Luego, si se desea, se podrá iniciar inmediatamente el procesamiento en segundo  plano siguiendo las instrucciones
 que se muestran por pantalla. De no hacerlo, se deberá ejecutar el comando:
		$ Start.sh RecPro

A medida que se depositen archivos con novedades en la carpeta correspondiente a las mismas
(cuyo nombre se eligió en la instalación), dichas novedades serán  movidas y procesadas, siempre
y cuando se haya iniciado el procesamiento.

########################################################################################

COMPROBACIONES A REALIZAR PARA VERIFICAR QUE TODO ESTÁ EN ORDEN

Para poder inicializar el programa y su ejecución, se debe haber ejecutado una vez el comando IniPro
en la sesión de terminal que se desea usar, tal como se aclara en el punto anterior.
Notar que de ejecutarse más de una vez, se verá por pantalla que ya fue ejecutado anteriormente.

########################################################################################
FRENAR LA EJECUCION DEL PROGRAMA

Todos los programas se ejecutan y finalizan cuando no tienen mas archivos por procesar, a
excepción del RecPro.sh que al ser un demonio, siempre queda en ejecución en segundo plano
hasta que se decida cortarlo. Para finalizar su ejecución, simplemente hay que ejecutar (estando
en la raiz del programa) el siguiente comando:
		Stop.sh RecPro

Una vez ejecutado esto, el RecPro.sh dejará de ejecutarse, y el programa finalizará su ejecución

########################################################################################

GENERAR CONSULTAS, INFORMES Y ESTADISTICAS

Luego de haber procesado los archivos, se pueden generar consultas, informes y estadisticas usando el comando
InfPro.pl presente en la carpeta de ejecutables. Para ver detalladamente cómo usarlo, ejecutar el comando:
	InfPro.pl -a
que mostrará por pantalla el manual de ayuda del mismo.

	InfPro.pl -c
Ira preguntando por pantalla por qué tipo de filtro se quiere realizar la consulta. Es obligatorio al menos seleccionar un filtro, en caso de no hacerlo, vuelve a realizar desde el principio que filtro desea aplicar. En caso de incorporar -g como parámetro la consulta se persistirá en INFODIR con el nombre resultado\_xxx con xxx la numeración en orden de la consulta a grabar realizada.

	InfPro.pl -i resultado_xxx
Realiza una consulta eligiendo alguno de los filtros ofrecidos, sobre la consulta realizada y persistida por InfPro.pl -c -g. Es obligatorio elegir un filtro para realizar la consulta del informe, en caso de no hacerlo, se le volverán a preguntar por los filtros ofrecidos.

	InfPro.pl -e
Solicita filtro sobre la gestion o sobre el rango de fechas sobre los que se desea realizar la estadística. El filtro es obligatorio, en caso de no seleccionar ninguno, se le solicitarán los filtros nuevamente hasta seleccionar al menos uno. La estadística agrupa por gestión y año, mostrando cantidad de resoluciones, cantidad de disposiciones y cantidad de convenios. En caso de incorporar -g como parámetro los resultados los persiste en la carpeta INFODIR con el nombre estadistica\_xxx con xxx la numeración en orden de la estadística a grabar realizada.