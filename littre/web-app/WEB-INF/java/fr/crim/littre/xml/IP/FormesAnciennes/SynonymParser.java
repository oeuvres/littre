package fr.crim.littre.xml.IP.FormesAnciennes;

import java.io.PrintWriter;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Attr;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class SynonymParser extends XMLParser {
	private String 			entryXPath;	// Expression XPath vers l'article du mot
	private String 			orthXPath;	// Expression XPath vers l'orthographe du mot
	private String 			synXPath;   // Expression XPath vers les citations
	
	public SynonymParser(String input, String output, PrintWriter consoleOutput) {
		/**
		 * Parser XML du littre, pour extraire les synonymes en vieux francais
		 * @param input : Chemin vers la ressource d'entree
		 * @param output : Chemin vers la ressource de sortie
		 * @param consoleOutput : Sortie Console
		 */
		super(input, output, consoleOutput);
		// Expressions XPath pour le littre
		this.entryXPath = "//entry";
		this.orthXPath  = ".//orth[1]";
		this.synXPath   = ".//note[@type='HIST.']//quote";
	}
	
	private void addMot(String mot, String[] synonymesList) throws Exception{
		/**
		 * Ajout d'un mot au document XML de sortie	
		 */
		// On verifie d'abord que le document existe bien
		// Le creer ainsi evite de le faire au cas ou il n'y aurait aucun mot contenant des synonymes
		if (this.xmlOutput == null) this.createOutput();
		
		// On cree le noeud <mot val="mot"> ... <mot/> 
		Element nodeMot = this.xmlOutput.createElement("mot");
		Attr attr = this.xmlOutput.createAttribute("val");
		attr.setValue(mot);
		nodeMot.setAttributeNode(attr);
		// Creation des noeuds <synonyme>synonymes[i]<synonyme/>
		// Et ajout des noeuds dans <mot val="mot"> ... <mot/>
		int size = synonymesList.length;
			for (int i=0; i<size; i++){
				Element synonyme = this.xmlOutput.createElement("synonyme");
				synonyme.appendChild(this.xmlOutput.createTextNode(synonymesList[i]));
				nodeMot.appendChild(synonyme);
		    }
		// Ajout de <mot val="mot"> ... <mot/> a la racine du document
		this.outputRoot.appendChild(nodeMot);
	}
	
	@Override
	public void parseXML() throws XPathExpressionException, Exception {
		/**
		 * Parse le fichier xmlInput pour trouver les mots (orth)
		 * et les citations contenant les synonymes en vieux francais (quote)
		 * les mots contenant des citations sont stockes dans un document
		 */
		// Creation du XPath et recuperation des entry : la liste des mots 
		XPath xpath = XPathFactory.newInstance().newXPath();
		NodeList motList = null;
		motList = (NodeList)xpath.evaluate(this.entryXPath, this.xmlInput, XPathConstants.NODESET);
		int nodesLength=motList.getLength();
		if (nodesLength > 0)
		{
			// Parcours de chaque article pour trouver l'orthographe et les synonymes
			for (int nodeNumber=0;nodeNumber<nodesLength;nodeNumber++){
				Node mot=motList.item(nodeNumber);
				
				// Nouvelle recherche XPath pour trouver l'orthographe du mot courant
				// On sait qu'il n'y a toujours qu'un element
				NodeList orthList = (NodeList)xpath.evaluate(this.orthXPath,mot, XPathConstants.NODESET);
				String orthVal = orthList.item(0).getTextContent(); 
				this.out.println("-->"+orthVal);
				// Recherche XPath pour trouver les citations contenant les synonymes
				NodeList synList = (NodeList)xpath.evaluate(this.synXPath,mot, XPathConstants.NODESET);
				int synLength=synList.getLength();
				if (synLength > 0)
				{
					String[] synValList = new String[synLength];
					for (int nodeNumber1=0;nodeNumber1<synLength;nodeNumber1++){
						// On parcours chacun des synonymes
						synValList[nodeNumber1] = synList.item(nodeNumber1).getTextContent();
						this.out.println("   -->"+synValList[nodeNumber1]);
					
					}//for syn in synList
					// On ajoute le mot et la liste de synonymes au XML de sortie
					this.addMot(orthVal, synValList);
				}//if synLength > O
			}//for mot in motList
		}//if nodelength > 0
	}

}
