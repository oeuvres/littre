package fr.crim.littre;

import java.io.IOException;
import java.io.Reader;

import lia.analysis.AnalyzerUtils;

import org.apache.lucene.analysis.ASCIIFoldingFilter;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.ChargramFilter;
import org.apache.lucene.analysis.KeywordTokenizer;
import org.apache.lucene.analysis.LetterTokenizer;
import org.apache.lucene.analysis.LowerCaseFilter;
import org.apache.lucene.analysis.LowerCaseTokenizer;
import org.apache.lucene.analysis.PerFieldAnalyzerWrapper;
import org.apache.lucene.analysis.SimpleAnalyzer;
import org.apache.lucene.analysis.TokenStream;

/**
 * Configurations partagées pour l'application
 * @author fred
 *
 */
public class Conf {
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
    analyzer.addAnalyzer("orthGram", new ChargramAnalyzer());
    analyzer.addAnalyzer("formGram", new ChargramAnalyzer());
    analyzer.addAnalyzer("form", new AsciiAnalyzer());
    return analyzer;
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
  /** Un analyseur qui indexe des motifs de lettres */
  public static class ChargramAnalyzer extends Analyzer { 
  	public TokenStream tokenStream(String fieldName, Reader reader) {
  		return new ChargramFilter( new ASCIIFoldingFilter( new LowerCaseTokenizer(reader)));
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
    final String text = "Ne pas couper";
    Analyzer analyzer=new OrthAnalyzer();
    AnalyzerUtils.displayTokensWithPositions(analyzer, text);
  }
}

