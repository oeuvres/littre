<%@ page
language="java"
session="false"
pageEncoding="UTF-8"
contentType="text/html; charset=UTF-8"
import = "
fr.crim.littre.*,
java.io.File,
java.io.PrintStream,
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
		<form name="index" method="POST">
			<input name="index" value="Indexer" type="submit"/>
		</form>
		<%
// réindexer
// TODO, tester IP && (request.getRemoteAddr() == request.getLocalAddr())
if (!request.getMethod().equals("POST")); // action uniquement en post
else if (request.getParameter("index") != null) {
	out.println("Indexation lancée sur le serveur (peut prendre plusieurs minutes)…");
	// vider les attributs de contexte où pourrait se trouver des searcher
	for (Enumeration<String> e = application.getAttributeNames(); e.hasMoreElements();) application.removeAttribute(e.nextElement());
	Thread task=new IndexEntry(out);
	out.println("<pre>");
	task.run();
	out.println("</pre>");
}

		%>

	</body>
</html>
