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

final static String CACHE_LUC="cnrtl_littre";
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
if (request.getRequestURI().indexOf(".jsp") != -1 || request.getParameter("q") != null) {
	if(request.getParameter("q") != null) q=request.getParameter("q");
	baseHref="?q=";
}
// accès par clean URI
else {
	if(request.getPathInfo() != null) q=request.getPathInfo().substring(1);
}
// verion affichabe du mot
String mot=q.toUpperCase();
// pour surcharge d'un préfixe de lien (comme WebService)
if(request.getParameter("baseHref") != null) baseHref=request.getParameter("baseHref");

// si paramètre ?body=, pas d'emballage html
if(request.getParameter("body") == null) {
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xml:lang="fr" xmlns="http://www.w3.org/1999/xhtml" lang="fr"><head>
		<meta http-equiv="content-language" content="fr"/>
		<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
		<meta name="robots" content="index,follow"/>
		<meta name="keywords" content="<%= mot %>, Littré"/>
		<title><%= mot %> (Littré)</title>
		<link type="image/x-icon" rel="icon" href="http://cnrtl.fr/favicon.ico"/>

		<link type="text/css" rel="stylesheet" media="all" href="cnrtl/stylev24.css"/>
		<link type="text/css" rel="stylesheet" media="all" href="cnrtl/portailv24.css"/>
		<link type="text/css" rel="stylesheet" media="all" href="theme/littre.css"/>
		<script type="text/javascript" src="cnrtl/overlib.js">//</script>
		<script type="text/javascript" src="cnrtl/utilitiesv25.js">//</script>
	</head>
  <body onload="initPortail();">
		<div id="wrap">

			<div id="header">
				<map name="Map" id="id_map">
					<area shape="rect" coords="15,5,170,40" href="http://www.cnrtl.fr/" alt="Accueil du CNRTL"/>
					<area shape="rect" coords="780,35,825,80" href="http://www.cnrs.fr/" alt="Site du CNRS"/>
					<area shape="rect" coords="830,35,890,80" href="http://www.atilf.fr/" alt="Site de l'ATILF"/>
				</map>
				<img src="cnrtl/bandeau.jpg" alt="" usemap="#Map"/>
			</div>
			<div id="nav">

				<ul>
					<li class="sep">&nbsp;</li>
					<li><a href="http://cnrtl.fr/"><img src="cnrtl/PointR.jpg" alt=""/>Accueil</a></li>
					<li class="sep current_left">&nbsp;</li>
					<li class="current"><a href="http://cnrtl.fr/portail/"><img src="cnrtl/PointR.jpg" alt=""/>Portail lexical</a></li>
					<li class="sep current_right">&nbsp;</li>
					<li><a href="http://cnrtl.fr/corpus/"><img src="cnrtl/PointR.jpg" alt=""/>Corpus</a></li>

					<li class="sep">&nbsp;</li>
					<li><a href="http://cnrtl.fr/lexiques/"><img src="cnrtl/PointR.jpg" alt=""/>Lexiques</a></li>
					<li class="sep">&nbsp;</li>
					<li><a href="http://cnrtl.fr/dictionnaires/"><img src="cnrtl/PointR.jpg" alt=""/>Dictionnaires</a></li>
					<li class="sep">&nbsp;</li>
					<li><a href="http://cnrtl.fr/outils/"><img src="cnrtl/PointR.jpg" alt=""/>Outils</a></li>
					<li class="sep">&nbsp;</li>

					<li><a href="mailto:contact@cnrtl.fr?subject=CNRTL"><img src="cnrtl/PointR.jpg" alt=""/>Contact</a></li>
					<li class="sep">&nbsp;</li>
				</ul>
			</div>
			<div id="main_content">
<div><ul class="tab_box"><li><a href="http://cnrtl.fr/morphologie/" onclick="return sendRequest(0,'/morphologie/');">Morphologie</a></li><li><a class="active" href="http://cnrtl.fr/definition/" onclick="return sendRequest(0,'/definition/');">Lexicographie</a></li><li><a href="http://cnrtl.fr/etymologie/" onclick="return sendRequest(0,'/etymologie/');">Etymologie</a></li><li><a href="http://cnrtl.fr/synonymie/" onclick="return sendRequest(0,'/synonymie/');">Synonymie</a></li><li><a href="http://cnrtl.fr/antonymie/" onclick="return sendRequest(0,'/antonymie/');">Antonymie</a></li><li><a href="http://cnrtl.fr/proxemie/" onclick="return sendRequest(0,'/proxemie/');">Proxémie</a></li><li><a href="http://cnrtl.fr/concordance/" onclick="return sendRequest(0,'/concordance/');">Concordance</a></li><li><a href="http://cnrtl.fr/aide/" onclick="return sendRequest(0,'/aide/');">Aide</a></li></ul></div>

<div id="content">
<table border="0" cellpadding="0" cellspacing="4" width="100%"><tbody><tr valign="top"><td id="menubox">
<table class="plugin_menu" cellpadding="0" cellspacing="0"><tbody><tr class="plugin_on" onclick="return sendRequest(0,'/definition/');">


<td class="plugin_image"><img src="cnrtl/tlfi_icon.jpg" alt="" height="44" width="36"/></td><td><h1>TLFi</h1><h2></h2></td>
</tr>
<tr onclick="return sendRequest(0,'/definition/academie9/');">
<td class="plugin_image"><img src="cnrtl/aca9_icon.jpg" alt="" height="44" width="36"/></td><td><h1>Académie</h1><h2>9<sup>ème</sup> édition</h2></td>
</tr>
<tr onclick="return sendRequest(0,'/definition/academie8/');">
<td class="plugin_image"><img src="cnrtl/aca8_icon.jpg" alt="" height="44" width="36"/></td><td><h1>Académie</h1><h2>8<sup>ème</sup> édition</h2></td>

</tr>
<tr onclick="return sendRequest(0,'/definition/academie4/');">
<td class="plugin_image"><img src="cnrtl/aca4_icon.jpg" alt="" height="44" width="36"/></td><td><h1>Académie</h1><h2>4<sup>ème</sup> édition</h2></td>
</tr>
<tr onclick="return sendRequest(0,'/definition/francophonie/');">
<td class="plugin_image"><img src="cnrtl/fran_icon.gif" alt="" height="44" width="36"/></td><td><h1>BDLP</h1><h2>Francophonie</h2></td>
</tr>
<tr onclick="return sendRequest(0,'/definition/bhvf/');">
<td class="plugin_image"><img src="cnrtl/atilf.gif" alt="" height="44" width="36"/></td><td><h1>BHVF</h1><h2>attestations</h2></td>

</tr>
<tr onclick="return sendRequest(0,'/definition/dmf/');">
<td class="plugin_image"><img src="cnrtl/dmf_cnrtl.jpg" alt="" height="44" width="36"/></td><td><h1>DMF</h1><h2>(1330 - 1500)</h2></td>
</tr>
<tr onclick="return sendRequest(0,'/definition/ducange/');">
<td class="plugin_image"><img src="cnrtl/ducange.png" alt="" height="44" width="36"/></td><td><h1>Du Cange</h1><h2>Moyen Âge</h2></td>
</tr>
</tbody></table></td><td width="100%">			
<div id="optionBox">
				<form name="optionBoxForm" action="">
					<div align="left">

						<span class="small_font">Police de caractères: </span>
						<select id="tlf.fontname" onchange="changeFontName(this.selectedIndex);">
							<option selected="selected" value="arial">Arial</option>
							<option value="verdana">Verdana</option>
							<option value="helvetica">Helvetica</option>
							<option value="times">Times</option>

							<option value="times new roman">Times New Roman</option>
						</select>
						<br/>
						<br/>
						<input id="tlf.highlight" onclick="changeHighlight(this.checked);" type="checkbox"/><span class="small_font"> Surligner les objets textuels</span>
					</div>
					<table border="0" cellpadding="0" cellspacing="4" width="100%">
						<tbody><tr>

							<td>
								<table border="0" cellpadding="0" cellspacing="0" width="100%">
									<tbody><tr>
										<td class="small_font" align="center"><b>Colorer les objets :</b></td>
									</tr>
									<tr>
										<td align="center">
											<table border="0">

																							<tbody><tr>
													<td class="tlf_color0"></td>
													<td>&nbsp;</td>
													<td>
														<select name="tlf.color0" onchange="changeColor(0,this);">
															<option selected="selected">Aucun</option>
															<option>Auteur d'exemple</option>
															<option>Code grammatical</option>

															<option>Construction</option>
															<option>Crochets</option>
															<option>Date d'exemple</option>
															<option>Définition</option>
															<option>Domaine technique</option>
															<option>Entrée</option>

															<option>Exemple</option>
															<option>Indicateur</option>
															<option>Mot vedette</option>
															<option>Plan de l'article</option>
															<option>Publication</option>
															<option>Source</option>

															<option>Synonyme/antonyme</option>
															<option>Syntagme</option>
															<option>Titre d'exemple</option>
														</select>
													</td>
												</tr>
																							<tr>
													<td class="tlf_color1"></td>

													<td>&nbsp;</td>
													<td>
														<select name="tlf.color1" onchange="changeColor(1,this);">
															<option selected="selected">Aucun</option>
															<option>Auteur d'exemple</option>
															<option>Code grammatical</option>
															<option>Construction</option>

															<option>Crochets</option>
															<option>Date d'exemple</option>
															<option>Définition</option>
															<option>Domaine technique</option>
															<option>Entrée</option>
															<option>Exemple</option>

															<option>Indicateur</option>
															<option>Mot vedette</option>
															<option>Plan de l'article</option>
															<option>Publication</option>
															<option>Source</option>
															<option>Synonyme/antonyme</option>

															<option>Syntagme</option>
															<option>Titre d'exemple</option>
														</select>
													</td>
												</tr>
																							<tr>
													<td class="tlf_color2"></td>
													<td>&nbsp;</td>
													<td>

														<select name="tlf.color2" onchange="changeColor(2,this);">
															<option selected="selected">Aucun</option>
															<option>Auteur d'exemple</option>
															<option>Code grammatical</option>
															<option>Construction</option>
															<option>Crochets</option>

															<option>Date d'exemple</option>
															<option>Définition</option>
															<option>Domaine technique</option>
															<option>Entrée</option>
															<option>Exemple</option>
															<option>Indicateur</option>

															<option>Mot vedette</option>
															<option>Plan de l'article</option>
															<option>Publication</option>
															<option>Source</option>
															<option>Synonyme/antonyme</option>
															<option>Syntagme</option>

															<option>Titre d'exemple</option>
														</select>
													</td>
												</tr>
																							<tr>
													<td class="tlf_color3"></td>
													<td>&nbsp;</td>
													<td>
														<select name="tlf.color3" onchange="changeColor(3,this);">

															<option selected="selected">Aucun</option>
															<option>Auteur d'exemple</option>
															<option>Code grammatical</option>
															<option>Construction</option>
															<option>Crochets</option>
															<option>Date d'exemple</option>

															<option>Définition</option>
															<option>Domaine technique</option>
															<option>Entrée</option>
															<option>Exemple</option>
															<option>Indicateur</option>
															<option>Mot vedette</option>

															<option>Plan de l'article</option>
															<option>Publication</option>
															<option>Source</option>
															<option>Synonyme/antonyme</option>
															<option>Syntagme</option>
															<option>Titre d'exemple</option>

														</select>
													</td>
												</tr>
																							<tr>
													<td class="tlf_color4"></td>
													<td>&nbsp;</td>
													<td>
														<select name="tlf.color4" onchange="changeColor(4,this);">
															<option selected="selected">Aucun</option>

															<option>Auteur d'exemple</option>
															<option>Code grammatical</option>
															<option>Construction</option>
															<option>Crochets</option>
															<option>Date d'exemple</option>
															<option>Définition</option>

															<option>Domaine technique</option>
															<option>Entrée</option>
															<option>Exemple</option>
															<option>Indicateur</option>
															<option>Mot vedette</option>
															<option>Plan de l'article</option>

															<option>Publication</option>
															<option>Source</option>
															<option>Synonyme/antonyme</option>
															<option>Syntagme</option>
															<option>Titre d'exemple</option>
														</select>
													</td>
												</tr>

																							<tr>
													<td class="tlf_color5"></td>
													<td>&nbsp;</td>
													<td>
														<select name="tlf.color5" onchange="changeColor(5,this);">
															<option selected="selected">Aucun</option>
															<option>Auteur d'exemple</option>
															<option>Code grammatical</option>

															<option>Construction</option>
															<option>Crochets</option>
															<option>Date d'exemple</option>
															<option>Définition</option>
															<option>Domaine technique</option>
															<option>Entrée</option>

															<option>Exemple</option>
															<option>Indicateur</option>
															<option>Mot vedette</option>
															<option>Plan de l'article</option>
															<option>Publication</option>
															<option>Source</option>

															<option>Synonyme/antonyme</option>
															<option>Syntagme</option>
															<option>Titre d'exemple</option>
														</select>
													</td>
												</tr>
																						</tbody></table>
										</td>

									</tr>
								</tbody></table>
							</td>
						</tr>
					</tbody></table>
					<input value="Fermer" onclick="return hideOptionBox();" type="submit"/>
				</form>
			</div>
			<div class="box bottombox">

				<div class="font_change" onclick="location.href='/definition/'"><img src="cnrtl/home.gif" alt="" title="Retour à la liste des formes" border="0" height="24" width="24"/></div>
				<div class="font_change" onclick="printPage();"><img src="cnrtl/printer.jpg" alt="" title="Imprimer la page" border="0" height="25" width="25"/></div>
				<div class="font_change" onclick="changeFontSize(+0.1);"><img src="cnrtl/font-inc.gif" alt="" title="Augmenter la taille du texte" border="0" height="25" width="25"/></div>
				<div class="font_change" onclick="changeFontSize(-0.1);"><img src="cnrtl/font-dec.gif" alt="" title="Diminuer la taille du texte" border="0" height="25" width="25"/></div>
				<form id="reqform" action="#" accept-charset="UTF-8">
					<table border="0" cellpadding="0" cellspacing="1">
						<tbody><tr>
							<td><h2>Entrez une forme</h2></td>

							<td colspan="2"><input size="48" name="q" id="query" value="<%=q%>" title="Saisir une forme" type="text"/></td>
							<td><input id="search" value="Chercher" title="Chercher une forme" type="submit"/></td>
						</tr>
						<tr>
							<td></td>
<td class="small_options"><a href="#" onclick="return displayOptionBox(this);">options d'affichage</a></td><td class="small_menu_font">catégorie : <select id="category"><option selected="selected" value="">toutes</option>
<option value="substantif">substantif</option>
<option value="verbe">verbe</option>

<option value="adjectif">adjectif</option>
<option value="adverbe">adverbe</option>
<option value="interjection">interjection</option>
</select></td>
						</tr>
					</tbody></table>
				</form>
			</div>
<div id="vtoolbar">
  <ul><li id="vitemselected"><a href="#" onclick="return sendRequest(5,'/definition/pierre//0');"><span><%= mot %></span></a></li></ul>
</div>

<div style="font-size: 1em;" id="contentbox">


<%
  }
		out.println("<div class=\"cnrtl\">");
    // le dossier de l'application (ici)
    File appDir=new File(application.getRealPath("/"));
    File indexDir=new File(appDir, "index");
    if (!indexDir.mkdirs()) {
      indexDir=new File(new File(getClass().getProtectionDomain().getCodeSource().getLocation().toURI()), "index");
      indexDir.mkdirs();
    }
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
    Analyzer analyzer = Conf.getAnalyzer();
    Document doc;
    // chercher un mot
    // écriture un peu particulière évitant trop de tests imbriqués
    // ! ne pas oublier de sortir
    while (true) {
      if ("".equals(q)) break;
      query=(new QueryParser(Version.LUCENE_CURRENT, "id", analyzer)).parse(q);
      results=searcher.search(query, 100);
      if (results.totalHits != 0) break;
      query=(new QueryParser(Version.LUCENE_CURRENT, "orth", analyzer)).parse(q);
      results=searcher.search(query, 100);
      if (results.totalHits != 0) break;
      query=(new QueryParser(Version.LUCENE_CURRENT, "form", analyzer)).parse(q);
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
    else if (results.totalHits < 5) {
      for (int i = 0; i < results.totalHits; i++) {
    	  doc = searcher.doc(results.scoreDocs[i].doc);
    	  out.println(doc.get("html"));
      }
    }
    else {
    	float score=results.scoreDocs[0].score;
      for (int i = 0; i < results.totalHits; i++) {
        doc = searcher.doc(results.scoreDocs[i].doc);
      	if ((results.scoreDocs[i].score / score) < 0.8) {
      		out.println(" ?");
      		break;
      	}
      	else if (i>0) out.println(", ");
        out.print("<a href=\""+baseHref+doc.get("id")+"\">"+doc.get("orth")+"</a>");
      }
    }
    out.print("<p class=\"credits\">Cette édition du <i>Littré</i> est réalisée par l’<a href=\"\">École des chartes</a> et l’<a href=\"http://crim.fr/master_2\">INALCO</a> (<a href=\"http://javacrim.sourceforge.net/littre/\">Crédits</a>).</p>");
		out.println("</div>");
    if(request.getParameter("body") == null) {
    %>
</div>
</td>
</tr>
</tbody>
</table>
</div>
</div>
			<div id="footer">
				<div id="footerleft">
	
					<a href="http://www.lorraine.pref.gouv.fr/index.php?headingid=112">
						<img src="cnrtl/Logo_Feder_Lorraine_h50.jpg" alt="" border="0"/>
					</a>
					<a href="http://www.tge-adonis.fr/">
						<img src="cnrtl/logo-adonis.jpg" alt="" align="top" border="0"/>
					</a>
				</div>
				<div id="footerright">
					<a href="http://validator.w3.org/check?uri=referer">
	
						<img src="cnrtl/xhtml10.png" alt="Valid XHTML 1.0 Strict" border="0"/>
					</a>
					<a href="http://jigsaw.w3.org/css-validator/">
						<img src="cnrtl/vcss.png" alt="Valid Cascading Style Sheet" border="0"/>
					</a>
				</div>
				<p>
					© 2009 - CNRTL<br/>
	
					44, avenue de la Libération BP 30687 54063 Nancy Cedex - France<br/>
					Tél. : +33 3 83 96 21 76 - Fax : +33 3 83 97 24 56
				</p>
			</div>
		</div>
	</body>
</html>
  <%
}
%>
