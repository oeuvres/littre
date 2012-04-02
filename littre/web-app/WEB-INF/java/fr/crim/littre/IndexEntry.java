package fr.crim.littre;


import java.io.File;
import java.io.FileInputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.Writer;
import java.sql.SQLException;
import java.util.Stack;

import javax.xml.namespace.QName;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.stream.XMLEventFactory;
import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLEventWriter;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.events.StartElement;
import javax.xml.stream.events.XMLEvent;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.xpath.XPathExpressionException;

import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.util.Version;


/**
 * Indexation lucene des entrées Littré (dictionnaire en TEI)
 * 
 * @author Ginka
 * @author frederic.glorieux@fictif.org
 */
public class IndexEntry extends Thread {
	/**  */
	static private String glob=".*\\.xml";
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
	/** Dossier à indexer */
	static File xmlDir=new File(LittreAnalyzer.WEB_INF.getParentFile().getParentFile(), "xml");
	/** Dossier de l'index */
	static File indexDir=new File(LittreAnalyzer.WEB_INF, "index");
	/** Où écrire */
	static PrintWriter out=new PrintWriter(System.out);
	/**
	 * Constructeur avec valeurs par défaut
	 * @throws IOException 
	 */
	public IndexEntry() throws IOException {
		this(null, null, null);
	}
	/**
	 * Constructeur rediriger un flux Servlet
	 * @throws IOException 
	 */
	public IndexEntry(Writer out) throws IOException {
		this(new PrintWriter(out), null, null);
	}
	/**
	 * Constructeur rediriger le flux
	 * @throws IOException 
	 */
	public IndexEntry(PrintWriter out) throws IOException {
		this(out, null, null);
	}
	/**
	 * Constructeur pour passer des paramètres
	 * @throws IOException 
	 */
	public IndexEntry(PrintWriter aOut, File aXmlDir, File aIndexDir) throws IOException {
		if (aOut!= null) out=aOut;
		// Si on voulais rendre le filtrage de fichier configurable
		// aGlob.replaceAll("([^.])([*?])", "$1.$2");
		if (aXmlDir != null) xmlDir=aXmlDir;
		if (aIndexDir != null) indexDir=aIndexDir;
		
		Directory dir=FSDirectory.open(indexDir);
		if (IndexWriter.isLocked(dir)) throw new java.util.ConcurrentModificationException("Indexation déjà lancée.");
		// connexion à la base du lexique
		try {
			
			IndexWriterConfig conf = new IndexWriterConfig(Version.LUCENE_35, new LittreAnalyzer());
			index = new IndexWriter(dir, conf);
			// destruction brutale, on pourrait faire plus fin, par exemple par nom de fichier
			index.deleteAll();
			index.commit();
			

			littre_html = TransformerFactory.newInstance().newTransformer(
					new StreamSource(new File(new File(xmlDir.getParentFile(), "transform"), "littre_html.xsl")));
			littre_html.setOutputProperty(OutputKeys.INDENT, "yes");
			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
			dbf.setNamespaceAware(true);
			xdoms = dbf.newDocumentBuilder();
		} catch (Exception e) {
			e.printStackTrace(out);
		}
	}
	
