<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"

  xmlns:exslt="http://exslt.org/common"
  xmlns:php="http://php.net/xsl"
  extension-element-prefixes="exslt php"
>
  <xsl:import href="littre_html.xsl"/>
  <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
  <xsl:param name="this">littre_sql.xsl</xsl:param>
  <!-- Without root element the process is very long and copy each xmlns on every element -->
  <xsl:template match="/">
    <div>
      <xsl:apply-templates select="/tei:TEI/tei:text/tei:body/tei:entry" mode="sql"/>
    </div>
  </xsl:template>
  <!-- Process doc for column data, tei:form/tei:orth[@type='lemma'] -->
  <xsl:template match="tei:entry" mode="sql">
    <xsl:variable name="html">
      <xsl:apply-templates select="."/>
    </xsl:variable>
    <xsl:variable name="rien" select="php:function('load::entry', string(@xml:id) , exslt:node-set($html))"/>
    <xsl:variable name="text">
      <xsl:apply-templates select="." mode="text"/>
    </xsl:variable>
    
    <!-- Procéder les autres éléments (citations ou gloses) -->
    <xsl:apply-templates mode="sql"/>
  </xsl:template>
  <xsl:template match="tei:orth" mode="sql">
    <xsl:variable name="rien" select="php:function('load::orth', string(@xml:id), string(.)"/>
  </xsl:template>
  <!-- Go throw -->
  <xsl:template match="tei:body | tei:text | tei:sense " mode="sql">
    <xsl:apply-templates select="*" mode="sql"/>
  </xsl:template>
  <!-- Indexarion plein texte -->
  <xsl:template match="tei:cit" mode="sql">
    <xsl:variable name="html">
      <xsl:apply-templates select="."/>
    </xsl:variable>
    <xsl:variable name="text">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:variable>
  </xsl:template>
  <!-- Stop it -->
  <xsl:template match="tei:teiHeader | tei:xr | tei:bibl | tei:num" mode="sql"/>


</xsl:transform>
