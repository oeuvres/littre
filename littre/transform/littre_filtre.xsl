<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
>
  <xsl:output encoding="UTF-8" method="xml"/>
  <xsl:template match="/">
    <xsl:processing-instruction name="oxygen">RNGSchema="littre.rng" type="xml"</xsl:processing-instruction>
    <xsl:text>
</xsl:text>
    <xsl:processing-instruction name="xml-stylesheet">type="text/xsl" href="../transform/littre_html.xsl"</xsl:processing-instruction>
    <xsl:text>
</xsl:text>
    <xsl:apply-templates select="comment()|*"/>
  </xsl:template>
  <xsl:template match="tei:sense[not(following-sibling::tei:sense)]">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
    <xsl:apply-templates select="../tei:re[@ana='supplement']/tei:sense"/>    
  </xsl:template>
  <xsl:template match="tei:re[@ana='supplement']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="tei:form">
        <xsl:attribute name="orig">
          <xsl:apply-templates select="tei:form"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="node()[local-name() != 'sense'][local-name() != 'form']"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:re[@ana='supplement']/*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="
        (local-name() != 'dictScrap')
    and (local-name() != 'label')
    and (local-name() != 're')
    and not(@type='historique')
      ">
        <xsl:attribute name="ana">supplement</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:re[@ana='supplement']/tei:note[@type='historique']/tei:cit">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="ana">supplement</xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:ref/tei:oVar">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:note[@type='historique']/tei:p">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
</xsl:transform>
