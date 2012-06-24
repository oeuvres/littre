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

public class FormParser extends XMLParser {
	public String motInput;	// Le mot a rechercher dans le fichier de correspondances
	public String result;		// La correpondance trouvee
	/**
	 * Classe permettant de parser les Formes Anciennes et de trouver le mot du littre corrsepondant
	 * @param input
	 * @param output
	 * @param consoleOutput
	 */
	public FormParser(String input, PrintWriter consoleOutput) {
		super(input, "", consoleOutput);
	}

	public void findMot(Node currentRoot, String mot) throws Exception{
		// Si il reste des lettres, on prend la premiere
		if (mot.length() > 0) {
			// On construit un XPath pour trouver le noeud correspondant a la lettre
			XPath xpath = XPathFactory.newInstance().newXPath();
			NodeList lettreList = null;
			String xPathExpr = "./lettre[@val='"+mot.charAt(0)+"']";
			lettreList = (NodeList)xpath.evaluate(xPathExpr, currentRoot, XPathConstants.NODESET);
			
			//TODO if (lettreList.getLength() > 1) raise Exception;
			// Le dictionnaire ne doit pas contenir plusieurs fois la meme lettre dans un meme noeud
			Element lettreNode = null;
			if (lettreList.getLength() != 0) {
				lettreNode = (Element) lettreList.item(0);
				this.findMot(lettreNode, mot.substring(1));
			} // if lettreList.getLength() == 0  
		} // if synonyme.length() > 0
		
		else {
			// Plus de lettres, on cherche si le mot existe
			XPath xpath = XPathFactory.newInstance().newXPath();
			NodeList motsList = null;
			String xPathExpr = "./mot";
			motsList = (NodeList)xpath.evaluate(xPathExpr, currentRoot, XPathConstants.NODESET);
			// On stocke dans le resultat le ou les mots trouves
			int motsLength=motsList.getLength();
			for (int i=0; i<motsLength; i++){
				String motVal = motsList.item(i).getTextContent();
				this.out.println("Resultat trouve : "+motVal);
				// TODO mettre les resultats en tableau
				this.result = motVal;
			} // for i in motList
		} // else synonyme.length() > 0
	}
	
	@Override
	public void parseXML() throws XPathExpressionException, Exception {
		/**
		 * Parser XML pour trouver le mot correspondant a celui fourni en input
		 */
		if (this.motInput.length() > 0){
			// Creation du XPath et recuperation des lettres
			XPath xpath = XPathFactory.newInstance().newXPath();
			NodeList lettreList = null;
			lettreList = (NodeList)xpath.evaluate("//doc", this.xmlInput, XPathConstants.NODESET);
			int lettresLength=lettreList.getLength();
			if (lettresLength > 0)
				this.findMot(lettreList.item(0), this.motInput);
		} //if motInput != "" 
		
	}
	
	@Override
	public void createOutput() throws Exception{
		// Pour s'assurer que l'on ne puisse creer d'output
		this.xmlOutput = null;
	}
	
	@Override
	public void writeOutput() throws Exception{
		// Pour s'assurer que l'on ne puisse creer d'output
		this.out.println(this.result);
	}
}
