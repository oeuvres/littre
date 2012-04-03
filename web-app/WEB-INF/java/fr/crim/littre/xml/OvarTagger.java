package fr.crim.littre.xml;



import java.io.File;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.regex.Pattern;

import org.w3c.dom.Document;
import org.w3c.dom.Node;

/**
 *  
 */
public class OvarTagger extends Tagger {
	/** Expression pour trouver un lemme à partir d'un identifiant en retirant les n° d'homographe */
	private Pattern idNorm=Pattern.compile("\\.[0-9]+$");
	/** Lemme courant */
	private String lemma;
	/** Formes */
	private HashSet<String> forms=new HashSet<String>();
	/** Connexion à un lexique */
	static private Connection conn;
	/** Requêtes pour récupérr des formes */
	private PreparedStatement formQuery;
	
	public OvarTagger(File dbFile) throws ClassNotFoundException, SQLException {
		Class.forName("org.sqlite.JDBC");
		conn = DriverManager.getConnection("jdbc:sqlite:"+dbFile);
	    formQuery = conn.prepareStatement("SELECT forme FROM lexique WHERE lemme=?");
	}

	/**
	 * TODO
	 * — Chercher l'identifiant du parent <entry>
	 * — Si nouveau, prendre la liste des formes fléchies dans la base SQLite
	 * — Tokeniser le contenu sans abîmer les balises
	 * — Si un mot est dans la liste, l'encadrer de la balise oVar
	 */
	ResultSet rs;
	public Node tag(Node n) {
		String id=getId(n);
		String lemma=idNorm.matcher(id).replaceAll("");
		// recharcher une nouvelle liste de formes
		if (!lemma.equals(this.lemma)) {
			this.lemma=lemma;
			// charger les formes fléchies
			this.forms.clear();
			try {
				formQuery.setString(1, lemma);
				rs = formQuery.executeQuery();
				while (rs.next()) this.forms.add(rs.getString(1));
			} catch (SQLException e) {
				// risque d'innonder la copsole si pb
				e.printStackTrace(System.err);
			}
			// noter ici les lemmes inconnus du lexique
			if (this.forms.size()==0) {
				// essayer de la flexion auto ? Ajouter au 
				// System.err.println(lemma);
				if (log == null);
				// iers, ière, ières
				else if (lemma.endsWith("ier")) {
					// exceptions : tripudier
				}
				// verbe ?
				else if (lemma.endsWith("er")) log.println(lemma);
			}
		}
		Node ret;
		String xml=dom2string(n);
		// Ne pas oublier si rien noter
		try {
			ret=string2dom(xml);
		}
		catch (Exception e) {
			System.err.println(this.getClass().getName()+".tag(), XML error: "+xml);
			return n;
		}
		return ret;
	}

	/**
	 * @param args
	 * @throws Exception
	 */
	public static void main(String[] args) throws Exception {
		File db=new File("web-app/WEB-INF/lib/lexique.sqlite");
		File xmlDir = new File("xml");
		String xpath = "//quote";
		if (args.length > 1)  xpath=args[0];
		if (args.length > 2) xmlDir = new File(args[1]);
		// parcourir la liste de fichiers
		Tagger tagger=new OvarTagger(db);
		tagger.setLog(new File("unknown.txt"));
		for (File file : xmlDir.listFiles(new GlobFilter("*.xml"))) {
			Document doc=tagger.parse(file, xpath);
			// voir ici ce qu'on fait avec le résultat, prudence avant de remplacer
			// System.out.println(dom2string(doc));
		}
	}

	
}
