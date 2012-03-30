# compilation de dépannage 
# à noter, -Djava.ext.dirs est une mauvaise pratique
# mais  -cp "lib/*.jar" n'est pas encore bien supporté (OpenJdk)
javac -Djava.ext.dirs=lib  -cp "lib/*.jar"  -d classes java/fr/crim/littre/*.java

