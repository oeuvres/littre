package fr.crim.littre.xml;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.StringWriter;

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
	
	/** Ici ne fait rien, à surcharger */
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
	static Document doc;
	static Node n;
	static NodeList nl;
	static XPath xp = XPathFactory.newInstance().newXPath();
	static DocumentBuilder parser;
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
		System.err.println(f+" "+nl.getLength()+"o.");
		for (int i=0; i<nl.getLength(); i++) {
			n=tag(nl.item(i));
			// remplacement, noter l'importation du noeud à remplacer (permet par exmeple de régulariser les espaces de noms)
			nl.item(i).getParentNode().replaceChild((Element)doc.importNode(n, true), nl.item(i));
		}
		return doc;
	}
	/**
	 * Parser une chaîne pour en faire du DOM.
	 * Attention, ne pas oublier d'acclimater le nœud à un document;
	 * Laisser l'appeleur décider ce qu'il fait avec les exceptions (exemple renoncer si ça ne parse pas).
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
	 * Sérialisation DOM. Les exception sont retenues, pas de raison prévue pour qu'elles arrivent.
	 */
	private static Transformer transformer;
	DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
	static {
		try {
			transformer= TransformerFactory.newInstance().newTransformer();
		} catch (Exception e) {
			throw new RuntimeException(e);
		} 
        transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
        transformer.setOutputProperty(OutputKeys.METHOD,"xml");
	}
	private static StringWriter sw = new StringWriter();
	private static DOMSource domSource = new DOMSource();
	public static String dom2string(Node n) {
		// NON (coupe les balises)
		// node.getTextContent();
		sw.getBuffer().setLength(0);
        StreamResult result = new StreamResult(sw);
        domSource.setNode(n);
        try {
			transformer.transform(domSource, result);
		} catch (TransformerException e) {
			e.printStackTrace();
		}
        return sw.toString();
	}
}
