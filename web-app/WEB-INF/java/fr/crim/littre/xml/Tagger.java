package fr.crim.littre.xml;

import java.io.BufferedWriter;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

public abstract class Tagger {
	/** Fichier en cours de traitement */
	File file;
	/**
	 * Reçoit un nœud sélectionné en XPath, le renvoit modifié. 
	 */
	abstract public Node tag(Node n);
    /**
     * Prend un fichier, extrait les noeuds d'un xpath, passe la main à une fonction "tag", remplace les noeuds,
     * renvoit le doc modifié.
     * 
     * @param files
     * @param xpath
     * @throws ParserConfigurationException
     * @throws SAXException
     * @throws IOException
     * @throws XPathExpressionException
     */
	private static Document doc;
	private static Node n;
	private static NodeList nl;
	private static XPath xp = XPathFactory.newInstance().newXPath();
	private static DocumentBuilder parser;
	static {
		// Instanciation du parseur pour le XML
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		// FIXME Pour simplifier les xpath, pas de namespace
		factory.setNamespaceAware(false);
		try {
			parser = factory.newDocumentBuilder();
		} catch (ParserConfigurationException e) {
			throw new RuntimeException(e);
		}
	}
	public Document parse(File f, String xpath) throws ParserConfigurationException, SAXException, IOException, XPathExpressionException {
		doc = parser.parse(f);
		nl = (NodeList) xp.evaluate( xpath, doc, XPathConstants.NODESET );
		System.err.println(f+"#"+xpath+" ("+nl.getLength()+")");
		// informer les objets du fichgier en cours de traitement
		this.file=f;
		for (int i=0; i<nl.getLength(); i++) {
			n=tag(nl.item(i));
			// remplacement, noter l'importation du noeud à remplacer (permet par exmeple de régulariser les espaces de noms)
			nl.item(i).getParentNode().replaceChild((Element)doc.importNode(n, true), nl.item(i));
		}
		return doc;
	}
	/**
	 * Rechercher l'identifiant le plus proche du nœud
	 * 
	 * @param n
	 * @return
	 */
	public static String getId(Node n) {
		while (n != null) {
			// le nœud n'est pas un élément
			if (n.getNodeType()!=Node.ELEMENT_NODE);
			// le nœud n'a pas d'attribut
			else if (!n.hasAttributes());
			// le nœud n'a pas d'attribut identifiant
			else if (!((Element)n).hasAttribute("xml:id") );
			// renvoyer la valeur de l'attribut id
			else return ((Element)n).getAttribute("xml:id");
			// passer au parent
			n=n.getParentNode();
		}
		// pas d'identifiant trouvé, renvoyer une chaîne vide, plus propre à afficher que null
		return "";
	}
	/**
	 * Parser une chaîne pour en faire du DOM.
	 * Attention, ne pas oublier d'acclimater le nœud à un document;
	 * Laisser l'appeleur décider ce qu'il fait avec les exceptions (exemple renoncer si ça ne parse pas).
	 * 
	 * @throws ParserConfigurationException 
	 * @throws IOException 
	 * @throws SAXException 
	 */
	static DocumentBuilder builder;
	static {
		try {
			builder=DocumentBuilderFactory.newInstance().newDocumentBuilder();
		} catch (ParserConfigurationException e) {
			throw new RuntimeException(e);
		}
	}
	public static Element string2dom(String xml) throws SAXException, IOException, ParserConfigurationException {
		Element el =  builder.parse(new ByteArrayInputStream(xml.getBytes())).getDocumentElement();
		return el;
	}
	/**
	 * Sérialisation d'un DOM en String. Les exception sont retenues, pas de raison prévue pour qu'elles arrivent.
	 * Les objets nécessaires sont factorisés en statique.
	 */
	private static StringWriter serSw = new StringWriter();
	private static DOMSource serSource = new DOMSource();
	private static Transformer serTr;
	static {
		try {
			serTr= TransformerFactory.newInstance().newTransformer();
		} catch (Exception e) {
			throw new RuntimeException(e);
		} 
		serTr.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
		serTr.setOutputProperty(OutputKeys.METHOD,"xml");
	}
	public static String dom2string(Node n) {
		// NON (coupe les balises)
		// node.getTextContent();
		serSw.getBuffer().setLength(0);
        StreamResult result = new StreamResult(serSw);
        serSource.setNode(n);
        try {
        	serTr.transform(serSource, result);
		} catch (TransformerException e) {
			throw new RuntimeException(e);
		}
        return serSw.toString();
	}
	/**
	 * Fixer un flux de sortie pour passer des informations de bilan du baliseur
	 */
	PrintWriter log;
	void setLog(File file) throws UnsupportedEncodingException, FileNotFoundException {
		// ne pas oublier le booléen autoflush
		this.log= new PrintWriter(new OutputStreamWriter(new FileOutputStream(file), "UTF-8"), true);
	}
}
