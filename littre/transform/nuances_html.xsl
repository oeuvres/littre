<?xml version="1.0" encoding="UTF-8"?>
<!--
Littré, nuances
-->
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.w3.org/1999/xhtml"
>
  <xsl:output  indent="no" method="xml" encoding="UTF-8"/>
  <xsl:param name="css">../transform/nuances.css</xsl:param>
  <!-- dosssier où trouver les ressources -->
  <xsl:variable name="min">abcdefghijklmnopqrstuvwxyzâêîôûäëïöüáéíóúàèìòùçæœ</xsl:variable>
  <xsl:variable name="maj">ABCDEFGHIJKLMNOPQRSTUVWXYZÂÊÎÔÛÄËÏÖÜÁÉÍÓÚÀÈÌÒÙÇÆŒ</xsl:variable>
  <!-- Clé pour retrouver l'entrée -->
  <xsl:key name="orth" match="orth" use="tei:m|."/>
  

  <!-- / racine du document = racine html -->
  <xsl:template match="/">
    <xsl:text disable-output-escaping="yes"><![CDATA[
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
]]></xsl:text>
    <!-- TODO en tête html et DOCTYPE -->
    <html>
      <head>
        <meta http-equiv="Content-type" content="text/html; charset=UTF-8" />
        <link rel="stylesheet" href="../diple/theme/_/html.css"/>
        <script type="text/javascript" src="../diple/js/Tree.js">//</script>
        <style type="text/css">
ul.tree ul.entry {
  background:#FFF;
}
ul.tree li {
  padding-left:0px !important;
}
li a.section {
  padding:left:16px;
}
li li a.section {
  padding:left:32px;
}
li li li a.section {
  padding:left:48px;
}
li li li li a.section {
  padding:left:64px;
}
p.entry {
  font-family:Garamond, serif;
  font-size:18px;
}
        </style>
      </head>
      <body class="fixed">
        <div id="article">
          <xsl:apply-templates/>
        </div>
        <xsl:call-template name="nav"/>
        <script type="text/javascript">Tree.load();</script>
      </body>
    </html>
  </xsl:template>


  <xsl:template name="nav">
    <div id="nav">
      <h1>Les nuances de <span class="author">Littré</span></h1>
      <p> </p>
      <xsl:call-template name="tree"/>
    </div>
    <!--
      <div class="tete">
        <div class="tabs">
          <a href="#toc" onclick="return onglet(this)" id="onglet_onload" class="actif">Thèmes</a>
          <a href="#index" onclick="return onglet(this)" >Index</a>
          <xsl:text>&#160;</xsl:text>
        </div>
      </div>
      <div class="corps">
        <xsl:call-template name="tree"/>
      </div>
    </div>
    -->
          <!-- difficile à placer à droite dans firefox -->
          <!-- div id="alphabet">
            <xsl:call-template name="alphabet"/>
            </div -->
        <!--
        <div id="tree" >
          <p>&#160;</p>
        </div>
        <div id="index" style="display:none">
          <xsl:call-template name="index"/>
          <p>&#160;</p>
        </div>
        -->
  </xsl:template>

  <xsl:template name="alphabet">
    <xsl:param name="alphabet" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:variable name="lettre" select="substring($alphabet, 1, 1)"/>
    <xsl:if test="normalize-space($lettre) != ''">
      <xsl:variable name="count" select="count(key('lettre', $lettre))"/>
      <xsl:if test="$count &gt; 0">
        <a href="#_{$lettre}">
          <xsl:value-of select="$lettre"/>
          <xsl:text> </xsl:text>
          <small title="Nombre de mots">
            <xsl:text>(</xsl:text>
            <xsl:value-of select="$count"/>
            <xsl:text>)</xsl:text>
          </small>
        </a>
      </xsl:if>
      <!-- passer à la lettre suivante -->
      <xsl:call-template name="alphabet">
        <xsl:with-param name="alphabet" select="substring($alphabet, 2)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="index">
    <xsl:param name="alphabet" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:variable name="lettre" select="substring($alphabet, 1, 1)"/>
    <xsl:if test="$lettre = 'A'">
      <!-- TODO liens lettres -->
    </xsl:if>
    <xsl:if test="normalize-space($lettre) != ''">
      <xsl:if test="key('lettre', $lettre)">
        <a name="_{$lettre}">
        <xsl:comment>&#160;</xsl:comment>
        </a>
        <h6>
          <xsl:value-of select="$lettre"/>
          <xsl:text> </xsl:text>
          <small title="Nombre de mots">
            <xsl:text>(</xsl:text>
            <xsl:value-of select="count(key('lettre', $lettre))"/>
            <xsl:text>)</xsl:text>
          </small>
        </h6>
        <xsl:for-each select="key('lettre', $lettre)">
          <xsl:sort select="."/>
          <!-- si c'est le premier de la liste -->
          <xsl:choose>
            <xsl:when test="count(. | key('mot', normalize-space(.))[1] ) = 1">
              <!-- pas de saut de ligne au début -->
              <xsl:if test="position() != 1">
                <xsl:text>.
