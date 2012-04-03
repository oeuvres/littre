package fr.crim.littre.xml;

import java.io.File;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.w3c.dom.Document;
import org.w3c.dom.Node;

public class SedTagger extends Tagger {
	/** Obligatoire, le motif à chercher */
	Pattern search;
	/** Obligatoire, l'expression de remplacement */
	String replace;
	/** Optionnel, une expression plus large que le motif en search pour repérer ce qui aurait été manqué  */
	Pattern silence;
	
	public SedTagger(String regex, String replace) {
		this(regex, replace, null);
	}
	public SedTagger(String regex, String replace, String silence) {
		search = Pattern.compile(regex, Pattern.CASE_INSENSITIVE);
		this.replace=replace;
		if (silence != null) this.silence= Pattern.compile("terme", Pattern.CASE_INSENSITIVE);
	}
	
	/**
	 * Recherche remplace par expressions régulières. 
	 */
	public Node tag(Node n) {
		Node ret;
		String xml=dom2string(n);
		Matcher match = search.matcher(xml);
		// renvoyer sans modification
		if ( !match.find() ) {
			// laisser une trace d'erreur si on pense qu'il y aurait un oublié
			// permet de perfectionner l’expresson régulière
			if(silence != null && silence.matcher(xml).find()) System.err.println(xml);
			return n;
		}
		xml=match.replaceAll(replace);
		try {
			ret=string2dom(xml);
		}
		// Si le remplacement produit du mauvais xml
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
		// pour mise au point, parmi les noeuds qui n'ont pas été modifié, chercher ceux contenant pourtant le mot "terme"
		String silence="terme";
		Tagger tagger=new SedTagger(regex, replace, silence);
		// parcourir la liste de fichiers
		for (File file : xmlDir.listFiles(new GlobFilter("*.xml"))) {
			Document doc=tagger.parse(file, xpath);
			// voir ici ce qu'on fait avec le résultat, prudence avant de remplacer
		}
	}

}
