package fr.crim.littre;


import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.Map;
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
import org.apache.lucene.util.Version;

/**
 * Configurations partagées pour l'application entre ligne de commande et web
 * @author fred
 *
 */
public class Conf {
	/** Version de lucene utilisée */
	static Version version=Version.LUCENE_35;
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
		if (lib != null) return lib;
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
	 * 
	 * <ul>
	 *   <li>docFreq - the number of documents which contain the term</li>
	 *   <li>numDocs - the total number of documents in the collection</li>
	 * </ul>
	 */
	@SuppressWarnings("serial")
	static public class DicSim extends DefaultSimilarity {
		/* Pour diminuer l'effet de mots trop fréquents */
		@Override
		public float idf(int docFreq, int numDocs) {
			return ((float)Math.log(1.0+docFreq)/(float)Math.log(1.0+numDocs));
			// return (float)(Math.log(numDocs/(double)(docFreq)) );
		}

		/* avoid too much score for little docs */
		@Override
		public float tf(float freq) {
			return freq; // (float)Math.sqrt(freq);
		} 

	}
	/**
	 * Envoi le même analyseur pour l'indexation et la recherche
	 * C'est ici que l'on peut modifier le modèle d'indexation selon les champs
	 */
	public static Analyzer getAnalyzer() {
		// ici brancher les analyzers selon les champs, voir 
		// http://lucene.apache.org/core/old_versioned_docs/versions/3_5_0/api/all/org/apache/lucene/analysis/PerFieldAnalyzerWrapper.html
		Map<String, Analyzer> conf = new HashMap<String, Analyzer>();
		conf.put("id", new IdAnalyzer());
		conf.put("orth", new OrthAnalyzer());
		conf.put("quote", new TextAnalyzer());
		conf.put("glose", new TextAnalyzer());
		conf.put("form", new OrthAnalyzer());
		conf.put("author", new IdAnalyzer());
		PerFieldAnalyzerWrapper analyzer=new PerFieldAnalyzerWrapper(new SimpleAnalyzer(version), conf);
		return analyzer;
	}
	/** Analyseur pour les citations, les formes et tous les lemmes possibles (? tronquer les terminaisons ?) */
	public static class TextAnalyzer extends Analyzer { 
		@Override
		public TokenStream tokenStream(String fieldName, Reader reader) {
			return new LexiqueFilter(
							new StopFilter(true, 
											new LetterTokenizer(reader), 
											stopList(), 
											true
							), 
							new File(lib(), "lexique.sqlite"), 
							LexiqueFilter.LEMMAS_AND_FORM
			);
		}
	}
	/** Analyseur pour l'identifiant = RIEN */
	public static class IdAnalyzer extends Analyzer { 
		@Override
		public TokenStream tokenStream(String fieldName, Reader reader) {
			return new KeywordTokenizer(reader);
		}
	}
	/** Analyseur pour les vedettes, conserver  */
	public static class OrthAnalyzer extends Analyzer { 
		@Override
		public TokenStream tokenStream(String fieldName, Reader reader) {
			return  new ASCIIFoldingFilter( new LowerCaseFilter(new KeywordTokenizer(reader)));
		}
	}
	/** Analyseur phonétique américain */
	public static class SoundAnalyzer extends Analyzer {
		@Override
		public TokenStream tokenStream(String fieldName, Reader reader) {
			return new PhoneticFilter(new ASCIIFoldingFilter (new LetterTokenizer(reader)), new RefinedSoundex(), false);
		}
	}
	/** Un analyseur qui indexe des motifs de lettres */
	public static class ChargramAnalyzer extends Analyzer { 
		@Override
		public TokenStream tokenStream(String fieldName, Reader reader) {
			return new GramcharFilter( new ASCIIFoldingFilter( new LowerCaseTokenizer(reader)));
		}
	}
	/** Un analyseur pour désaccentuer */
	public static class AsciiAnalyzer extends Analyzer { 
		@Override
		public TokenStream tokenStream(String fieldName, Reader reader) {
			return new ASCIIFoldingFilter( new LowerCaseTokenizer(reader));
		}
	}
	public static void main(String[] args) throws IOException {
		// text to tokenize
		final String text = "Vous seule pouvez faire la joie et la douleur de ma vie ; je ne connais que vous, et hors de vous tout est loin de moi.";
		Analyzer analyzer=new TextAnalyzer();
		System.out.println(text);
		new LuceneTagger().displayTokensWithPositions(analyzer, text);
	}
}

