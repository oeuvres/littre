package fr.crim.littre;

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.PerFieldAnalyzerWrapper;
import org.apache.lucene.analysis.SimpleAnalyzer;

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
    return analyzer;
  }
}
