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


  <xsl:template match="tei:teiHeader" mode="text"/>
  <!-- par défaut tout traverser sans laisser de trace de texte -->
  <xsl:template match="tei:TEI | tei:text | tei:entry | tei:form | tei:re[@type='supplement']" mode="text">
    <xsl:apply-templates select="*" mode="text"/>
  </xsl:template>

  <!-- séparer les articles à ce niveau pour garder net match="tei:entry" -->
  <xsl:template match="tei:body" mode="text">
    <xsl:for-each select="*">
      <xsl:text>-------</xsl:text>
      <xsl:value-of select="$lf"/>
      <xsl:value-of select="$lf"/>
      <xsl:apply-templates select="*" mode="text"/>
      <xsl:value-of select="$lf"/>
      <xsl:value-of select="$lf"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:entry/*" priority="0" mode="text">
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates mode="text"/>
  </xsl:template>

  <xsl:template match="tei:form" mode="text">
    <xsl:apply-templates select="*" mode="text"/>
  </xsl:template>

  <xsl:template match="tei:dictScrap" mode="text">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="tei:pron" mode="text">
    <xsl:text> /</xsl:text>
    <xsl:apply-templates mode="text"/>
    <xsl:text>/ </xsl:text>
  </xsl:template>

  <xsl:template match="tei:entry/tei:sense" mode="text">
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:if test="@n">
      <xsl:value-of select="@n"/>
      <xsl:text>. </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="*" mode="text"/>
  </xsl:template>

  <xsl:template match="tei:sense/tei:sense" mode="text">
    <xsl:value-of select="$lf"/>
    <xsl:text>   ♦ </xsl:text>
    <xsl:apply-templates select="*" mode="text"/>
  </xsl:template>

  <xsl:template match="tei:note[@type='H']" mode="text">
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates select="*" mode="text"/>
  </xsl:template>

  <xsl:template match="tei:label" mode="text">
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates mode="text"/>
  </xsl:template>

  <!-- Utilisé pour sortir les citations modernes -->
  <xsl:template match="tei:cit" mode="text">
    <xsl:value-of select="$lf"/>
    <xsl:text>– </xsl:text>
    <xsl:value-of select="tei:quote"/>
    <xsl:text>.</xsl:text>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="normalize-space(tei:bibl)"/>
    <xsl:text>) </xsl:text>
  </xsl:template>


</xsl:transform>
