<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:alix="xalan://fr.crim.lucene.alix.AliXSL"
  >

  <xsl:template match="/tei:TEI">


    <xsl:apply-templates select="//tei:entry">
      <xsl:with-param name="fileid" select="@xml:id" />
    </xsl:apply-templates>
    
  </xsl:template>

  <xsl:template match="tei:entry">
    <xsl:param name="fileid" />


    <xsl:value-of select="alix:newDocument('id')"/>

    
    <xsl:value-of select="alix:addField('fileid',$fileid,'IS')"/>
    <xsl:value-of select="alix:addField('id',@xml:id,'IS')" />
    <xsl:value-of select="alix:addXMLField('xml',.,'S')" />
    <xsl:apply-templates select="tei:form/tei:orth"/>
    <xsl:apply-templates select="tei:form/tei:pron"/>

    <xsl:value-of select="alix:writeDocument()" />
  </xsl:template>

  <xsl:template match="tei:orth|tei:pron">
    <xsl:value-of select="alix:addField(name(),.,'IS')"/>
  </xsl:template>

  
</xsl:stylesheet>