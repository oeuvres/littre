<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
  <xsl:output omit-xml-declaration="yes" encoding="UTF-8" method="text"/>
  <xsl:variable name="ABC">ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÇÉÈÊËÎÏÔÙÛ</xsl:variable>
  <xsl:variable name="abc">abcdefghijklmnopqrstuvwxyzaaceeeeiiouu</xsl:variable>

  <!-- Permet l'indentation des éléments de structure -->
  <xsl:strip-space elements="xmlittre entree corps variante entete rubrique indent entete"/>
  <xsl:variable name="lf">
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>
  <xsl:variable name="tab">
    <xsl:text>&#9;</xsl:text>
  </xsl:variable>

  <xsl:template match="entree">
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="@terme"/>
    <xsl:text>, </xsl:text>
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <xsl:template match="entete">
    <xsl:apply-templates/>
    <xsl:value-of select="$lf"/>
  </xsl:template>

  <xsl:template match="prononciation">
    <xsl:text>/</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>/</xsl:text>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="rubrique">
    <xsl:value-of select="$lf"/>
    <xsl:text>  &lt;</xsl:text>
    <xsl:value-of select="translate(@nom, $ABC, $abc)"/>
    <xsl:text>&gt;</xsl:text>
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <xsl:template match="indent">
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates/>    
  </xsl:template>
  
  <xsl:template match="indent/text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template match="cit">
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates/>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="@aut"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="@ref"/>
    <xsl:text>)</xsl:text>
  </xsl:template>
</xsl:transform>
