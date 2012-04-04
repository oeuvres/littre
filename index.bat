@echo off
:: 
:: Lancement de l'indexation du Littre avec Alix
::

:: Ne pas modifier ces deux lignes, merci
set WEBINF=web-app/WEB-INF
set CP=%WEBINF%/lib/alix-3.5.0.jar;%WEBINF%/lib/lucene-core-3.5.0.jar;%WEBINF%/lib/javacrim-lucene.jar;%WEBINF%/lib/sqlitejdbc-v056.jar;%WEBINF%/classes

:: Personnalisation
if "%1" == "defaut" (
	set ANALYZER_OPT=-analyzer fr.crim.littre.lucene.LittreAnalyzer
	set INDEX_DIR=%WEBINF%/index
	set XSL_FILE=transform/littre_alix.xsl
) else (
if "%1" == "lemmatizer" (
	set ANALYZER_OPT=
	set INDEX_DIR=%WEBINF%/index/lemmatizer
	set XSL_FILE=transform/littre_alix_lemmatizer.xsl
) else (
if "%1" == "similarity" (
	set ANALYZER_OPT=
	set INDEX_DIR=%WEBINF%/index/similarity
	set XSL_FILE=transform/littre_alix_similarity.xsl
) else (
	echo usage: index.bat {defaut|lemmatizer|similarity}
	goto END
)))

:: Lancement de la commande
java -Xmx512m -cp %CP% fr.crim.lucene.alix.Alix %ANALYZER_OPT% -dir %INDEX_DIR% -xsl %XSL_FILE% index xml

:END
