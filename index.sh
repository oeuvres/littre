#!/bin/sh
#
# Lancement de l'indexation du Littre avec Alix
#

# Ne pas modifier les 2 lignes suivantes, merci
WEBINF=web-app/WEB-INF
CP="$WEBINF/lib/alix-3.5.0.jar:$WEBINF/lib/lucene-core-3.5.0.jar:$WEBINF/lib/javacrim-lucene.jar:$WEBINF/lib/sqlitejdbc-v056.jar:$WEBINF/classes"

# Rajouter ici sa personnalisation
case $1 in
	defaut)
		ANALYZER_OPT='-analyzer fr.crim.littre.lucene.LittreAnalyzer'
		INDEX_DIR=$WEBINF/index
		XSL_FILE='transform/littre_alix.xsl'
		;;
	*)
		echo 'usage: index.sh {defaut}'
		exit;
		;;
esac

# Lancement de la commande
java -cp $CP fr.crim.lucene.alix.Alix $ANALYZER_OPT -dir $INDEX_DIR -xsl $XSL_FILE index xml
