package fr.crim.littre.xml;



import org.w3c.dom.Node;

/**
 */
public class OvarTagger extends Tagger {
	/**
	 * TODO
	 * — Chercher l'identifiant du parent <entry>
	 * — Si nouveau, prendre la liste des formes fléchies dans la base SQLite
	 * — Tokeniser le contenu sans abîmer les balises
	 * — Si un mot est dans la liste, l'encadrer de la balise oVar
	 */
	public Node tag(Node n) {
		Node ret;
		String xml=dom2string(n);
		try {
			ret=string2dom(xml);
		}
		catch (Exception e) {
			System.err.println(this.getClass().getName()+".tag(), XML error: "+xml);
			return n;
		}
		return ret;
	}

	
}
