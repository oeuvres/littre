<%@ page
language="java"
session="false"
pageEncoding="UTF-8"
contentType="text/html; charset=UTF-8"
import = "
java.io.File,
java.io.Writer,
java.io.IOException,
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
org.apache.lucene.util.Version
"
%>
<%!
// champs et méthodes de la classe JSP
public void coucou(JspWriter out) throws IOException {
  out.println("Beuh.");
}
%>
<%
// coucou(out);


String orth="";
if(request.getParameter("orth") != null) orth=request.getParameter("orth");

// si paramètre ?body=, pas d'emballage html
if(request.getParameter("body") != null) {
%>
<html>
  <head>
    <title>Littré</title>
    <link rel="stylesheet" type="text/css" href="theme/littre.css"/>
  </head>
  <body>
    <form name="search" action="" method="get">
      <p>Littré, consulter un mot<br/>
        <input name="orth" size="44" value="<%=orth%>"/>
      </p>
    </form>
<%
}
// le dossier de l'application (ici)
File appDir=new File(application.getRealPath("/"));
File indexDir=new File(appDir, "index");
// réindexer
if (request.getParameter("index") != null) {
  IndexEntry.index(new File(appDir, "xml"), indexDir);
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
TopDocs results;
Analyzer analyzer = Conf.getAnalyzer();
Document doc;
// chercher un mot
if (!"".equals(orth)) {
  query=(new QueryParser(Version.LUCENE_CURRENT, "orth", analyzer)).parse(orth);
  results=searcher.search(query, 100);
  if (results.totalHits == 0) {
    out.println("<p>Pas de résultats</p>");
  }
  else {
    for (int i = 0; i < results.totalHits; i++) {
      // out.print(i);
      doc = searcher.doc(results.scoreDocs[i].doc);
      out.println(doc.get("html"));
    }
  }


}

if(request.getParameter("body") != null) {
%>
  </body>
</html>
<%
}
%>
