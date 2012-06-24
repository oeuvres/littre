package fr.crim.littre.xml.IP.FormesAnciennes;

import java.io.File;
import java.io.InputStream;
import java.io.PrintWriter;
import java.net.URL;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPathExpressionException;

import org.w3c.dom.Document;
import org.w3c.dom.Element;


public abstract class XMLParser {
	private   String		inputPath;	// Chemin vers la ressource d'entree
	private   String		outputPath;	// Chemin vers la ressource de sortie
	protected Document 		xmlInput; 	// Fichier XML d'entree
	protected Document 		xmlOutput;	// Fichier XML de sortie
	protected Element     	outputRoot;	// Noeud racine du XML de sortie
	protected PrintWriter	out;		// Sortie Console
	
	public XMLParser(String input, String output, PrintWriter consoleOutput){
		/**
		 * Parser XML generique
		 * Regroupe les operation d'ouverture, de creation et d'ecriture de fichier
		 * @param input : Chemin vers la ressource d'entree
		 * @param output : Chemin vers la ressource de sortie
		 * @param consoleOutput : Sortie Console
		 */
		this.inputPath	= input;
		this.outputPath = output;
		this.xmlInput   = null;
		this.xmlOutput  = null;
		this.outputRoot = null;
		this.out		= consoleOutput;			
	}
	
	public void createInput() throws Exception{
		/**
		 * Cree et renvoie un document a partir d'un flux 
		 */
		// Instanciation des analyseurs XML
		InputStream inputStrem = new URL(this.inputPath).openStream();
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		factory.setNamespaceAware(false);
		DocumentBuilder builder = factory.newDocumentBuilder();
		// Analyse du document XML mise en memoire
		this.xmlInput = builder.parse(inputStrem);
		inputStrem.close();
		
	}
	
	public void createOutput() throws Exception{
		/**
		 * Creation du fichier XML de sortie 
		 */
		DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
		DocumentBuilder docBuilder;
		docBuilder = docFactory.newDocumentBuilder();
		this.xmlOutput = docBuilder.newDocument();
		this.outputRoot = this.xmlOutput.createElement("doc");
		this.xmlOutput.appendChild(this.outputRoot);
	}
	
	public void writeOutput() throws Exception {
		/**
		 * Creation du fichier XML de sortie contenant le dictionnaire de synonymes	
		 */
		if (this.xmlOutput != null){
			// On ecrit le contenu du document dans le fichier xml
			TransformerFactory transformerFactory = TransformerFactory.newInstance();
			Transformer transformer = transformerFactory.newTransformer();
			DOMSource source = new DOMSource(this.xmlOutput);
			StreamResult result = new StreamResult(new File(this.outputPath));
			//StreamResult result = new StreamResult(System.out);
			transformer.transform(source, result);
			this.out.println("Resultats sauvegardes!");
		}
	}
	
	public abstract void parseXML() throws XPathExpressionException, Exception;
		/**
		 * La facon dont est parse le xml depend de chaque implementation
		 */
}
