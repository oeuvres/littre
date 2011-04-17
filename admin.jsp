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
<html>
	<head>
		<title>Littré, Administration</title>
	</head>
	<body>
		<%
 File appDir=new File(application.getRealPath("/"));
 File indexDir=new File(appDir, "index");
 if (!indexDir.mkdirs()) {
   indexDir=new File(new File(getClass().getProtectionDomain().getCodeSource().getLocation().toURI()), "index");
   indexDir.mkdirs();
 }
// réindexer
// TODO, tester IP && (request.getRemoteAddr() == request.getLocalAddr())
if ((request.getMethod().equals("POST") && request.getParameter("index") != null)  || indexDir.listFiles().length < 3 ) {
	out.println("Indexation lancée dans "+indexDir+" (peut prendre plusieurs minutes)…");
	// vider les attributs de contexte où pourrait se trouver des searcher
	for (Enumeration<String> e = application.getAttributeNames(); e.hasMoreElements();)
    application.removeAttribute(e.nextElement());
	Thread task=new IndexEntry(new File(appDir, "xml"), indexDir, new File(appDir, "WEB-INF/lib/lexique.sqlite"));
	task.start();
}

		%>
		<form name="index" method="POST">
			<input name="index" value="Indexer" type="submit"/>
		</form>

	</body>
</html>
