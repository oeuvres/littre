<?xml version="1.0" encoding="UTF-8"?>
<!-- 
Génération de graphes, notamment pour CCVisu
http://www.sosy-lab.org/~dbeyer/CCVisu/
-->
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
>
  <xsl:output method="text" encoding="UTF-8"/>
  <!-- Permet l'indentation des éléments de structure -->
  <xsl:strip-space elements="tei:TEI tei:body tei:div tei:docDate tei:front tei:group tei:index tei:listWit tei:teiHeader tei:text"/>
  <xsl:variable name="lf">
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>
  <xsl:template match="/">
    <graph>
     <xsl:apply-templates/>
    </graph>
  </xsl:template>
  <xsl:template match="*">
    <xsl:apply-templates select="*"/>
  </xsl:template>
  <xsl:template match="tei:front"/>
  <!-- Relations entre les vedettes des articles. -->
  <xsl:template match="tei:entry">
    <xsl:for-each select="tei:form/tei:orth[@ana][@type]">
      <xsl:variable name="src" select="@ana"/>
      <xsl:for-each select="following-sibling::tei:orth[@ana][@type]">
        <xsl:value-of select="@type"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$src"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@ana"/>
        <xsl:value-of select="$lf"/>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

    <!--
      graphe des corrélats, résultat peu probant, cf https://javacrim.svn.sourceforge.net/svnroot/javacrim/littre/nuances/nuances_ref.svg
    <xsl:for-each select="tei:dictScrap//tei:ref">
      <xsl:variable name="cRef" select="@cRef"/>
      <xsl:variable name="count" select="count(key('ref', @cRef))"/>
      <xsl:if test="true()"> 
        <xsl:variable name="dest" select="@cRef"/>
        <xsl:if test="$src != $dest">
          <xsl:value-of select="$lf"/>
          <xsl:text>R </xsl:text>
          <xsl:value-of select="$src"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$dest"/>
        </xsl:if>
        <xsl:for-each select="key('orth', @cRef)[1]">
          <xsl:variable name="dest" select="translate(ancestor::tei:entry/@xml:id, '-0123456789', '–')"/>
          <xsl:if test="$src != $dest">
            <xsl:value-of select="$lf"/>
            <xsl:text>R </xsl:text>
            <xsl:value-of select="$src"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$dest"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
      </xsl:for-each>
    -->

</xsl:transform>
