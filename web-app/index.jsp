<%@ page
language="java"
session="false"
pageEncoding="UTF-8"
contentType="text/html; charset=UTF-8"
import = "
fr.crim.littre.*,
java.io.File,
java.io.Writer,
java.io.IOException,
java.util.Enumeration,
org.apache.lucene.analysis.Analyzer,
org.apache.lucene.document.Document,
org.apache.lucene.index.IndexReader,
org.apache.lucene.queryParser.QueryParser,
org.apache.lucene.search.IndexSearcher,
org.apache.lucene.search.Query,
org.apache.lucene.search.ScoreDoc,
org.apache.lucene.search.TopDocs,
org.apache.lucene.store.FSDirectory,
org.apache.lucene.util.Version
"
%>
<%!
final static String CACHE_LUC="littre_searcher";

public static int count(String text, String occ) {
	int count=0;
	int pos=-1;
	while (count < 500) {
		pos = text.indexOf(occ, pos+1);  
		if (pos==-1) return count;
		count++;
	}
	return count;
}%>
<%
	String q="";
// utilisé pour écrire les liens
String baseHref="";
// accès par adresse jsp
if (request.getRequestURI().indexOf("index.jsp") != -1 || request.getParameter("q") != null) {
	if(request.getParameter("q") != null) q=request.getParameter("q");
	baseHref="?q=";
}
// accès par clean URI
else {
	if(request.getPathInfo() != null) q=request.getPathInfo().substring(1);
}
// pour surcharge d'un préfixe de lien (comme WebService)
if(request.getParameter("baseHref") != null) baseHref=request.getParameter("baseHref");

// si paramètre ?body=, pas d'emballage html
if(request.getParameter("body") == null) {
%>
<html>
  <head>
    <title>Littré</title>
    <link rel="stylesheet" type="text/css" href="<%="../../../../".substring(0, 3*(count(request.getRequestURI(), "/")-2))%>theme/littre.css"/>
    <script type="text/javascript">
function go() {
  var forme;
  if (window.getSelection) forme=window.getSelection();
  else if (document.getSelection) forme=document.getSelection();
  else if (document.selection) forme=document.selection.createRange().text;
  document.forms['search']['q'].value=forme;
  document.forms['search'].onsubmit();
  document.forms['search'].submit();
}
    </script>
  </head>
  <body ondblclick="go();" class="littre">
    <form name="search" action="" method="get" onsubmit="<%if(baseHref!="?q=") out.print("window.location.href=this.q.value; ");%>">
      <p>
        Littré, consulter un mot<br/>
        <input id="q" name="q" size="44" value="<%=q%>"/>
        <small>ou double-cliquer un mot dans le texte</small>
      </p>
    </form>
    
<%
    	}
                // le dossier de l'application (ici)
                File appDir=new File(application.getRealPath("/"));
                File indexDir=new File(appDir, "WEB-INF/index");
                /* encore utile ?
                if (!indexDir.mkdirs()) {
                  indexDir=new File(new File(getClass().getProtectionDomain().getCodeSource().getLocation().toURI()), "WEB-INF/index");
                  indexDir.mkdirs();
                }
                */
                if (request.getParameter("force") != null ) application.setAttribute(CACHE_LUC, null);
                // charger un searcher, mis en cache pour éviter de le rouvrir à chaque fois
                IndexSearcher searcher=(IndexSearcher)application.getAttribute(CACHE_LUC);
                // rien en cache, recharger
                if (searcher==null) {
                  searcher=new IndexSearcher(
                    IndexReader.open(FSDirectory.open(indexDir), true)
                  );
                  application.setAttribute(CACHE_LUC, searcher);
                }
                Query query;
                TopDocs results=null;
                Analyzer analyzer = new LittreAnalyzer(LittreAnalyzer.SEARCH);
                Document doc;
                // chercher un mot
                // écriture un peu particulière évitant trop de tests imbriqués
                // ! ne pas oublier de sortir
                while (true) {
                  if ("".equals(q)) break;
                  query=(new QueryParser(LittreAnalyzer.version, "id", analyzer)).parse(q);
                  results=searcher.search(query, 100);
                  if (results.totalHits != 0) break;
                  query=(new QueryParser(LittreAnalyzer.version, "orth", analyzer)).parse(q);
                  results=searcher.search(query, 100);
                  if (results.totalHits != 0) break;
                  query=(new QueryParser(LittreAnalyzer.version, "form", analyzer)).parse(q);
                  results=searcher.search(query, 100);
                  if (results.totalHits != 0) break;

                  /* Intéressant
                  q=q.replace("(s|aient|oient|oit|ait|ons|ont)$", "");
                  query=(new QueryParser(Version.LUCENE_CURRENT, "orthGram", analyzer)).parse(q);
                  results=searcher.search(query, 100);
                	*/
                  break;
                }
                if (results==null || results.totalHits == 0) {
                  out.println("<p>Pas de résultats</p>");
                }
                else if (results.totalHits < 8) {
                	if (results.totalHits>1) {
                		out.print("<p class=\"\">Articles : ");
                		for (int i = 0; i < results.totalHits; i++) {
                   	  doc = searcher.doc(results.scoreDocs[i].doc);
                   		if (i>0) out.print(", ");
                      out.print("<a href=\"#"+doc.get("id")+"\">"+doc.get("orth")+"</a>");
                     }
                		out.print(".</p>");
                	}
                  for (int i = 0; i < results.totalHits; i++) {
                	  doc = searcher.doc(results.scoreDocs[i].doc);
                	  out.println(doc.get("html"));
                  }
                }
                else {
                	float max=results.scoreDocs[0].score;
                	float score;
	            		out.print("<p class=\"\">Quel article : ");
                  for (int i = 0; i < results.totalHits; i++) {
                    doc = searcher.doc(results.scoreDocs[i].doc);
                  	score=results.scoreDocs[i].score / max;
                  	if (i>0) out.println(", ");
                    out.print("<a href=\""+baseHref+doc.get("id")+"\">"+doc.get("orth")+"</a>");
                  }
                  out.print(" ?</p>");
                }

                if(request.getParameter("body") == null) {
    %>
  </body>
</html>
<%
}
%>
