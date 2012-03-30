<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:alix="xalan://fr.crim.lucene.alix.AliXSL"
  xmlns:xalan="http://xml.apache.org/xalan"
  exclude-result-prefixes="tei"
  extension-element-prefixes="xalan alix"
  >
  <!-- transformation du littre en html (mode par défaut) -->
  <xsl:import href="littre_html.xsl"/>
  <xsl:output encoding="UTF-8" method="xml" indent="yes" xalan:indent-amount="2"/>
  <xsl:template match="/tei:TEI">
    <report>
      <!-- Le mode alix est un moyen de pouvoir profiter de l'xsl par défaut qui transforme en html -->
      <xsl:apply-templates select="//tei:entry" mode="alix">
        <xsl:with-param name="file" select="@xml:id" />
      </xsl:apply-templates>
    </report>
  </xsl:template>
  <!-- Par défaut, on traverse tout en mode alix -->
  <xsl:template match="*" mode="alix">
  	<xsl:apply-templates mode="alix"/>
  </xsl:template>


  <xsl:template match="tei:entry" mode="alix">
    <xsl:param name="file" />
    <!-- Créer un nouveau document -->
    <xsl:value-of select="alix:newDocument('id')"/>
    <!-- Ajouter des champs -->
    <xsl:value-of select="alix:addField('file',$file,'IS')"/>
    <xsl:value-of select="alix:addField('id',@xml:id,'IS')" />
    <!-- Appliquer la transformation HTML -->
    <xsl:variable name="html"><xsl:apply-templates select="."/></xsl:variable>
    <xsl:value-of select="alix:addXMLField('html',$html,'S')" />
    <xsl:apply-templates select="tei:form" mode="alix"/>
    <!-- Ajouter le document en cours à l'index ? -->
    <xsl:value-of select="alix:addDocument()" />
  </xsl:template>
  

  <xsl:template match="tei:orth" mode="alix">
    <xsl:variable name="value" select="normalize-space(.)"/>
    <xsl:value-of select="alix:addField('orth', $value, 'ITS')" />
    <xsl:value-of select="alix:addField('form', $value, 'ITS')" />
  </xsl:template>

</xsl:transform>
