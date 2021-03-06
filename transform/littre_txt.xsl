<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
>
  <xsl:output omit-xml-declaration="yes" encoding="UTF-8" method="text"/>
  <!-- Permet l'indentation des éléments de structure -->
  <xsl:strip-space elements="tei:TEI tei:body tei:div tei:docDate tei:front tei:group tei:index tei:listWit tei:teiHeader tei:text"/>
  <xsl:variable name="lf">
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>
  <xsl:variable name="tab">
    <xsl:text>&#9;</xsl:text>
  </xsl:variable>


  <xsl:template match="tei:teiHeader" mode="txt"/>
  <!-- par défaut tout traverser sans laisser de trace de texte -->
  <xsl:template match="tei:TEI | tei:text | tei:entry | tei:form | tei:re[@type='supplement']" mode="txt">
    <xsl:apply-templates select="*" mode="txt"/>
  </xsl:template>

  <!-- séparer les articles à ce niveau pour garder net match="tei:entry" -->
  <xsl:template match="tei:body" mode="txt">
    <xsl:for-each select="*">
      <xsl:text>-------</xsl:text>
      <xsl:value-of select="$lf"/>
      <xsl:value-of select="$lf"/>
      <xsl:apply-templates select="*" mode="txt"/>
      <xsl:value-of select="$lf"/>
      <xsl:value-of select="$lf"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:entry/*" priority="0" mode="txt">
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates mode="txt"/>
  </xsl:template>

  <xsl:template match="tei:form" mode="txt">
    <xsl:apply-templates select="*" mode="txt"/>
  </xsl:template>

  <xsl:template match="tei:dictScrap" mode="txt">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="tei:pron" mode="txt">
    <xsl:text> /</xsl:text>
    <xsl:apply-templates mode="txt"/>
    <xsl:text>/ </xsl:text>
  </xsl:template>

  <xsl:template match="tei:entry/tei:sense" mode="txt">
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:if test="@n">
      <xsl:value-of select="@n"/>
      <xsl:text>. </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="*" mode="txt"/>
  </xsl:template>

  <xsl:template match="tei:sense/tei:sense" mode="txt">
    <xsl:value-of select="$lf"/>
    <xsl:text>   ♦ </xsl:text>
    <xsl:apply-templates select="*" mode="txt"/>
  </xsl:template>

  <xsl:template match="tei:note[@type='H']" mode="txt">
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates select="*" mode="txt"/>
  </xsl:template>

  <xsl:template match="tei:label" mode="txt">
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates mode="txt"/>
  </xsl:template>

  <!-- Utilisé pour sortir les citations modernes -->
  <xsl:template match="tei:cit" mode="txt">
    <xsl:value-of select="$lf"/>
    <xsl:text>– </xsl:text>
    <xsl:value-of select="tei:quote"/>
    <xsl:text>.</xsl:text>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="normalize-space(tei:bibl)"/>
    <xsl:text>) </xsl:text>
  </xsl:template>


</xsl:transform>
