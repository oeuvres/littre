<%@ page
language="java"
session="false"
pageEncoding="UTF-8"
contentType="text/html; charset=UTF-8"
import = "
java.io.File,
java.io.InputStreamReader,
java.io.FileInputStream,
java.io.Writer,
java.io.IOException,
java.util.Properties,
fr.crim.littre.Conf,
fr.crim.littre.IndexEntry,
org.apache.lucene.analysis.Analyzer,
org.apache.lucene.document.Document,
org.apache.lucene.index.IndexReader,
org.apache.lucene.queryParser.QueryParser,
org.apache.lucene.search.IndexSearcher,
org.apache.lucene.search.Query,
org.apache.lucene.search.ScoreDoc,
org.apache.lucene.search.TopDocs,
org.apache.lucene.store.FSDirectory,
org.apache.lucene.util.Version,
org.apache.lucene.search.similar.MoreLikeThis
"
%>
<%!
%>
<%
// coucou(out);
// préfixe des liens de redirection
String baseHref="?q=";
if(request.getParameter("baseHref") != null) baseHref=request.getParameter("baseHref");

String q="";
if(request.getParameter("q") != null) q=request.getParameter("q");

// si paramètre ?body=, pas d'emballage html
if(request.getParameter("body") == null) {
%>
<html>
  <head>
    <title>Littré</title>
    <link rel="stylesheet" type="text/css" href="theme/littre.css"/>
    <script type="text/javascript">
function go() {
  var forme;
  if (window.getSelection) forme=window.getSelection();
  else if (document.getSelection) forme=document.getSelection();
  else if (document.selection) forme=document.selection.createRange().text;
  document.forms['search']['q'].value=forme;
  document.forms['search'].submit();
}
    </script>
  </head>
  <body ondblclick="go();">
    <form name="search" action="" method="get">
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
File indexDir=new File(appDir, "index");
// réindexer
if (request.getParameter("index") != null ) {
	out.println("Indexation lancée (peut prendre quelques minutes)…");
  application.setAttribute("searcher", null);
  IndexEntry.index(new File(appDir, "xml"), indexDir, new File(appDir, "WEB-INF/lib/lexique.sqlite"));
}
// charger un searcher, mis en cache pour éviter de le rouvrir à chaque fois
IndexSearcher searcher=(IndexSearcher)application.getAttribute("searcher");
// rien en cache, recharger
if (searcher==null) {
  searcher=new IndexSearcher(
    IndexReader.open(FSDirectory.open(indexDir), true)
  );
  application.setAttribute("searcher", searcher);
}
Query query;
TopDocs results=null;
Analyzer analyzer = Conf.getAnalyzer();
// chercher un mot
// écriture un peu particulière évitant trop de tests imbriqués
// ! ne pas oublier de sortir
while (true) {
  if ("".equals(q)) break;
  query=(new QueryParser(Version.LUCENE_CURRENT, "orth", analyzer)).parse(q);
  results=searcher.search(query, 100);
  if (results.totalHits != 0) break;
  query=(new QueryParser(Version.LUCENE_CURRENT, "form", analyzer)).parse(q);
  results=searcher.search(query, 100);
  break;
}
if (results==null || results.totalHits == 0) {
  out.println("<p>Pas de résultats</p>");
}
else {
  MoreLikeThis mlt = new MoreLikeThis(searcher.getIndexReader());
  Query mltq=null;
  String[] terms;
  int refid;
  int likeid;
	Document refdoc;
	Document likedoc;
  String[][] fields={{"quoteSim"},{"glossSim"},{"textSim"}};
  for (int i = 0; i < results.totalHits; i++) {
    // out.print(i);
    refid=results.scoreDocs[i].doc;
    refdoc = searcher.doc(refid);
    for (String[] field: fields) {
    	mlt.setFieldNames(field);
    	// mlt.setMaxQueryTerms(100); // augmenter le nb de termes ?
      mltq=mlt.like(refid);
    	out.print("<b title=\"");
    	terms=mlt.retrieveInterestingTerms(refid);
    	for (int z=0; z < terms.length; z++) {
    		if (z !=0) out.print(", ");
    		out.print(terms[z]);
    	}
    	out.print(".\">"+field[0]+"</b>");
      TopDocs hits = searcher.search(mltq, null, 25);
      int len = hits.totalHits;
      ScoreDoc[] scoreDocs = hits.scoreDocs;
      for (int j = 0; j < Math.min(25, len); j++) {
      	likeid=scoreDocs[j].doc;
      	likedoc = searcher.doc(likeid);
      	out.print(", <a title=\"");
      	terms=mlt.retrieveInterestingTerms(likeid);
      	for (int z=0; z < terms.length; z++) {
      		if (z !=0) out.print(", ");
      		out.print(terms[z]);
      	}
      	out.print(".\">"+likedoc.get("id")+"</span>");
      }
      out.println(".<br/>");
    }
    out.println(refdoc.get("html"));
  }
}

if(request.getParameter("body") == null) {
%>
  </body>
</html>
<%
}
%>
