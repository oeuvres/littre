<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
>
  <xsl:output omit-xml-declaration="yes" encoding="UTF-8" method="xml"/>

  <!-- coupé -->
  <xsl:template match="tei:teiHeader">
    <link rel="stylesheet" type="text/css" href="../theme/littre.css"/>
  </xsl:template>
  <!-- traversé -->
  <xsl:template match="tei:TEI | tei:text | tei:body | tei:note/tei:p">
    <xsl:apply-templates select="*"/>
  </xsl:template>
  <!-- blocs génériques -->
  <xsl:template match="tei:entry | tei:sense | tei:note | tei:re ">
    <div>
      <xsl:call-template name="class"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <!-- Sens (niv 1) -->
  <xsl:template match="tei:sense">
    <div class="sense1">
      <xsl:if test="@n">
        <b>
          <xsl:value-of select="@n"/>
          <xsl:text>.</xsl:text>
        </b>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <!-- Sens (niv 2) -->
  <xsl:template match="tei:sense/tei:sense">
    <div class="sense2">
      <b>♦</b>
      <xsl:text> </xsl:text>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <!-- Rappel de la vedette -->
  <xsl:template match="tei:oVar">
    <i class="oVar">
      <xsl:apply-templates/>
    </i>
  </xsl:template>
  <!-- texte génériques -->
  <xsl:template match="tei:author | tei:oVar | tei:biblScope | tei:gram | tei:quote | tei:quote/tei:note">
    <span>
      <xsl:call-template name="class"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <!-- référence biblio -->
  <xsl:template match="tei:bibl">
    <xsl:text> </xsl:text>
    <small class="bibl">(<xsl:apply-templates/>)</small>
  </xsl:template>
  <xsl:template match="tei:pron">
    <tt>(<xsl:apply-templates/>)</tt>
  </xsl:template>
  <!-- paragraphe générique -->
  <xsl:template match="tei:form | tei:etym | tei:dictScrap">
    <p>
      <xsl:call-template name="class"/>
      <xsl:apply-templates/>
    </p>      
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
          <xsl:value-of select="@type"/>
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
