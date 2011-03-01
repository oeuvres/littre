package fr.crim.littre;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringWriter;

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
import javax.xml.stream.XMLStreamWriter;
import javax.xml.stream.events.StartElement;
import javax.xml.stream.events.XMLEvent;
import javax.xml.transform.Source;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stax.StAXSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Result;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;

import org.apache.lucene.analysis.PerFieldAnalyzerWrapper;
import org.apache.lucene.analysis.SimpleAnalyzer;
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
  /** Article en cours d'écriture */
  static XMLEventWriter entry;
  /** Factorie à fabriquer les lecteurs de balises */
  static XMLInputFactory xins = XMLInputFactory.newInstance();
  /** Factorie à fabriquer les scripteurs de balises */
  static XMLOutputFactory xouts = XMLOutputFactory.newInstance();
  /** Factorie à fabriquer les événements à balises */
  static XMLEventFactory  xevs = XMLEventFactory.newInstance();
  /** Factorie à dom */
  static DocumentBuilder xdoms;
  /** Index lucene où écrire */
  static IndexWriter index;
  /** Dossier de transformations xslt */
  static File transform=new File("transform");
  /** xslt entry > html */
  static Transformer littre_html;
  /** nom qualifié d'attibut, en constante */
  static final QName XML_ID = new QName("http://www.w3.org/XML/1998/namespace", "id", "xml");
  
  /**
   * L'exécution sera généralement en ligne de commande,
   * il faut cependant pouvoir indexer depuis un serveur,
   * cette méthode ne comportera que passage des paramètres.
   * 
   * @param args
   * @throws Exception
   */
  public static void main(String[] args) throws Exception {
    File indexDir=new File("index");
    if (args.length >= 1) indexDir=new File(args[0]);
    File xmlDir=new File("xml");
    if (args.length >= 2) xmlDir=new File(args[1]);
    if (args.length >= 3) transform=new File(args[2]);
    index(indexDir, xmlDir);
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
   */
  public static void index(File indexDir, File xmlDir) throws IOException, TransformerFactoryConfigurationError, XMLStreamException, TransformerException, ParserConfigurationException {
    PerFieldAnalyzerWrapper analyzer=new PerFieldAnalyzerWrapper(new SimpleAnalyzer());
    // TODO, ici brancher les analyzers selon les champs, voir 
    // http://lucene.apache.org/java/3_0_3/api/all/org/apache/lucene/analysis/PerFieldAnalyzerWrapper.html
    index=new IndexWriter(FSDirectory.open(indexDir), analyzer, true,  IndexWriter.MaxFieldLength.UNLIMITED ); 
    littre_html=TransformerFactory.newInstance().newTransformer(new StreamSource(new File(transform, "littre_html.xsl")));
    littre_html.setOutputProperty(OutputKeys.INDENT, "yes");
    DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
    dbf.setNamespaceAware(true);
    xdoms=dbf.newDocumentBuilder();
    
    File[] files=xmlDir.listFiles(
      new FilenameFilter() {
        public boolean accept(File f, String s) { return s.endsWith("k.xml"); }
      }
    );
    for (File f : files) {
      System.out.println(f);
      parse(f);
    }
    index.commit();
    index.optimize();
    index.close();
    System.out.println("Indexation terminée");
  }
  /**
   * Passer à travers le TEI d'une lettre
   * @throws XMLStreamException 
   * @throws TransformerException 
   * @throws IOException 
   * @throws CorruptIndexException 
   */
  public static void parse(File xml) throws XMLStreamException, TransformerException, CorruptIndexException, IOException {
    XMLEventReader reader = xins.createXMLEventReader(
      new InputStreamReader(new FileInputStream(xml))
    );
    // événement XML courant
    XMLEvent ev;
    // élément XML courant
    StartElement el;
    // chaîne outil, notamment nom d'élément
    String name;
    // document lucene en cours
    Document doc=null;
    // résultat de la transformation <entry> vers html
    StringWriter html=null;
    // les <entry> sont recueillies dans un DOM
    org.w3c.dom.Document dom=null;
    // parcourir les événements
    while (reader.hasNext()) {
      ev=reader.nextEvent();
      /* 
       * début d'article
       *  – créer un nouveau document lucene
       *  – prendre l'identifiant
       *  – démarrer l'enregistrement du XML 
       */
      if (ev.isStartElement()) {
        el=ev.asStartElement();
        name=el.getName().getLocalPart();
        if ("entry".equals(name)) {
          doc=new Document();
          doc.add(new Field("id", el.getAttributeByName(XML_ID).getValue(),Field.Store.YES,Field.Index.NOT_ANALYZED ));
          html=new StringWriter();
          // Result 
          dom=xdoms.newDocument();
          entry=xouts.createXMLEventWriter(new DOMResult(dom));
          entry.add(xevs.createStartDocument());
        }
      }
      if (entry != null) entry.add(ev);
      /* 
       * fin d'article
       *  – finir l'enregistrement du XML
       *  – transformer en html 
       */
      if (ev.isEndElement()) {
        name=ev.asEndElement().getName().getLocalPart();
        if ("entry".equals(name)) {
          entry.add(xevs.createEndDocument());
          entry.flush();
          entry.close();
          littre_html.transform(new DOMSource(dom), new StreamResult(html));
          entry=null;
          doc.add(new Field("html", html.toString(), Field.Store.YES, Field.Index.NO ));
          doc.add(new Field("type", "entry", Field.Store.NO, Field.Index.NOT_ANALYZED ));
          // remplace
          index.updateDocument(new Term("id", doc.get("id")), doc);

        }
      }
    }
    
  }
}
