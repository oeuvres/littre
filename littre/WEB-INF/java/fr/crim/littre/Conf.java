package fr.crim.littre;


import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URISyntaxException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Properties;
import java.util.Set;

import lia.analysis.LuceneTagger;

import org.apache.commons.codec.language.RefinedSoundex;
import org.apache.lucene.analysis.ASCIIFoldingFilter;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.GramcharFilter;
import org.apache.lucene.analysis.KeywordTokenizer;
import org.apache.lucene.analysis.LetterTokenizer;
import org.apache.lucene.analysis.LexiqueFilter;
import org.apache.lucene.analysis.LowerCaseFilter;
import org.apache.lucene.analysis.LowerCaseTokenizer;
import org.apache.lucene.analysis.PerFieldAnalyzerWrapper;
import org.apache.lucene.analysis.PhoneticFilter;
import org.apache.lucene.analysis.SimpleAnalyzer;
import org.apache.lucene.analysis.StopFilter;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.search.DefaultSimilarity;
import org.apache.lucene.search.Similarity;

/**
 * Configurations partagées pour l'application
 * @author fred
 *
 */
public class Conf {
	/** Un set de mots vides tout chargés */
	static Set<String> stopList;
	/** une chemin de fichier vers le dossier lib */
	static File lib;
	/**
	 * Où trouver le dossier lib ?
	 */
	/**
	 * Un dossier avec des ressources
	 */
	public static File lib() {
		if (lib != null) return lib();
		lib=new File("WEB-INF/lib");
		if (lib.exists()) return lib;
		try {
			lib=new File(new File( Conf.class.getProtectionDomain().getCodeSource().getLocation().toURI()).getParentFile().getParentFile().getParentFile().getParentFile().getParentFile(), "lib");
		} catch (URISyntaxException e) {
			e.printStackTrace();
		}
		return lib;
	}
	/**
	 * Charger les mots vide
	 * @throws IOException 
	 */
	public static Set<String> stopList() {
		if (stopList != null) return stopList;
		Properties props = new Properties();
		try {
		  InputStreamReader isr= new InputStreamReader(new FileInputStream(new File(lib(), "fr.stop")), "UTF-8");
		  props.load(isr);
		  isr.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		stopList=props.stringPropertyNames();
		return stopList;
	}
	/**
	 * Charger les mots vide
	 * @throws IOException 
	 */
	public static Set<String> stopGloss() {
		
		if (stopList != null) return stopList;
		Properties props = new Properties();
		try {
		  InputStreamReader isr= new InputStreamReader(new FileInputStream(new File(lib(), "fr.stop")), "UTF-8");
		  props.load(isr);
		  isr.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		stopList=props.stringPropertyNames();
		return stopList;
	}
	/**
	 * Similarité, calcul 
	 */
	public static Similarity getSimilarity() {
		return new DicSim();
	}
	/**
	 * Similarité adaptée à un dictionnaire
	 */
	@SuppressWarnings("serial")
	static public class DicSim extends DefaultSimilarity {
	  /* Pour diminuer l'effet de mots trop fréquents */
	  public float idf(int docFreq, int numDocs) {
	    return (float)(Math.log(numDocs/(double)(docFreq)) );
	  }
	  
	  /* avoid too much score for little docs */
	  public float tf(float freq) {
	    return freq; // (float)Math.sqrt(freq);
	  } 

	}
  /**
   * Envoi le même analyseur pour l'indexation et la recherche
   */
  public static Analyzer getAnalyzer() {
    PerFieldAnalyzerWrapper analyzer=new PerFieldAnalyzerWrapper(new SimpleAnalyzer());
    // TODO, ici brancher les analyzers selon les champs, voir 
    // http://lucene.apache.org/java/3_0_3/api/all/org/apache/lucene/analysis/PerFieldAnalyzerWrapper.html
    // analyzer.addAnalyzer("orth", new KeywordAnalyzer()); ?
    analyzer.addAnalyzer("id", new IdAnalyzer());
    analyzer.addAnalyzer("orth", new OrthAnalyzer());
    analyzer.addAnalyzer("orthGram", new ChargramAnalyzer());    // pour expérience comparative
    // analyzer.addAnalyzer("formGram", new ChargramAnalyzer()); // sur-représentation des verbes avec plusieurs formes 
    // analyzer.addAnalyzer("textGram", new ChargramAnalyzer()); // amusant pour la phonétique, mais non significatif
    analyzer.addAnalyzer("quote", new QuoteAnalyzer());
    analyzer.addAnalyzer("quoteSim", new SimAnalyzer());
    analyzer.addAnalyzer("glose", new SimAnalyzer());
    analyzer.addAnalyzer("form", new SoundAnalyzer());
    analyzer.addAnalyzer("author", new IdAnalyzer());
    return analyzer;
  }
  /** Analyseur pour les citations, les formes et tous les lemmes possibles (? tronquer les terminaisons ?) */
  public static class QuoteAnalyzer extends Analyzer { 
  	public TokenStream tokenStream(String fieldName, Reader reader) {
  		return new LexiqueFilter(
  			new StopFilter(true, 
  			  new LetterTokenizer(reader), 
  			  stopList(), true), 
  			new File(lib, "lexique.sqlite"), 
  			LexiqueFilter.LEMMAS_AND_FORM
  		);
  	}
  }
  /** Analyseur pour les similarités, juste des lemmes */
  public static class SimAnalyzer extends Analyzer { 
  	public TokenStream tokenStream(String fieldName, Reader reader) {
  		return new LexiqueFilter(
  			new StopFilter(true, 
  			  new LetterTokenizer(reader), 
  			  stopList(), true), 
  			new File(lib, "lexique.sqlite"), 
  			LexiqueFilter.LEMMA_NOT_FORM
  		);
  	}
  }
  /** Analyseur pour les similarités, juste des lemmes */
  public static class GlossAnalyzer extends Analyzer {
  	public TokenStream tokenStream(String fieldName, Reader reader) {
  		String[] list={"terme", "dire", "nom", "donner", "partir", "chose", "action", "servir", "mettre", "pouvoir", "sortir", "homme"};
			return new StopFilter(
				true,
	  		new LexiqueFilter(
	  			new StopFilter(
	  				true, 
	  			  new LetterTokenizer(reader), 
	  			  stopList(), 
	  			  true
	  			), 
	  			new File(lib, "lexique.sqlite"), 
	  			LexiqueFilter.LEMMA_NOT_FORM
	  		),
	  		new HashSet<String>(Arrays.asList(list))
			);
  	}
  }
  /** Analyseur pour l'identifiant = RIEN */
  public static class IdAnalyzer extends Analyzer { 
  	public TokenStream tokenStream(String fieldName, Reader reader) {
  		return new KeywordTokenizer(reader);
  	}
  }
  /** Analyseur pour les vedettes, conserver  */
  public static class OrthAnalyzer extends Analyzer { 
  	public TokenStream tokenStream(String fieldName, Reader reader) {
  		return  new ASCIIFoldingFilter( new LowerCaseFilter(new KeywordTokenizer(reader)));
  	}
  }
  /** Analyseur phonétique américain */
  public static class SoundAnalyzer extends Analyzer {
  	public TokenStream tokenStream(String fieldName, Reader reader) {
  		 return new PhoneticFilter(new ASCIIFoldingFilter (new LetterTokenizer(reader)), new RefinedSoundex(), false);
  	}
  }
  /** Un analyseur qui indexe des motifs de lettres */
  public static class ChargramAnalyzer extends Analyzer { 
  	public TokenStream tokenStream(String fieldName, Reader reader) {
  		return new GramcharFilter( new ASCIIFoldingFilter( new LowerCaseTokenizer(reader)));
  	}
  }
  /** Un analyseur pour désaccentuer */
  public static class AsciiAnalyzer extends Analyzer { 
  	public TokenStream tokenStream(String fieldName, Reader reader) {
  		return new ASCIIFoldingFilter( new LowerCaseTokenizer(reader));
  	}
  }
	public static void main(String[] args) throws IOException {
    // text to tokenize
    final String text = "Je suis le petit lapin Bugs Bunny et je ne vais pas à Paris.";
    Analyzer analyzer=new SimAnalyzer();
    System.out.println(text);
    new LuceneTagger().displayTokensWithPositions(analyzer, text);
  }
}

