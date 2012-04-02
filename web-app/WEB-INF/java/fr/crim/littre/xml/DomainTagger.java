package fr.crim.littre.xml;

import java.io.File;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.w3c.dom.Document;
import org.w3c.dom.Node;

public class DomainTagger extends Tagger {
	Pattern pattern;
	String replace;
	Pattern test;
	
	public DomainTagger(String regex, String replace) {
		pattern = Pattern.compile(regex, Pattern.CASE_INSENSITIVE);
		this.replace=replace;
		test= Pattern.compile("terme", Pattern.CASE_INSENSITIVE);
	}
	
	/** Cherche les temres de domaines */
	public Node tag(Node n) {
		Node ret;
		String xml=dom2string(n);
		Matcher match = pattern.matcher(xml);
		// renvoyer sans modification
		if ( !match.find() ) {
			// laisser une trace d'erreur s'il y a pourtant le mot "terme"
			// if(test.matcher(xml).find()) System.err.println(xml);
			return n;
		}
		xml=pattern.matcher(xml).replaceAll(replace);
		// System.out.println(xml);
		try {
			ret=string2dom(xml);
		}
		catch (Exception e) {
			System.err.println(this.getClass().getSimpleName()+".tag(), XML error: "+xml);
			return n;
		}
		return ret;
	}

	public static void main(String[] args) throws Exception {
		File xmlDir = new File("xml");
		if (args.length > 1) xmlDir = new File(args[1]);
		String xpath="//dictScrap";
		// expression testée sur le totalité du dictionnaire
		String regex="((en )?termes?)( de | d’| d'| | de l’| de l')([^\\.]+)([.,])";
		// cette expression un peu complexe permet d'isoler toute l'expression en distinguant le terme
		String replace="<usg type=\"dom\">$1$2<term>$3</term>$4</usg>";
		Tagger tagger=new DomainTagger(regex, replace);
		// parcourir la liste de fichiers
		for (File file : xmlDir.listFiles(new GlobFilter("*.xml"))) {
			Document doc=tagger.parse(file, xpath);
			// voir ici ce qu'on fait avec le résultat, prudence avant de remplacer
		}
	}

}
