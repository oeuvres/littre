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

  <!-- par défaut tout traverser sans laisser de trace de texte -->
  <xsl:template match="*">
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <!-- Utilisé pour sortir les citations modernes -->
  <!--
  <xsl:template match="tei:sense/tei:cit/tei:quote">
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="."/>
    <xsl:text>.</xsl:text>
  </xsl:template>
  -->

  <xsl:template match="tei:sense/tei:dictScrap">
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="."/>
  </xsl:template>

</xsl:transform>
