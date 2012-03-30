<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 Ne pas supprimer <xsl:text></xsl:text>
Contournement d'un Bug Xalan à la recopie des attributs 
-->
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xalan="http://xml.apache.org/xalan"
  exclude-result-prefixes="tei"
  extension-element-prefixes="xalan"
>
  <xsl:output omit-xml-declaration="yes" encoding="UTF-8" method="xml" indent="yes"/>
  <xsl:variable name="lf">
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>
  <!-- racine -->
  <xsl:template match="tei:TEI">
    <html>
      <head>
        <title>Littré</title>
        <link rel="stylesheet" type="text/css" href="../theme/littre.css"/>
      </head>
      <body>
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>
  
  <!-- traversé -->
  <xsl:template match="tei:text | tei:note/tei:p">
    <xsl:apply-templates select="*"/>
  </xsl:template>
  <xsl:template match="tei:body">
    <xsl:for-each select="*">
      <xsl:apply-templates select="."/>
      <hr/>
    </xsl:for-each>
  </xsl:template>
  <!-- arrêté -->
  <xsl:template match="tei:teiHeader"/>
  <!-- Article -->
  <xsl:template match="tei:entry | tei:entryFree">
    <div id="{@xml:id}" class="entry"><xsl:text></xsl:text>
      <xsl:apply-templates select="tei:form"/>
      <xsl:choose>
        <xsl:when test="tei:sense[2]">
          <ul class="n"><xsl:text></xsl:text>
            <xsl:for-each select="tei:sense">
              <xsl:value-of select="$lf"/>
              <li class="sense1"><xsl:text></xsl:text>
                <xsl:call-template name="sense1"/>
                <xsl:value-of select="$lf"/>
              </li>
            </xsl:for-each>
            <xsl:value-of select="$lf"/>
          </ul>
        </xsl:when>
        <xsl:when test="tei:sense">
          <xsl:for-each select="tei:sense">
            <xsl:value-of select="$lf"/>
            <div class="sense1"><xsl:text></xsl:text>
              <xsl:call-template name="sense1"/>
              <xsl:value-of select="$lf"/>
            </div>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="tei:note[not(@type='plan')] | tei:re | tei:etym"/>      
    <xsl:value-of select="$lf"/>
    </div>
  </xsl:template>
  <!-- blocs génériques -->
  <xsl:template match="tei:note | tei:re ">
    <xsl:value-of select="$lf"/>
    <div><xsl:text></xsl:text>
      <xsl:call-template name="class"/>
      
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <!-- Sens (niv 1) -->
  <xsl:template match="tei:sense" name="sense1">
    <!--
    <xsl:if test="@n">
      <b>
        <xsl:value-of select="@n"/>
        <xsl:text>.</xsl:text>
      </b>
      <xsl:text> </xsl:text>
    </xsl:if>
    -->
    <xsl:apply-templates select="tei:dictScrap | tei:cit"/>
    <xsl:if test="tei:sense">
      <xsl:value-of select="$lf"/>
      <ul class="◊"><xsl:text></xsl:text>
        <xsl:apply-templates select="tei:sense"/>
      </ul>
    </xsl:if>
    <xsl:apply-templates select="tei:re | tei:q | tei:xr"/>
  </xsl:template>
  <!-- Sens (niv 2) 

  -->
  <xsl:template match="tei:sense/tei:sense">
    <xsl:value-of select="$lf"/>
    <li class="sense2"><xsl:text></xsl:text>
      <xsl:apply-templates/>
      <xsl:value-of select="$lf"/>
    </li>
  </xsl:template>
  <!-- Rappel de la vedette -->
  <xsl:template match="tei:oVar">
    <i class="oVar"><xsl:text></xsl:text>
      <xsl:apply-templates/>
    </i>
  </xsl:template>
  <!-- texte génériques -->
  <xsl:template match="tei:biblScope | tei:gram | tei:quote | tei:quote/tei:note">
    <xsl:if test="normalize-space(.) != ''">
      <span class="{local-name()}">
        <xsl:text></xsl:text>
        <xsl:apply-templates/>
      </span>
    </xsl:if>
  </xsl:template>
  <xsl:template match="tei:cit/tei:quote">
    <div class="quote"><xsl:text></xsl:text>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <!-- référence biblio -->
  <xsl:template match="tei:author">
    <span class="author"><xsl:text></xsl:text>
      <xsl:apply-templates/>
    </span>
    <xsl:text>, </xsl:text>
  </xsl:template>
  <xsl:template match="tei:bibl">
    <small class="bibl">
      <xsl:text>— </xsl:text>
      <xsl:apply-templates select="*"/>
    </small>
  </xsl:template>
  <xsl:template match="tei:pron">
    <tt class="pron">(<xsl:apply-templates/>)</tt>
  </xsl:template>
  <!-- paragraphe générique -->
  <xsl:template match="tei:dictScrap">
    <xsl:value-of select="$lf"/>
    <p class="dictScrap">
      <xsl:text></xsl:text>
      <!-- position() ne marche pas fort -->
      <xsl:variable name="pos">
        <xsl:number count="tei:dictScrap"/>
      </xsl:variable>
      <xsl:if test="$pos =1">
        <xsl:choose>
          <xsl:when test="../@n">
            <b class="n">
              <xsl:value-of select="../@n"/>
              <xsl:text>.</xsl:text>
            </b>
            <xsl:text> </xsl:text>
          </xsl:when>
          <xsl:when test="local-name(../..)='sense'">
            <b class="◊">◊</b>
            <xsl:text> </xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
      <xsl:apply-templates/>
    </p>
    <xsl:value-of select="$lf"/>
  </xsl:template>
  <!-- Entête étymologique -->
  <xsl:template match="tei:form">
    <xsl:value-of select="$lf"/>
    <p class="form"><xsl:text></xsl:text>
      <xsl:for-each select="*[text()]">
        <xsl:apply-templates select="."/>
        <xsl:choose>
          <xsl:when test="position() = last()"/>
          <xsl:otherwise>, </xsl:otherwise>
        </xsl:choose>        
      </xsl:for-each>
    </p>      
  </xsl:template>
  <xsl:template match="tei:form/tei:note">
    <span class="note"><xsl:text></xsl:text>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="tei:re/tei:form">
    <strong>
      <xsl:apply-templates/>
    </strong>
  </xsl:template>
  <!-- -->
  <xsl:template match="tei:etym">
    <xsl:value-of select="$lf"/>
    <p class="etym"><xsl:text></xsl:text>
      <b class="label">Étymologie</b>
      <xsl:text> – </xsl:text>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  <!-- Calcul d'une classe CSS -->
  <xsl:template name="class">
    <xsl:attribute name="class">
      <xsl:choose>
        <xsl:when test="@type">
          <xsl:value-of select="translate(@type, '.', '')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="local-name()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  <!-- vedette -->
  <xsl:template match="tei:orth">
    <strong>
      <xsl:apply-templates/>
    </strong>
  </xsl:template>
  <!-- Lien -->
  <xsl:template match="tei:ref">
    <a>
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  <xsl:template match="tei:xr">
    <span class="xr"><xsl:text></xsl:text>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="tei:note[starts-with(@type, 'HIST')]">
    <xsl:value-of select="$lf"/>
    <div class="HIST"><xsl:text></xsl:text>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <!-- siècle dans la section historique -->
  <xsl:template match="tei:label">
    <label>
      <xsl:apply-templates/>
    </label>
  </xsl:template>
  <!-- exemple en italique -->
  <xsl:template match="tei:q">
    <q>
      <xsl:apply-templates/>
    </q>
  </xsl:template>
  <!-- définition -->
  <xsl:template match="tei:dfn">
    <dfn>
      <xsl:apply-templates/>
    </dfn>
  </xsl:template>
  <!-- Citation -->
  <xsl:template match="tei:cit">
    <blockquote>
      <xsl:apply-templates/>
    </blockquote>
  </xsl:template>
  
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


</xsl:transform>
