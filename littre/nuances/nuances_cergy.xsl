<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="tei"
>
  <xsl:import href="nuances_html.xsl"/>
  <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
  <xsl:param name="dir">littre-nuances/</xsl:param>
  <xsl:template match="/">
    <xsl:call-template name="html">
      <xsl:with-param name="href">matieres.html</xsl:with-param>
      <xsl:with-param name="html">
        <table class="header" width="100%">
          <tr>
            <td class="ariane">
              <a href="index.html">Les nuances de Littré</a>
            </td>
            <td align="right"><a href="nomenclature.html">Index</a></td>
          </tr>
        </table>
        <h1>
          <img src="http://www.u-cergy.fr/dictionnaires/images/carre_histoire.gif" width="25" height="25" alt="·"/>
          <xsl:text> Matières</xsl:text>
        </h1>
        <xsl:call-template name="matieres"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:apply-templates/>
    <xsl:call-template name="html">
      <xsl:with-param name="href">nomenclature.html</xsl:with-param>
      <xsl:with-param name="html">
        <table class="header" width="100%">
          <tr>
            <td class="ariane">
              <a href="index.html">Les nuances de Littré</a>
            </td>
            <td align="right"><a href="nomenclature.html">Index</a> | <a href="matieres.html">Matières</a></td>
          </tr>
        </table>
        <h1>
          <img src="http://www.u-cergy.fr/dictionnaires/images/carre_histoire.gif" width="25" height="25" alt="·"/>
          <xsl:text> Index</xsl:text>
        </h1>
        <xsl:call-template name="index"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:front">
    <xsl:call-template name="html">
      <xsl:with-param name="href">index.html</xsl:with-param>
      <xsl:with-param name="html">
        <table class="header" width="100%">
          <tr>
            <td class="ariane">
              <a href="index.html">Un dictionnaire à lire</a>
            </td>
            <td align="right">
              <a href="nomenclature.html">Index</a>
              <xsl:text> | </xsl:text>
              <a href="matieres.html">Matières</a>
              <xsl:text> | </xsl:text>
              <xsl:for-each select="../tei:body/tei:div[1]">
                <xsl:call-template name="a"/>
              </xsl:for-each>
              <xsl:text> »</xsl:text>
            </td>
          </tr>
        </table>
        <xsl:apply-templates/>
        <xsl:for-each select="../tei:body">
          <xsl:call-template name="nav-pied"/>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template name="href">
    <xsl:for-each select="ancestor-or-self::tei:div[1]">
      <xsl:call-template name="number"/>
    </xsl:for-each>
    <xsl:text>.html</xsl:text>
  </xsl:template>
  <xsl:template name="html">
    <xsl:param name="href">
      <xsl:call-template name="href"/>
    </xsl:param>
    <xsl:param name="html"/>
    <xsl:document href="{$dir}{$href}"  encoding="UTF-8" method="xml" indent="yes">
      <html>
        <head>
          <meta http-equiv="Content-type" content="text/html; charset=UTF-8"/>
          <link rel="stylesheet" href="littre-nuances.css"/>
        </head>
        <body>
          <table width="100%">
            <tr>
              <td width="25%" valign="top">
                <xsl:call-template name="nav"/>
              </td>
              <td valign="top">
                <xsl:copy-of select="$html"/>
                <p> </p>
                <p> </p>
              </td>
            </tr>
            <tr>
              <td/>
              <td align="right" class="small" valign="bottom">Édition : <a onclick="this.href='mailto'+'\x3A'+'frederic.glorieux'+'\x40'+'enc.sorbonne.fr'">Frédéric Glorieux</a> (<a href="http://ducange.enc.sorbonne.fr">École nationale des chartes</a>)</td>
            </tr>          
          </table>
        </body>
      </html>
    </xsl:document>
  </xsl:template>
  <!-- Panneau de navigation -->
  <xsl:template name="nav">
    <div id="nav">
      <a href="http://www.u-cergy.fr/dictionnaires/"><img src="http://www.u-cergy.fr/dictionnaires/images/logo.gif" border="0" width="139" height="113" alt="Accueil du musée des dictionnaires"/></a>
      <ul>
        <li>
          <a href="http://www.u-cergy.fr/dictionnaires/accueil.html">
          <img src="http://www.u-cergy.fr/dictionnaires/images/carre_accueil.gif" alt="·" width="15" height="15"/> 
          Présentation du Musée</a>
        </li>
        <li>
          <a href="http://www.u-cergy.fr/dictionnaires/rech_chronologique/mvd._chronologie.html">
          <img src="http://www.u-cergy.fr/dictionnaires/images/carre_histoire.gif" alt="·" width="15" height="15"/> 
          Histoire des Dictionnaires</a>
        </li>
        <li>
          <a href="http://www.u-cergy.fr/dictionnaires/rech_chronologique/mvd._chronologie.html">
          <img src="http://www.u-cergy.fr/dictionnaires/images/carre_chrono.gif" alt="·" width="15" height="15"/> 
          Recherche Chronologique</a>
        </li>
        <li>
          <a href="http://www.u-cergy.fr/dictionnaires/auteurs/accueil_auteur.html">
          <img src="http://www.u-cergy.fr/dictionnaires/images/carre_auteur.gif" alt="·" width="15" height="15"/> 
          Recherche par Auteurs</a>
        </li>
        <li>
          <a href="http://www.u-cergy.fr/dictionnaires/biblio/mvd._bibliographie.html">
          <img src="http://www.u-cergy.fr/dictionnaires/images/carre_biblio.gif" alt="·" width="15" height="15"/> 
          Bibliographie</a>
        </li>
        <li>
          <a href="http://www.u-cergy.fr/dictionnaires/equipe/mvd_equipe.html">
          <img src="http://www.u-cergy.fr/dictionnaires/images/carre_equipe.gif" alt="·" width="15" height="15"/> 
          Équipe éditoriale</a>
        </li>
        <li>
          <a href="http://www.u-cergy.fr/dictionnaires/actualites/actualites.html">
          <img src="http://www.u-cergy.fr/dictionnaires/images/carre_actualite.gif" alt="·" width="15" height="15"/> 
          Actualités</a>
        </li>
      </ul>
      <xsl:comment> Google CSE Search Box Begins </xsl:comment>
      <form id="searchbox_001532429990255103477:tzvjrleiqu8" action="http://www.google.com/search">
        <input type="hidden" name="cx" value="001532429990255103477:tzvjrleiqu8" />
        <input type="hidden" name="cof" value="FORID:0" />
        <div class="small">Chercher sur le Musée</div>        
        <input name="q" type="text" size="16" /><br/>
        <input type="submit" name="sa" value="Chercher" />
      </form>
      <script type="text/javascript" src="http://www.google.com/coop/cse/brand?form=searchbox_001532429990255103477%3Atzvjrleiqu8">//</script>
      <script type="text/javascript" src="http://www.google.com/coop/cse/brand?form=searchbox_001532429990255103477%3Atzvjrleiqu8">//</script>
    </div>
  </xsl:template>
  <!-- Sections dans front -->
  <xsl:template match="tei:front//tei:div">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Section -->
  <xsl:template match="tei:body//tei:div">
    <xsl:variable name="id">
      <xsl:call-template name="number"/>
    </xsl:variable>
    <xsl:call-template name="html">
      <xsl:with-param name="href" select="concat($id, '.html')"/>
      <xsl:with-param name="html">
        <table class="header" width="100%">
          <tr>
            <td class="ariane">
              <a href="index.html">Les nuances de Littré</a>
              <xsl:text> </xsl:text>
              <small>(<xsl:value-of select="count(//tei:entry)"/>)</small>
              <xsl:text> » </xsl:text>
              <xsl:call-template name="chemin"/>
            </td>

            <td align="right">
              <xsl:variable name="prev" select="(preceding::tei:div[1][ancestor::tei:body]|parent::tei:div)[1] "/>
              <xsl:for-each select="$prev">
                <xsl:text>« </xsl:text>
                <xsl:call-template name="a"/>
                <xsl:text> | </xsl:text>
              </xsl:for-each>
              <a href="nomenclature.html">Index</a>
              <xsl:text> | </xsl:text>
              <a href="matieres.html">Matières</a>
              <xsl:variable name="next" select="(tei:div | following::tei:div[1])[1] "/>
              <xsl:for-each select="$next">
                <xsl:text> | </xsl:text>
                <xsl:call-template name="a"/>
                <xsl:text> »</xsl:text>
              </xsl:for-each>
            </td>
          </tr>
        </table>
        <xsl:apply-templates select="tei:head | tei:epigraph"/>
        <xsl:if test="tei:entry">
          <div class="cols">
            <xsl:apply-templates select="tei:entry"/>
          </div>
        </xsl:if>
        <xsl:call-template name="nav-pied"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:apply-templates select="tei:div"/>
  </xsl:template>
  <xsl:template name="nav-pied">
    <xsl:if test="tei:div">
      <center>
        <xsl:for-each select="tei:div">
          <xsl:if test="position() != 1"> | </xsl:if>
          <xsl:call-template name="a"/>
          <xsl:text> </xsl:text>
          <small>(<xsl:value-of select="count(.//tei:entry)"/>)</small>
        </xsl:for-each>
      </center>
    </xsl:if>
  </xsl:template>
  <xsl:template match="tei:head">
    <h1>
      <img src="http://www.u-cergy.fr/dictionnaires/images/carre_histoire.gif" width="25" height="25" alt="·"/>
      <xsl:text> </xsl:text>
      <xsl:apply-templates/>      
    </h1>
  </xsl:template>

</xsl:transform>
