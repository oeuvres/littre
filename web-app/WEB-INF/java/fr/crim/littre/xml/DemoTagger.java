package fr.crim.littre.xml;

import java.io.File;

import org.w3c.dom.Document;
import org.w3c.dom.Node;

public class DemoTagger extends Tagger {
	/** Squelette qui ne fait rien*/
	public Node tag(Node n) {
		Node ret;
		String xml=dom2string(n);
		System.out.println(xml);
		try {
			ret=string2dom(xml);
		}
		catch (Exception e) {
			System.err.println("\t"+this.getClass().getName()+".tag(), XML error in  "+this.file+"#"+getId(n)+"\n"+xml);
 			return n;
		}
		return ret;
	}
	/**
	 * Tester le balisage de token
	 */
	public String word(String word) {
		if (path.length()>0) return "<w path=\""+path+"\">"+word+"</w>";
		else return "<w>"+word+"</w>";
	}

	/**
	 * @param args
	 * @throws Exception
	 */
	public static void main(String[] args) throws Exception {
		File xmlDir = new File("xml");
		String xpath = "//quote";
		if (args.length > 1)  xpath=args[0];
		if (args.length > 2) xmlDir = new File(args[1]);
		// parcourir la liste de fichiers
		Tagger tagger=new DemoTagger();
		System.out.println(tagger.tokenize("Ma <phr>chatte <o>me</o> ronronne</phr> dans l'oreille."));
		System.exit(0);
		for (File file : xmlDir.listFiles(new GlobFilter("test.tei"))) {
			Document doc=tagger.parse(file, xpath);
			// voir ici ce qu'on fait avec le résultat, prudence avant de remplacer le fichier
			// System.out.println(dom2string(doc));
		}
	}

}
