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

public class TreeBuilder extends XMLParser {
	private String 		motXPath;		// Expression XPath vers le mot
	private String 		synXPath;		// Expression XPath vers les synonymes du mot

	public TreeBuilder(String input, String output, PrintWriter consoleOutput) {
		/**
		 * Parser XML pour trnsformer un dictionnaire mots -> synonymes en arborescence
		 * @param input : Chemin vers la ressource d'entree
		 * @param output : Chemin vers la ressource de sortie
		 * @param consoleOutput : Sortie Console
		 */
		super(input, output, consoleOutput);
		// Expressions XPath pour le dictionnaire
		this.motXPath 	 = "//mot";
		this.synXPath 	 = ".//synonyme";
	}
	public void addSyn(Element currentRoot, String synonyme, String mot) throws Exception {
		/**
		 * Decompose un synonyme en ses differentes lettres et cree un noeud pour chacun
		 * Le mot est place a la fin quand il ne reste plus de lettres
		 */
		// Si il reste des lettres, on prend la premiere
		if (synonyme.length() > 0) {
			// On construit un XPath pour trouver le noeud correspondant a la lettre
			XPath xpath = XPathFactory.newInstance().newXPath();
			NodeList lettreList = null;
			String xPathExpr = "./lettre[@val='"+synonyme.charAt(0)+"']";
			lettreList = (NodeList)xpath.evaluate(xPathExpr, currentRoot, XPathConstants.NODESET);
			
			//TODO if (lettreList.getLength() > 1) raise Exception;
			// Le dictionnaire ne doit pas contenir plusieurs fois la meme lettre dans un meme noeud
			Element lettreNode = null;
			if (lettreList.getLength() == 0) {
				// Le noeud correspondant a la lettre n'existe pas, il faut donc le creer
				lettreNode = this.xmlOutput.createElement("lettre");
				Attr attr = this.xmlOutput.createAttribute("val");
				attr.setValue(synonyme.substring(0,1));
				lettreNode.setAttributeNode(attr);
				currentRoot.appendChild(lettreNode);
			} // if lettreList.getLength() == 0  
			
			else lettreNode = (Element) lettreList.item(0);
			this.addSyn(lettreNode, synonyme.substring(1), mot);
		} // if synonyme.length() > 0
		
		else {
			// Plus de lettres, on ajoute le mot
			Element motNode = this.xmlOutput.createElement("mot");
			motNode.appendChild(this.xmlOutput.createTextNode(mot));
			currentRoot.appendChild(motNode);
		} // else synonyme.length() > 0
	}
	
	public void addMot(String valMot, String[] synList) throws Exception {
		/**
		 * Ajoute au document XML de sortie la liste des synonymes et le mot correspondant 
		 */
		// On verifie d'abord que le document existe bien
		// Le creer ainsi evite de le faire au cas ou il n'y aurait aucun mot contenant des synonymes
		if (this.xmlOutput == null) this.createOutput();
		
		int synLength = synList.length;
		if (synLength > 0){
			for (int i=0;i<synLength;i++){
				this.out.println("*** Adding ["+valMot+"] : "+synList[i].toUpperCase());
				this.addSyn(this.outputRoot, synList[i].toUpperCase(), valMot);
			} // for syn in synList
		}// if synLength > 0
	}

	@Override
	public void parseXML() throws XPathExpressionException, Exception {
		/**
		 * Parse le fichier dictionnaire XML pour creer un arbre
		 * Chaque noeud correspond a une lettred'un synonyme
		 * Chaque feuille correspond a un mot
		 */
		// Creation du XPath et recuperation des mots
		XPath xpath = XPathFactory.newInstance().newXPath();
		NodeList motList = null;
		motList = (NodeList)xpath.evaluate(this.motXPath, this.xmlInput, XPathConstants.NODESET);
		int nodesLength=motList.getLength();
		if (nodesLength > 0)
		{
			// Parcours de chaque noeud pour trouver le mot et les synonymes
			for (int nodeNumber=0;nodeNumber<nodesLength;nodeNumber++){
				//Node mot=motList.item(nodeNumber);
				Node mot=motList.item(nodeNumber);
				Attr motVal = (Attr)mot.getAttributes().item(0);
				String value = motVal.getValue();
				this.out.println("-->"+value);
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
					this.addMot(value, synValList);
					
				}//if synLength > 0
			}//for mot in motListe
		}//if nodesLength > 0
	}

}
