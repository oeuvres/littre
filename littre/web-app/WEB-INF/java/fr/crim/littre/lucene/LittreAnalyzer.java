package fr.crim.littre.lucene;


import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import lia.analysis.LuceneTagger;

import org.apache.lucene.analysis.ASCIIFoldingFilter;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.KeywordAnalyzer;
import org.apache.lucene.analysis.KeywordTokenizer;
import org.apache.lucene.analysis.LetterTokenizer;
import org.apache.lucene.analysis.LexiqueFilter;
import org.apache.lucene.analysis.LowerCaseFilter;
import org.apache.lucene.analysis.PerFieldAnalyzerWrapper;
import org.apache.lucene.analysis.ReusableAnalyzerBase;
import org.apache.lucene.analysis.SimpleAnalyzer;
import org.apache.lucene.analysis.StopFilter;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.Tokenizer;
import org.apache.lucene.util.Version;

import fr.crim.lucene.lexique.DBLookup;

/**
 * Analyseur pour le corpus Littré
 * @author frederic.glorieux@fictif.org
 *
 */
public class LittreAnalyzer extends Analyzer {
	/** L'analyseur configuré par champs */
	private static PerFieldAnalyzerWrapper analyzer;
	/** Permet de retrouver un dossier par défaut pour trouver un chemin vers les ressources */
	public static File WEB_INF=new File(LittreAnalyzer.class.getResource("LittreAnalyzer.class").getFile()).getParentFile().getParentFile().getParentFile().getParentFile().getParentFile().getParentFile();
	/** Version de lucene utilisée */
	public static final Version version=Version.LUCENE_35;
	/** Un set de mots vides tout chargés */
	private static Set<String> stopList;
	/** Utiliser l'analyseur en recherche */
	public static final int SEARCH=1;
	/** Utiliser l'analyseur en indexation */
	public static final int INDEX=0;

	/**
	 * analyseur par défaut, utilisé par Alix pour indexation
	 */
	public LittreAnalyzer() {
		this(INDEX);
	}
	/**
	 * Analyseur 
	 */
	public LittreAnalyzer(int mode) {
		// ici brancher les analyzers selon les champs, voir 
		// http://lucene.apache.org/core/old_versioned_docs/versions/3_5_0/api/all/org/apache/lucene/analysis/PerFieldAnalyzerWrapper.html
		Map<String, Analyzer> conf = new HashMap<String, Analyzer>();
		conf.put("id", new KeywordAnalyzer());
		conf.put("orth", new OrthAnalyzer());
		// La recherche sur forme fléchie réagit déifféremment à l'indexation ou à la recherche
		// on cherche tous les mots séparés d'espace 
		if (mode==SEARCH) conf.put("form", new SimpleAnalyzer(version));
		else conf.put("form", new InflectAnalyzer());;

		// pas utilisé par IndexEntry
		conf.put("quote", new TextAnalyzer());
		conf.put("glose", new TextAnalyzer());

		analyzer=new PerFieldAnalyzerWrapper(new SimpleAnalyzer(version), conf);
		Properties props = new Properties();
		try {
			InputStreamReader isr= new InputStreamReader(new FileInputStream(new File(WEB_INF, "lib/fr.stop")), "UTF-8");
			props.load(isr);
			isr.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		stopList=props.stringPropertyNames();
	}

	@Override
	public TokenStream tokenStream(String fieldName, Reader reader) {
		return analyzer.tokenStream(fieldName, reader);
	}

	@Override
	public TokenStream reusableTokenStream(String fieldName, Reader reader)
		throws IOException {
		return analyzer.reusableTokenStream(fieldName, reader);
	}

	/** 
	 * Analyseur félchissant une forme.
	 * Prendre la forme complète, pour éviter de répondre “peut-être” pour “es”.
	 */
	public static class InflectAnalyzer extends ReusableAnalyzerBase {
		private DBLookup dbLookup;
		
		public InflectAnalyzer() {
			super();
			
			File dbFile = new File(WEB_INF, "lib/lexique.sqlite");
			try {
				// Sans activation du cache pour limiter la consommation mémoire
				dbLookup = new DBLookup(dbFile, false);
			} catch (Exception e) {
				e.printStackTrace();
				System.err.println("Impossible de se connecter à la base de données ["+dbFile+"]");
			}
		}
		
		@Override
		public void finalize() {
			dbLookup.close();
		}
		
		@Override
		protected TokenStreamComponents createComponents(String fieldName, Reader reader) {
			final Tokenizer source = new KeywordTokenizer(reader);
	    	final TokenStream sink = new LexiqueFilter(source, dbLookup, LexiqueFilter.FORMS);
		    return new TokenStreamComponents(source, sink);
		}
	}

	/** 
	 * Analyseur pour les vedettes, spliter les mots composés.
	 */
	public static class OrthAnalyzer extends ReusableAnalyzerBase { 
		@Override
		protected TokenStreamComponents createComponents(String fieldName, Reader reader) {
			final Tokenizer source = new LetterTokenizer(version, reader);
		    TokenStream sink = new LowerCaseFilter(version, source);
		    sink = new ASCIIFoldingFilter(sink);
		    return new TokenStreamComponents(source, sink);
		}
	}
	/** Analyseur pour les citations, les formes et tous les lemmes possibles (? tronquer les terminaisons ?) */
	public static class TextAnalyzer extends ReusableAnalyzerBase { 
		@Override
		protected TokenStreamComponents createComponents(String fieldName, Reader reader) {
			final Tokenizer source = new LetterTokenizer(version, reader);
			TokenStream sink = new StopFilter(version, source, stopList, true);
		    return new TokenStreamComponents(source, sink);
		}
	}
	public static void main(String[] args) throws IOException {
		// text to tokenize
		final String text = "COURIR, GÂTER, je-suis-un-mot-qui-n'existe-pas PARMESAN, CONNERIE";
		Analyzer analyzer=new InflectAnalyzer();
		System.out.println(text);
		new LuceneTagger().displayTokensWithFullDetails(analyzer, text);
	}
}