</xsl:text>
                <br/>
              </xsl:if>
              <xsl:value-of select="translate(.,$maj,$min)"/>
              <xsl:text> : </xsl:text>
            </xsl:when>
            <xsl:otherwise>, </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates select="ancestor::tei:entry[1]" mode="lien"/>
          <!-- un point à la fin -->
          <xsl:if test="position() = last()">.</xsl:if>
        </xsl:for-each>
      </xsl:if>
      <!-- passer à la lettre suivante -->
      <xsl:call-template name="index">
        <xsl:with-param name="alphabet" select="substring($alphabet, 2)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <xsl:template name="tree">
    <ul class="tree">
      <xsl:apply-templates select="/tei:TEI/tei:text/tei:body" mode="tree"/>
    </ul>
  </xsl:template>
  <xsl:template match="*" mode="tree">
    <xsl:apply-templates mode="tree"/>
  </xsl:template>
  <xsl:template match="tei:epigraph" mode="tree"/>
  <xsl:template match="tei:div" mode="tree">
    <li class="plus">
      <xsl:apply-templates select="tei:head" mode="tree"/>
      <xsl:if test="tei:entry">
        <ul class="entry">
          <xsl:apply-templates select="tei:entry" mode="tree"/>
        </ul>
      </xsl:if>
      <xsl:if test="tei:div">
        <ul>
          <xsl:apply-templates select="tei:div" mode="tree"/>
        </ul>
      </xsl:if>
    </li>
  </xsl:template>

  <xsl:template match="tei:entry" mode="tree">
    <li>
      <a>
        <xsl:attribute name="href">
          <xsl:text>#</xsl:text>
          <xsl:apply-templates select="." mode="id"/>
        </xsl:attribute>
        <xsl:apply-templates select="." mode="number"/>
        <xsl:text>. </xsl:text>
        <xsl:for-each select="tei:form/tei:orth">
          <xsl:if test="position() != 1">, </xsl:if>
          <xsl:value-of select="translate(., $maj, $min)"/>
        </xsl:for-each>
      </a>
      <xsl:text>.</xsl:text>
    </li>
  </xsl:template>


  <xsl:template match="tei:head" mode="tree">
      <xsl:variable name="number">
        <xsl:apply-templates select="ancestor::tei:div[1]" mode="number"/>
      </xsl:variable>
      <!--
      <small>
        <xsl:value-of select="$number"/>
        <xsl:text>)</xsl:text>
      </small>
      <xsl:text> </xsl:text>
      -->
      <a href="#{$number}" class="section">
        <xsl:value-of select="."/>
      </a>
      <xsl:text> </xsl:text>
      <small>(<xsl:value-of select="count(ancestor::tei:div[1]//tei:entry)"/>)</small>
  </xsl:template>


  <!-- pour l'instant, pas de préface, on passe tout -->
  <xsl:template match="tei:TEI">
    <xsl:apply-templates select="tei:text"/>
  </xsl:template>

  <xsl:template match="tei:text">
    <xsl:apply-templates select="tei:body"/>
  </xsl:template>


  <xsl:template match="tei:body">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Le sectionnement est calculé pour conversion vers traitement de texte  -->
  <xsl:template match="tei:div">
    <xsl:variable name="id">
      <xsl:apply-templates select="." mode="number"/>
    </xsl:variable>
    <div id="{$id}">
      <xsl:apply-templates select="tei:head | tei:epigraph"/>
      <xsl:if test="tei:entry">
        <div class="cols">
          <xsl:apply-templates select="tei:entry"/>
        </div>
      </xsl:if>
      <xsl:apply-templates select="tei:div"/>
    </div>
  </xsl:template>


  <!-- numéro de section -->
  <xsl:template match="tei:div" mode="number">
    <xsl:number from="tei:TEI/tei:text/tei:body" level="multiple" format="A.1.a"/>
  </xsl:template>


  <!-- en-tête de section -->
  <xsl:template match="tei:epigraph">
    <ul class="epigraph">
      <xsl:apply-templates/>
    </ul>
  </xsl:template>
  <xsl:template match="tei:epigraph/tei:entryFree">
    <li>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <!-- titre de section -->
  <xsl:template match="tei:head">
    <xsl:variable name="niveau" select="count(ancestor::tei:div)"/>
    <xsl:element name="h{$niveau}">
      <xsl:variable name="number">
        <xsl:apply-templates select="ancestor::tei:div[1]" mode="number"/>
      </xsl:variable>
      <!--
      <small>
        <xsl:value-of select="$number"/>
        <xsl:text>)</xsl:text>
      </small>
      <xsl:text> </xsl:text>
      -->
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- persName ? faire quelque chose ? -->
  <xsl:template match="tei:persName">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:entry" mode="number">
    <xsl:number from="tei:TEI/tei:text/tei:body" level="any"/>
  </xsl:template>

  <xsl:template match="tei:entry" mode="lien">
    <a>
      <xsl:attribute name="href">
        <xsl:text>#</xsl:text>
        <xsl:apply-templates select="." mode="id"/>
      </xsl:attribute>
      <xsl:apply-templates select="." mode="number"/>
    </a>
  </xsl:template>

  

  <xsl:template match="tei:entry" mode="id">
    <xsl:apply-templates select="." mode="number"/>
  </xsl:template>


  <xsl:template match="tei:entry/tei:form">
    <small>
      <xsl:apply-templates select=".." mode="number"/>
      <xsl:text>.</xsl:text>
    </small>
    <xsl:text> </xsl:text>
    <xsl:for-each select="tei:orth">
      <xsl:if test="position() != 1">, </xsl:if>
      <strong>
        <xsl:choose>
          <xsl:when test="tei:m">
            <xsl:attribute name="id">
              <xsl:value-of select="translate(tei:m, $maj, $min)"/>
            </xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="id">
              <xsl:value-of select="translate(., $maj, $min)"/>
            </xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates/>
      </strong>
    </xsl:for-each>
    <xsl:text>. </xsl:text>
  </xsl:template>

  <xsl:template match="tei:form">
    <b>
      <xsl:apply-templates/>
    </b>
  </xsl:template>

  <xsl:template match="tei:m">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:entry">
    <p class="entry">
      <xsl:attribute name="id">
        <xsl:apply-templates select="." mode="id"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="tei:dictScrap">
      <xsl:apply-templates/>
  </xsl:template>

  <!-- exemple -->
  <xsl:template match="tei:q">
    <samp>
      <xsl:apply-templates/>
    </samp>
  </xsl:template>

  <!-- -->
  <xsl:template match="tei:q[@type = 'contre']">
    <span class="contre">
      <xsl:text>(</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
    </span>
  </xsl:template>

  <!-- définition -->
  <xsl:template match="tei:gloss | tei:def">
    <dfn>
      <xsl:text>“</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>”</xsl:text>
    </dfn>
  </xsl:template>

  <!-- les notes concernent généralement rappel à l'article, ne seront pas sorties -->
  <xsl:template match="tei:note">

  </xsl:template>

  <xsl:template match="tei:lb">
    <br/>
  </xsl:template>

  <!-- rappels de la vedette -->
  <xsl:template match="tei:oVar">
    <em>
      <xsl:apply-templates/>
    </em>
  </xsl:template>

  <!-- marques
      <xsl:text>‘</xsl:text>
      <xsl:text>’</xsl:text>

  -->
  <xsl:template match="tei:dictScrap//tei:term | tei:term | tei:lang">
    <kbd>
      <xsl:apply-templates/>
    </kbd>
  </xsl:template>


  <!-- étymologie, mot étranger -->
  <xsl:template match="tei:etym | tei:foreign">
    <i>
      <xsl:attribute name="class">
        <xsl:value-of select="local-name(.)"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </i>
  </xsl:template>

  <xsl:template match="tei:name | tei:placeName">
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="local-name(.)"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </span>
  </xsl:template>


  <!-- lien -->
  <xsl:template match="tei:ref">
    <xsl:variable name="cible">
      <xsl:choose>
        <xsl:when test="@cRef">
          <xsl:value-of select="@cRef"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate( . , $maj, $min)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <a>
      <xsl:attribute name="href">
        <xsl:text>#</xsl:text>
        <xsl:apply-templates select="key('orth', translate( $cible , $min, $maj))" mode="id"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </a>
    <!--
    <xsl:text>*</xsl:text>
    <xsl:if test="not(key('mot', translate($cible, $min, $maj)))">
      [lien mort]
    </xsl:if>
    -->
  </xsl:template>


  <!-- citation référencée -->
  <xsl:template match="tei:cit">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- référence bibliographique -->
  <xsl:template match="tei:bibl">
    <cite>
      <xsl:text>(</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
    </cite>
  </xsl:template>

  <!-- titre d'ouvrage -->
  <xsl:template match="tei:title">
    <i>
      <xsl:apply-templates/>
    </i>
  </xsl:template>

  <!-- pagination -->
  <xsl:template match="tei:biblScope">
    <span class="pagination">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- citation inline -->
  <xsl:template match="tei:quote">
    <q>
      <xsl:apply-templates/>
    </q>
  </xsl:template>

  <!-- nom, souvent auteur -->
  <xsl:template match="tei:author">
    <span class="author">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- date (dans une référence biblio) -->
  <xsl:template match="tei:date">
    <span class="date">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <!-- place, dans une adresse bibliographique -->
  <xsl:template match="tei:place">
    <span class="place">
      <xsl:apply-templates/>
    </span>
  </xsl:template>



    <!-- <*> Modèle par défaut d'interception des éléments inconnus

  -->
  <xsl:template match="*">
    <div>
      <font color="red">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>&gt;</xsl:text>
      </font>
      <xsl:apply-templates/>
      <font color="red">
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>&gt;</xsl:text>
      </font>
    </div>
  </xsl:template>


  <!-- un peu de CSS par défaut -->
  <xsl:template name="style">
    <!-- lien css résolu depuis une instruction xsl -->
    <xsl:if test="contains(/processing-instruction('xml-stylesheet'), 'xsl')">
      <link rel="stylesheet" type="text/css">
        <xsl:attribute name="href">
          <xsl:call-template name="pi-lien"/>
          <xsl:text>nuances.css</xsl:text>
        </xsl:attribute>
      </link>
      <script type="text/javascript">
        <xsl:attribute name="src">
          <xsl:call-template name="pi-lien"/>
          <xsl:text>dico.js</xsl:text>
        </xsl:attribute>
        <xsl:text>//</xsl:text>
      </script>
    </xsl:if>
  </xsl:template>


  <!-- résolution de chemin vers une css -->
  <xsl:template name="pi-lien">
    <xsl:param name="pi" select="/processing-instruction('xml-stylesheet')"/>
    <xsl:choose>
      <xsl:when test="contains($pi, 'href=&quot;')">
        <xsl:call-template name="pi-lien">
          <xsl:with-param name="pi" select="substring-after($pi, 'href=&quot;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($pi, '&quot;')">
        <xsl:call-template name="pi-lien">
          <xsl:with-param name="pi" select="substring-before($pi, '&quot;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($pi, '\')">
        <xsl:call-template name="pi-lien">
          <xsl:with-param name="pi" select="translate($pi, '\', '/')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($pi, '/')">
        <xsl:value-of select="substring-before($pi, '/')"/>
        <xsl:text>/</xsl:text>
        <xsl:call-template name="pi-lien">
          <xsl:with-param name="pi" select="substring-after($pi, '/')"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


</xsl:transform>
