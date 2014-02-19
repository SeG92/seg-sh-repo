#!/bin/bash

#antes de nada compruebo si se está ejecutando con privilegios de root
if [ `whoami` == "root" ]
then
	#banderas de estado
	EXISTEGRUPO=false

	#pido usuario
	echo "Introduzca el nombre del usuario:"
	read NOMBRE

	#si el nombre de usuario viene en blanco me salgo directamente, en caso contrario lo compruebo
	if [ -z $NOMBRE ];
	then
		echo "ERROR: No se ha introducido ningun nombre de usuario."
		exit
	else
		while IFS=: read FUSUARIO KK
		do
			if [ $FUSUARIO = $NOMBRE ];
			then
				echo "ERROR: El usuario ya existe."
				exit
			fi
		done < /etc/passwd
	fi	

	#leo la contraseña y guardo el hash
	PHASH=`mkpasswd -m sha-512`

	#leo el grupo
	echo "Introduzca el grupo:"
	read GRUPO

	#si el grupo viene vacio
	if [ -z $GRUPO ];
	then
	
		#creo el usuario con el grupo por defecto
		echo "AVISO: No se ha introducido ningun grupo, se usará un grupo por defecto."
		echo "Creando el usuario '$NOMBRE'."
		useradd -d /home/grupo/$NOMBRE -m -p $PHASH -s /bin/sh $NOMBRE

	#si el grupo viene lleno
	else

		#compruebo si existe el grupo
		while IFS=: read FGRUPO KK
		do
			if [ $FGRUPO = $GRUPO ];
			then
				EXISTEGRUPO=true
			fi
		done < /etc/group
	
		#si existe el grupo creo el usuario y se lo asigno, en caso contrario pregunto
		if [ $EXISTEGRUPO = "true" ];
		then
			echo "Creando el usuario '$NOMBRE' con grupo '$GRUPO'."
			useradd -d /home/grupo/$NOMBRE -m -g $GRUPO -p $PHASH -s /bin/sh $NOMBRE
		else
			echo "AVISO: El grupo no existe ¿Desea crearlo? S/n"
			read CREARGRUPO
			if [ $CREARGRUPO = "S" ];
			then
				echo "Creando el grupo '$GRUPO'."
				groupadd $GRUPO
				EXISTEGRUPO=true
				echo "Creando el usuario '$NOMBRE' con grupo '$GRUPO'."
				useradd -d /home/grupo/$NOMBRE -m -g $GRUPO -p $PHASH -s /bin/sh $NOMBRE
			else
				echo "AVISO: Se creará el usuario con el grupo por defecto"
				echo "Creando el usuario '$NOMBRE'."
				useradd -d /home/grupo/$NOMBRE -m -p $PHASH -s /bin/sh $NOMBRE
			fi
		fi
	
	fi

else
	echo "ERROR: No tienes suficientes privilegios para ejecutar este script."
	exit
fi

#fin
