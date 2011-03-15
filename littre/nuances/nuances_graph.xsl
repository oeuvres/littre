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
   <!-- Pour conversion minuscule -->
  <xsl:variable name="Â">ABCDEFGHIJKLMNOPQRSTUVWXYZÂÄÀÆÇÉÈÊËÎÏŒÖÔÙÛÜ-</xsl:variable>
  <xsl:variable name="â">abcdefghijklmnopqrstuvwxyzâäàæçéèêëîïœöôùûü–</xsl:variable>
 <!-- Permet l'indentation des éléments de structure -->
  <xsl:strip-space elements="tei:TEI tei:body tei:div tei:docDate tei:front tei:group tei:index tei:listWit tei:teiHeader tei:text"/>
  <!-- Clé sur une vedette -->
  <xsl:key name="orth" match="tei:orth[not(tei:m)] | tei:m[not(@ana)] | tei:m/@ana" use="translate(.,  $Â, $â)"/>
  <!-- Clé sur un corrélat -->
  <xsl:key name="ref" match="tei:ref" use="@cRef"/>
  <xsl:variable name="lf">
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>
  <xsl:template match="/">
    <dot>
  <xsl:apply-templates/>
    </dot>
  </xsl:template>
  <xsl:template match="*">
    <xsl:apply-templates select="*"/>
  </xsl:template>
  <!-- Relations entre articles -->
  <xsl:template match="tei:entry">
    <xsl:for-each select="tei:form/tei:orth">
      <xsl:variable name="src" select="tei:orth[not(tei:m)] | tei:m[not(@ana)] | tei:m/@ana"/>
      <xsl:for-each select="following-sibling::tei:orth">
        <xsl:variable name="dest" select=""></xsl:variable>
      </xsl:for-each>
    </xsl:for-each>
    <!--
      graphe des corrélats, résultat peu probant
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
  </xsl:template>

</xsl:transform>
