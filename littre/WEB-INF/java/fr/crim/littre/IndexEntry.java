package fr.crim.littre;

import java.io.File;
import java.io.FileInputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.io.StringWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;
import java.util.Stack;
import java.util.TreeSet;

import javax.xml.namespace.QName;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.stream.XMLEventFactory;
import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLEventWriter;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.events.StartElement;
import javax.xml.stream.events.XMLEvent;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.Term;
import org.apache.lucene.store.FSDirectory;

/**
 * Indexation lucene des entrées Littré (dictionnaire en TEI)
 * 
 * @author Ginka
 * @author frederic.glorieux@fictif.org
 */
public class IndexEntry {
	/** Connexion sqlite au lexique */
	static private Connection conn;
	/** Requête préparée */
	static private PreparedStatement stat;
	/** Chemin XML courant */
	static Stack<String> stackpath;
	/** Article en cours d'écriture */
	static XMLEventWriter entry;
	/** Factorie à fabriquer les lecteurs de balises */
	static XMLInputFactory xins = XMLInputFactory.newInstance();
	/** Factorie à fabriquer les scripteurs de balises */
	static XMLOutputFactory xouts = XMLOutputFactory.newInstance();
	/** Factorie à fabriquer les événements à balises */
	static XMLEventFactory xevs = XMLEventFactory.newInstance();
	/** Factorie à dom */
	static DocumentBuilder xdoms;
	/** Index lucene où écrire */
	static IndexWriter index;
	/** xslt entry > html */
	static Transformer littre_html;
	/** nom qualifié d'attibut, en constante */
	static final QName XML_ID = new QName("http://www.w3.org/XML/1998/namespace", "id", "xml");
	/** Unknown */
	static PrintStream unknown;

	/**
	 * L'exécution sera généralement en ligne de commande, il faut cependant
	 * pouvoir indexer depuis un serveur, cette méthode ne comportera que passage
	 * des paramètres.
	 * 
	 * @param args
	 * @throws Exception
	 */
	public static void main(String[] args) throws Exception {
		File xmlDir = new File("xml");
		if (args.length > 0)
			xmlDir = new File(args[0]);
		File indexDir = new File("index");
		if (args.length > 1)
			indexDir = new File(args[1]);
		File sqliteFile = new File("WEB-INF/lib/lexique.sqlite");
		if (args.length > 2)
			sqliteFile = new File(args[2]);
		// ouvrir un fichier où écrire les formes inconnues
		unknown=new PrintStream(new File("unknown.txt"), "UTF-8");
		index(xmlDir, indexDir, sqliteFile);
		unknown.close();
	}

	/**
	 * Parcours du dossier de documents XML
	 * 
	 * @param dir
	 * @throws IOException
	 * @throws TransformerFactoryConfigurationError
	 * @throws XMLStreamException
	 * @throws TransformerException
	 * @throws ParserConfigurationException
	 * @throws ClassNotFoundException
	 * @throws SQLException
	 * @throws XPathExpressionException 
	 */
	public static void index(File xmlDir, File indexDir, File dbFile) throws IOException,
			TransformerFactoryConfigurationError, XMLStreamException, TransformerException, ParserConfigurationException,
			ClassNotFoundException, SQLException, XPathExpressionException {
		// un petit message quand ça commence
		System.out.println(xmlDir.getAbsolutePath() + " > " + indexDir.getAbsolutePath() + " (" + dbFile.getAbsolutePath()
				+ ")");
		// connexion à la base du lexique
		Class.forName("org.sqlite.JDBC");
		conn = DriverManager.getConnection("jdbc:sqlite:" + dbFile);
		stat = conn.prepareStatement("SELECT forme FROM lexique WHERE lemme=?");
		index = new IndexWriter(FSDirectory.open(indexDir), Conf.getAnalyzer(), true, IndexWriter.MaxFieldLength.UNLIMITED);
		littre_html = TransformerFactory.newInstance().newTransformer(
				new StreamSource(new File(new File(xmlDir.getParentFile(), "transform"), "littre_html.xsl")));
		littre_html.setOutputProperty(OutputKeys.INDENT, "yes");
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		dbf.setNamespaceAware(true);
		xdoms = dbf.newDocumentBuilder();
		
		File[] files = xmlDir.listFiles(new FilenameFilter() {
			public boolean accept(File f, String s) {
				return s.endsWith(".xml");
			}
		});
		for (File f : files) {
			System.out.println(f);
			parse(f);
		}
		System.out.println("Optimisation de l'index…");
		index.commit();
		index.optimize();
		index.close();
		System.out.println("Indexation terminée.");
	}

