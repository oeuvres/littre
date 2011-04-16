<%@ page
language="java"
session="false"
pageEncoding="UTF-8"
contentType="text/html; charset=UTF-8"
import = "
java.io.*,
java.util.*,
fr.crim.littre.*,
org.apache.lucene.analysis.*,
org.apache.lucene.document.Document,
org.apache.lucene.index.*,
org.apache.lucene.search.*,
org.apache.lucene.queryParser.QueryParser,
org.apache.lucene.store.FSDirectory,
org.apache.lucene.util.Version
"
%>
<%!
/** Afficher le contenu d'une specif comme une table HTML */
void specif_table(Specif specif, Writer out) {
	
}
%>
<%
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
if (request.getParameter("force") != null ) application.setAttribute("searcher", null);
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
  String[] terms;
  int refid, qid;
  int likeid;
	Document refdoc, qdoc;
	Document likedoc;
	
  for (int i = 0; i < results.totalHits; i++) {
    refid=results.scoreDocs[i].doc;
    refdoc = searcher.doc(refid);
    out.println(refdoc.get("html"));
    String lemme=refdoc.get("orth");
    out.println("<table>");
    out.println("<caption>"+lemme+" : cooccurrents</caption>");
    out.println("<tr><th>Glose</th><th>Citations</th></tr>");
		out.print("<tr><td valign=\"top\">");
 	  Specif specif = new Specif(searcher.getIndexReader());
 	  specif.add(refid, "glose");
 	  specif.html(out);
		out.print("</td><td valign=\"top\">");
    query=new TermQuery(new Term("quote", lemme));
    TopDocs quotes=searcher.search(query, 10000);
    Specif speQuote=new Specif(searcher.getIndexReader());
    for (int j = 0; j < quotes.totalHits; j++) {
      qid=quotes.scoreDocs[j].doc;
      speQuote.add(qid, "quoteSim");
      qdoc = searcher.doc(qid);
      // out.println(qdoc);
    }
    speQuote.html(out);
		out.print("</td></tr>\n</table>");
    // out.print("<textarea rows=\"20\" style=\"width:100%; \">");
    // out.print("</textarea>");
    
   	// out.print(".\">"+field[0]+"</b>");
  }
}

if(request.getParameter("body") == null) {
out.print("<script type=\"text/javascript\" src=\"theme/Sortable.js\">//</script>");
%>
  </body>
</html>
<%
}
%>