	@Override
	public void run() {
		// un petit message quand ça commence
		out.println(xmlDir.getAbsolutePath() + " > " + indexDir.getAbsolutePath() );
		File[] files = xmlDir.listFiles(new FilenameFilter() {
			public boolean accept(File f, String s) {
				return s.matches(glob);
			}
		});
		try {
			for (File f : files) {
				out.print(f);
				out.print("… ");
				out.flush();
				parse(f);
				out.print("… ");
				index.commit();
				out.println(" OK.");
				out.flush();
			}
			// réduit le nombre de fichiers de l'index
			out.println("Optimisation de l'index…");
			out.flush();
			index.forceMerge(1);
			index.close();
		} catch (Exception e) {
			e.printStackTrace(out);
		} 
		out.print("Indexation terminée.");
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
		// contre la spec XML, le flux de caractère ne tient pas compte du prolog
		XMLEventReader reader = xins.createXMLEventReader(new InputStreamReader(new FileInputStream(xml), "UTF-8"));
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

		// un dédoublonneur
		String orth;
		String id;
		int pos;
		// parcourir les événements
		while (reader.hasNext()) {
			ev = reader.nextEvent();

			// début d'élément, démarrer des captures
			if (ev.isStartElement()) {
				el = ev.asStartElement();
				name = el.getName().getLocalPart();
				// une pile qui garde en mémoire les noms d'éléments parents
				// ne pas oublier de dépiler à la fermeture d'un élément
				stackpath.push(name);
				// début d'article, crére un document lucene, y ajouter son identifiant
				// démarrer la capture des événements XML pour en faire un document DOM, qui sera ensuite transformé en html
				if ("entry".equals(name)) {
					// reprendre xml:id
					id=el.getAttributeByName(XML_ID).getValue();
					// créer le document lucene, 
					doc = new Document();
					doc.add(new Field("id", id, Field.Store.YES, Field.Index.NOT_ANALYZED));
					// le dom pour capturer le XML
					dom = xdoms.newDocument();
					entry = xouts.createXMLEventWriter(new DOMResult(dom));
					entry.add(xevs.createStartDocument("UTF-8", "1.0"));
				}
				// remise à 0 du buffer de capture d'une citation
				else if ("quote".equals(name)) quote.setLength(0);
				// remise à 0 du buffer de capture d'une glose
				else if ("dictScrap".equals(name)) dictScrap.setLength(0);
			}
			// quel que soit l'événement XML, l'ajouter au dom d'article en cours, mais après sa création
			if (entry != null) entry.add(ev);
			
			// en cas de nœud texte, alimenter les buffers texte
			if (ev.isCharacters()) {
				text = ev.asCharacters().getData();
				// ajouter à la citation en cours
				if (quote != null) quote.append(text);
				if (dictScrap != null) dictScrap.append(text);
			}

			// Intercepter ici les éléments fermants, pour constituer les champs à indexer
			if (ev.isEndElement()) {
				// nom de l'élément
				name = ev.asEndElement().getName().getLocalPart();
				// forme othographique
				if ("orth".equals(name)) {
					// formes
					orth = text.toLowerCase();
					// il est arrivé à un moment que les vedettes étaient mal balisées, d’ou cette virgule
					// TODO vérifier si c’est encore nécessaire
					pos=orth.indexOf(',');
					if (pos > 0) orth=orth.substring(0, pos);
					pos=orth.indexOf(' ');
					if (pos > 0) orth=orth.substring(0, pos);
					doc.add(new Field("orth", orth, Field.Store.YES, Field.Index.ANALYZED));
					doc.add(new Field("form", orth, Field.Store.NO, Field.Index.ANALYZED));
				}
				// fin d'article, transformer le document XML capturé en HTML
				else if ("entry".equals(name)) {
					entry.add(xevs.createEndDocument());
					entry.flush();
					entry.close();
					// flux de destination de la transformation html
					html=new StringWriter(); 
					littre_html.transform(new DOMSource(dom), new StreamResult(html));
					entry = null;
					// html de l'article, stocké mais pas analysé
					doc.add(new Field("html", html.toString(), Field.Store.YES, Field.Index.NO));
					// ajouter un chanmp type de document (permettra par exemple d'indexer les citations séparément)
					doc.add(new Field("type", "entry", Field.Store.NO, Field.Index.NOT_ANALYZED));
					// remplacer le document dans l'index lucene
					// index.updateDocument(new Term("id", doc.get("id")), doc);
					// tout ayant été détruit, devrait aller plus vite
					index.addDocument(doc);
				}
				// citations, une bonne approche pourrait être de créer un document par citation
				// gloses ?
				stackpath.pop();
			}
		}

	}
	/**
	 * L'exécution sera généralement en ligne de commande, il faut cependant
	 * pouvoir indexer depuis un serveur, cette méthode ne comportera que passage
	 * des paramètres.
	 * 
	 * @param args
	 * @throws Exception
	 */
	public static void main(String[] args) throws Exception {
		Thread task;
		if (args.length == 2) task=new IndexEntry(null, new File(args[0]), new File(args[1]));
		else task=new IndexEntry();
		// ouvrir un fichier où écrire les formes inconnues
		unknown=new PrintStream(new File("unknown.txt"), "UTF-8");
		task.run();
		unknown.close();
	}

}
