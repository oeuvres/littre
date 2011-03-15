<?xml version="1.0" encoding="UTF-8"?>
<!--
Littré, nuances
-->
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="tei"
>
  <xsl:output  indent="no" method="xml" encoding="UTF-8"/>
  <xsl:param name="css">../transform/nuances.css</xsl:param>
   <!-- Pour conversion minuscule -->
  <xsl:variable name="Â">ABCDEFGHIJKLMNOPQRSTUVWXYZÂÄÀÆÇÉÈÊËÎÏÖÔŒÙÛÜ-</xsl:variable>
  <!-- garder les minuscules accentuées dans l'identifiant pour éviter doublons sur les adjectifs de participe passé -->
  <xsl:variable name="â">abcdefghijklmnopqrstuvwxyzâäàæçéèêëîïöôœùûü–</xsl:variable>
  <!-- Clé pour retrouver l'entrée -->
  <xsl:key name="orth" match="tei:orth[not(tei:m)] | tei:m[not(@ana)] | tei:m/@ana" use="translate(.,  $Â, $â)"/>
  <xsl:key name="lettre" match="tei:orth[not(tei:m)] | tei:m[not(@ana)] | tei:m/@ana" use="substring(., 1, 1)"/>
  <!-- uri de base pour joindre un article du littré -->
  <xsl:variable name="littre-href">http://artflx.uchicago.edu/cgi-bin/dicos/pubdico1look.pl?dicoid=LITTRE1872&amp;strippedhw=</xsl:variable>  

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
  padding-left:16px;
}
li li a.section {
  padding-left:32px;
}
li li li a.section {
  padding-left:48px;
}
li li li li a.section {
  padding-left:64px;
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
  
  <xsl:template name="chemin">
    <xsl:for-each select="ancestor-or-self::tei:div">
      <xsl:if test="position() != 1"> » </xsl:if>
      <xsl:call-template name="a"/>
      <xsl:text> </xsl:text>
      <small>(<xsl:value-of select="count(.//tei:entry)"/>)</small>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="index">
    <xsl:param name="alphabet" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:variable name="lettre" select="substring($alphabet, 1, 1)"/>
    <xsl:if test="$lettre = 'A'">
      <!-- TODO liens lettres -->
    </xsl:if>
    <xsl:if test="normalize-space($lettre) != ''">
      <xsl:if test="key('lettre', $lettre)">
        <h2 id="_{$lettre}">
          <xsl:value-of select="$lettre"/>
          <!-- ?
          <xsl:text> </xsl:text>
          <small title="Nombre de mots">
            <xsl:text>(</xsl:text>
            <xsl:value-of select="count(key('lettre', $lettre))"/>
            <xsl:text>)</xsl:text>
          </small>
          -->
        </h2>
        <p class="lettre">
          <xsl:for-each select="key('lettre', $lettre)">
            <xsl:sort select="."/>
            
            <!--
            <xsl:choose>
              <xsl:when test="count(. | key('mot', normalize-space(.))[1] ) = 1">
                <xsl:if test="position() != 1">
                  <xsl:text>.
  </xsl:text>
                  <br/>
                </xsl:if>
                <xsl:value-of select="translate(.,$Â,$â)"/>
                <xsl:text> : </xsl:text>
              </xsl:when>
              <xsl:otherwise>, </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="a"/>
            <xsl:if test="position() = last()">.</xsl:if>
            -->
            <xsl:call-template name="a"/>
            <xsl:choose>
              <xsl:when test="position()=last()">.</xsl:when>
              <xsl:otherwise>, </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </p>
      </xsl:if>
      <!-- passer à la lettre suivante -->
      <xsl:call-template name="index">
        <xsl:with-param name="alphabet" select="substring($alphabet, 2)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="matieres">
    <xsl:apply-templates select="/tei:TEI/tei:text/tei:body" mode="matieres"/>
  </xsl:template>
  <xsl:template match="tei:div" mode="matieres">
    <xsl:if test="tei:entry">
      <h2>
        <xsl:call-template name="chemin"/>
      </h2>
      <p>
        <xsl:for-each select="tei:entry">
            <!--
            <xsl:attribute name="href">
              <xsl:call-template name="href"/>
              <xsl:text>#</xsl:text>
              <xsl:call-template name="number"/>
            </xsl:attribute>
            -->
            <xsl:for-each select="tei:form/tei:orth">
              <xsl:choose>
                <xsl:when test="position()=1">
                  <xsl:value-of select="substring(., 1, 1)"/>
                  <xsl:value-of select="translate(substring(., 2), $Â, $â)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>, </xsl:text>
                  <xsl:value-of select="translate(., $Â, $â)"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          <xsl:text>. </xsl:text>
        </xsl:for-each>
      </p>
    </xsl:if>
    <xsl:apply-templates select="tei:div" mode="matieres"/>
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
          <xsl:call-template name="number"/>
        </xsl:attribute>
        <xsl:call-template name="number"/>
        <xsl:text>. </xsl:text>
        <xsl:for-each select="tei:form/tei:orth">
          <xsl:if test="position() != 1">, </xsl:if>
          <xsl:value-of select="translate(., $Â, $â)"/>
        </xsl:for-each>
      </a>
      <xsl:text>.</xsl:text>
    </li>
  </xsl:template>


  <xsl:template match="tei:head" mode="tree">
      <xsl:variable name="number">
        <xsl:call-template name="number"/>
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

  <xsl:template match="tei:text | tei:front">
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <xsl:template match="tei:byline | tei:titlePart">
    <div class="{local-name()}">
      <xsl:apply-templates/>
    </div>
  </xsl:template>


  <xsl:template match="tei:body">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:front//tei:div">
    <xsl:apply-templates/>
  </xsl:template>


  <!-- Le sectionnement est calculé pour conversion vers traitement de texte  -->
  <xsl:template match="tei:body//tei:div">
    <xsl:variable name="id">
      <xsl:call-template name="number"/>
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
  <xsl:template name="number">
    <xsl:choose>
      <xsl:when test="ancestor-or-self::tei:entry">
        <xsl:number from="tei:TEI/tei:text/tei:body" level="any" count="tei:entry"/>
      </xsl:when>
      <xsl:when test="ancestor-or-self::tei:div">
        <xsl:number from="tei:TEI/tei:text/tei:body" level="multiple" count="tei:div" format="A-1-a"/>
      </xsl:when>
      <xsl:otherwise>ERROR</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- en-tête de section -->
  <xsl:template match="tei:epigraph">
    <ul class="epigraph">
      <xsl:apply-templates/>
    </ul>
  </xsl:template>
  <xsl:template match="tei:list">
    <ul>
      <xsl:apply-templates/>
    </ul>
  </xsl:template>
  <xsl:template match="tei:item">
    <li>
      <xsl:apply-templates/>
    </li>
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
        <xsl:call-template name="number"/>
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


  <!-- fichier de destination -->
  <xsl:template name="href"/>
  <xsl:template name="a">
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="href"/>
        <xsl:text>#</xsl:text>
        <xsl:call-template name="number"/>
      </xsl:attribute>
      <!-- 
      <xsl:call-template name="number"/>
      -->
      <xsl:choose>
        <xsl:when test="tei:head">
          <xsl:value-of select="normalize-space(tei:head)"/>
        </xsl:when>
        <xsl:when test="ancestor-or-self::tei:form">
          <xsl:value-of select="translate(., $Â, $â)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

  
  <xsl:template match="tei:p">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>


  <xsl:template match="tei:entry/tei:form">
    <xsl:if test="ancestor::tei:body">
      <small>
        <xsl:call-template name="number"/>
        <xsl:text>.</xsl:text>
      </small>
      <xsl:text> </xsl:text>
    </xsl:if>
    <!-- 
    <xsl:choose>
      <xsl:when test="tei:m">
        <xsl:attribute name="id">
          <xsl:value-of select="translate(tei:m, $Â, $â)"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="id">
          <xsl:value-of select="translate(., $Â, $â)"/>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
    -->
    <xsl:for-each select="tei:orth">
      <xsl:choose>
        <xsl:when test="position() != 1">
          <xsl:text>, </xsl:text>
          <strong class="orth">
            <xsl:apply-templates/>
          </strong>
        </xsl:when>
        <xsl:otherwise>
          <a class="orth" href="{$littre-href}{translate(ancestor::tei:entry/@xml:id, '01234567890', '')}">
            <xsl:apply-templates/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <xsl:text>. </xsl:text>
  </xsl:template>

  <xsl:template match="tei:form">
    <span class="form">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:m">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:entry">
    <p class="entry">
      <xsl:attribute name="id">
        <xsl:call-template name="number"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="tei:dictScrap">
      <xsl:apply-templates/>
  </xsl:template>

  <!-- exemple -->
  <xsl:template match="tei:q">
    <cite>
      <xsl:apply-templates/>
    </cite>
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
    <xsl:text>“</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>”</xsl:text>
  </xsl:template>

  <!-- les notes concernent généralement rappel à l'article, ne seront pas sorties -->
  <xsl:template match="tei:entry//tei:note">

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
    <abbr>
      <xsl:apply-templates/>
    </abbr>
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
    <a>
      <xsl:choose>
        <xsl:when test="starts-with(@target, 'mailto:')">
          <xsl:attribute name="onclick">
            <xsl:text>this.href='mailto'+'\x3A'+'</xsl:text>
            <xsl:value-of select="substring-before(substring-after(@target,'mailto:'),'@')"/>
            <xsl:text>'+'\x40'+'</xsl:text>
            <xsl:value-of select="substring-after(@target,'@')"/>
            <xsl:text>'</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="href">#</xsl:attribute>
        </xsl:when>
        <xsl:when test="@target">
          <xsl:attribute name="href">
            <xsl:value-of select="@target"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="@cRef">
          <xsl:variable name="cible">
            <xsl:choose>
              <xsl:when test="@cRef">
                <xsl:value-of select="@cRef"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="translate( . , $Â, $â)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="href">
            <xsl:for-each select="key('orth', $cible)[1]">
              <xsl:call-template name="href"/>
               <xsl:text>#</xsl:text>
              <xsl:call-template name="number"/>
            </xsl:for-each>
          </xsl:attribute>
        </xsl:when>
      </xsl:choose>
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
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <!-- référence bibliographique -->
  <xsl:template match="tei:bibl">
    <cite>
      <xsl:apply-templates/>
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
  <xsl:template match="tei:entry//tei:quote">
    <cite>
      <xsl:apply-templates/>
    </cite>
  </xsl:template>
  <xsl:template match="tei:quote">
    <blockquote>
      <xsl:apply-templates/>
    </blockquote>
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
