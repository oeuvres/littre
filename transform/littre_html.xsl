<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
>
  <xsl:output omit-xml-declaration="yes" encoding="UTF-8" method="xml"/>

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
    <div>
      <xsl:call-template name="class"/>
      <xsl:apply-templates select="tei:form"/>
      <xsl:choose>
        <xsl:when test="tei:sense[2]">
          <ul class="n">
            <xsl:for-each select="tei:sense">
              <li class="sense1">
                <xsl:call-template name="sense1"/>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:when>
        <xsl:when test="tei:sense">
          <xsl:for-each select="tei:sense">
            <div class="sense1">
              <xsl:call-template name="sense1"/>
            </div>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="tei:note[not(@type='plan')] | tei:re | tei:etym"/>      
    </div>
  </xsl:template>
  <!-- blocs génériques -->
  <xsl:template match="tei:note | tei:re ">
    <div>
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
      <ul class="◊">
        <xsl:apply-templates select="tei:sense"/>
      </ul>
    </xsl:if>
    <xsl:apply-templates select="tei:re | tei:q | tei:xr"/>
  </xsl:template>
  <!-- Sens (niv 2) 

  -->
  <xsl:template match="tei:sense/tei:sense">
    <li class="sense2">
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  <!-- Rappel de la vedette -->
  <xsl:template match="tei:oVar">
    <i class="oVar">
      <xsl:apply-templates/>
    </i>
  </xsl:template>
  <!-- texte génériques -->
  <xsl:template match="tei:biblScope | tei:gram | tei:quote | tei:quote/tei:note">
    <xsl:if test="normalize-space(.)">
      <span>
        <xsl:call-template name="class"/>
        <xsl:apply-templates/>
      </span>
    </xsl:if>
  </xsl:template>
  <xsl:template match="tei:cit/tei:quote">
    <div class="quote">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <!-- référence biblio -->
  <xsl:template match="tei:author">
    <span class="author">
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
  <xsl:template match="tei:etym">
    <p>
      <xsl:call-template name="class"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  <xsl:template match="tei:dictScrap">
    <p>
      <xsl:call-template name="class"/>
      <!-- position() ne marche pas fort avec Xalan -->
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
  </xsl:template>
  <!-- Entête étymologique -->
  <xsl:template match="tei:form">
    <p class="form">
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
    <span class="note">
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
    <p>
      <tt>Étymologie</tt>
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
    <span class="xr">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="tei:note[starts-with(@type, 'HIST')]">
    <div class="HIST">
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