	/**
	 * Passer à travers le TEI d'une lettre, créer un dom pour chaque article,
	 * récupérer différents champs au passage, transformer le dom en en html,
	 * ajouter le html au document Lucene.
	 * 
	 * @throws XMLStreamException
	 * @throws TransformerException
	 * @throws IOException
	 * @throws CorruptIndexException
	 * @throws SQLException
	 * @throws XPathExpressionException 
	 */
	public static void parse(File xml) throws XMLStreamException, TransformerException, CorruptIndexException,
			IOException, SQLException, XPathExpressionException {
		stackpath = new Stack<String>();
		XMLEventReader reader = xins.createXMLEventReader(
		// contre la spec XML, le flux de caractère ne tient pas compte du
		// prolog
				new InputStreamReader(new FileInputStream(xml), "UTF-8"));
		// événement XML courant
		XMLEvent ev;
		// élément XML courant
		StartElement el;
		// chaîne outil, notamment nom d'élément
		String name;
		// texte en cours
		String text = null;
		// String buffer de text en cours
		StringBuilder quote = new StringBuilder();
		StringBuilder dictScrap = new StringBuilder();
		// document lucene en cours
		Document doc = null;
		// résultat de la transformation <entry> vers html
		StringWriter html = null;
		// les <entry> sont recueillies dans un DOM
		org.w3c.dom.Document dom = null;
    XPath xp =  XPathFactory.newInstance().newXPath();
		// un dédoublonneur
		TreeSet<String> uniq = new TreeSet<String>();
		String orth;
		String id;
		int pos;
		// parcourir les événements
		while (reader.hasNext()) {
			ev = reader.nextEvent();
			/*
			 * début d'article – créer un nouveau document lucene – prendre
			 * l'identifiant – démarrer l'enregistrement du XML
			 */
			if (ev.isStartElement()) {
				el = ev.asStartElement();
				name = el.getName().getLocalPart();
				stackpath.push(name);
				if ("entry".equals(name)) {
					// reprendre xml:id
					id=el.getAttributeByName(XML_ID).getValue();
					// créer le document lucene, démarrer la capture des événements XML pour en faire un document DOM
					doc = new Document();
					doc.add(new Field("id", id, Field.Store.YES, Field.Index.NOT_ANALYZED));
					dom = xdoms.newDocument();
					entry = xouts.createXMLEventWriter(new DOMResult(dom));
					entry.add(xevs.createStartDocument("UTF-8", "1.0"));
					
					
				}
				if ("quote".equals(name)) {
					quote = new StringBuilder();
				}
				if ("dictScrap".equals(name)) {
					dictScrap = new StringBuilder();
				}
			}
			// ajouter l'événement au dom d'article en cours, après sa création
			if (entry != null)
				entry.add(ev);
			if (ev.isCharacters()) {
				text = ev.asCharacters().getData();
				// ajouter à la citation en cours
				if (quote != null) quote.append(text);
				if (dictScrap != null) dictScrap.append(text);
			}

			/*
			 * fin d'article – finir l'enregistrement du dom XML – transformer en html
			 */
			if (ev.isEndElement()) {
				// nom de l'élément
				name = ev.asEndElement().getName().getLocalPart();
				// forme othographique
				if ("orth".equals(name)) {
					// formes
					orth = text.toLowerCase();
					pos=orth.indexOf(',');
					if (pos > 0) orth=orth.substring(0, pos);
					pos=orth.indexOf(' ');
					if (pos > 0) orth=orth.substring(0, pos);
					doc.add(new Field("orth", orth, Field.Store.YES, Field.Index.ANALYZED));
					// une version de la vedette pour un “tu veux dire…”
					doc.add(new Field("orthGram", orth, Field.Store.NO, Field.Index.ANALYZED_NO_NORMS));
					// chercher la forme dans la base
					stat.setString(1, orth);
					ResultSet rs = stat.executeQuery();
					// dédoublonner les formes
					uniq.clear();
					while (rs.next()) {
						uniq.add(rs.getString(1));
					}
					if (uniq.size() == 0) {
						// lemme inconu de lexique.org, ajouter le lemme (fléchir ?)
						doc.add(new Field("form", orth, Field.Store.NO, Field.Index.NOT_ANALYZED));
						// ne pas ajouter les ngram des formes, survalorise les verbes
						// doc.add(new Field("formGram", orth, Field.Store.NO, Field.Index.ANALYZED_NO_NORMS));
						if (unknown != null) unknown.println(orth);
					}
					else {
						for (String s : uniq) {
							doc.add(new Field("form", s, Field.Store.NO, Field.Index.NOT_ANALYZED));
							// ne pas ajouter les ngram des formes, survalorise les verbes
							// doc.add(new Field("formGram", s, Field.Store.NO, Field.Index.ANALYZED_NO_NORMS));
						}
					}
				}
				// citation (pour similarités)
				if ("quote".equals(name)) {
					doc.add(new Field("quote", quote.toString(), Field.Store.NO, Field.Index.ANALYZED,  Field.TermVector.YES));
					quote = null;
				}
				// citation (pour similarités)
				if ("dictScrap".equals(name)) {
					doc.add(new Field("dictScrap", dictScrap.toString(), Field.Store.NO, Field.Index.ANALYZED,  Field.TermVector.YES));
					dictScrap = null;
				}
				// fin d'article, transformer le document XML capturé en HTML
				if ("entry".equals(name)) {
					entry.add(xevs.createEndDocument());
					entry.flush();
					entry.close();
					// flux de destination de la transformation html
					html=new StringWriter(); 
					littre_html.transform(new DOMSource(dom), new StreamResult(html));
					entry = null;
					// pour les simililarités
					doc.add(new Field("text", xp.evaluate("string(/)", dom.getDocumentElement()),  Field.Store.NO, Field.Index.ANALYZED,  Field.TermVector.YES));
					doc.add(new Field("html", html.toString(), Field.Store.YES, Field.Index.NO));
					// ajouter un chanmp type de document (permettra par exemple d'indexer les citations séparément)
					doc.add(new Field("type", "entry", Field.Store.NO, Field.Index.NOT_ANALYZED));
					// remplacer le document dans l'index lucene
					index.updateDocument(new Term("id", doc.get("id")), doc);

				}
				stackpath.pop();
			}
		}

	}
}
