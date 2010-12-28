<?xml version="1.0" encoding="UTF-8"?>
<!--

Camille Dutrey, XML Littré, Gannaz => TEI
=========================================

Attributs
- - - - -

@ref => @target
@aut => <author> si valeur, sinon rien
@nom => @type
@num => @n dans <sense>
@terme => <orth> dans <form>
@supplement => @type="supplement" (le numéro associé en valeur de @supplement dans le source a-t-il de l'importance ?)
@sens => rien car création de @xml:id (si <entree> a @sens, alors valeur de @xml:id = concat txt de <entree> "." valeur de @sens)
@option => @type in <sense>
@lettre => @xml:id (exemple : @lettre="P" devient @xml:id="lettre_p", dans <TEI> ?)
@nb => ? (pas trouvé dans la source)

Éléments
 - - - -

cit => <cit> si @aut, sinon <quote>
indent => divers : <dictScrap>
					OU <time> (dans <rubrique nom="HISTORIQUE"> qui devient <note type="historique">)
					OU rien (dans <etym>, dans <note type="remarque">)
variante => <sense> (avec @n ou la valeur de @n correspond à la valeur du @num dans le source)
rubrique => cf. détail
entree => <entry>
entete => <form> (qui contiendra <orth>, <pron> et <gram>)
corps => rien
prononciation => <pron> (dans <form>)
nature => <gram> dans <form>
rubrique nom="ÉTYMOLOGIE" => <etym>
rubrique nom="HISTORIQUE" => <note type="historique">
a => <ref> (avec @target, plus création de <xr> autour de ref avec <lbl> pour encadrer "Voy." si présent dans le texte)
rubrique nom="SUPPLÉMENT AU DICTIONNAIRE" => <note type="supplément">
rubrique nom="REMARQUE" => <note type="remarque">
exemple => <dictScrap> (on verra sous-structuration plus tard, comme pour les autres <dictScrap> ?)
rubrique nom="SYNONYME" => <note type="synonyme">
rubrique nom="PROVERBE" => <note type="proverbe">
rubrique nom="PROVERBES" => <note type="proverbe">
résumé => ? (rien ?)
xmlittre => <TEI> ? (avec @xml:id dont la valeur comprend la lettre en cours ?) (soit un <TEI> par lettre avec cette lettre codée en valeur de @xml:id, le tout dans un <teiCorpus> ?)
rubrique nom="REMARQUES" => <note type="remarque"> (plus @n si les <indent> dans <rubrique nom="REMARQUES"> sont directement suivis par un chiffre (exemple : pencher). La valeur de @n ainsi créé correspondra au chiffre qui débute le contenu textuel de <indent>)

-->
<xsl:transform 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="1.1"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
  >
  <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
  <!-- Pour conversion minuscule -->
  <xsl:variable name="Â">ABCDEFGHIJKLMNOPQRSTUVWXYZÂÄÀÆÇÉÈÊËÎÏÖÔÙÛÜ</xsl:variable>
  <!-- garder les minuscules accentuées dans l'identifiant pour éviter doublons sur les adjectifs de participe passé -->
  <xsl:variable name="â">abcdefghijklmnopqrstuvwxyzâäàæçéèêëîïöôùûü</xsl:variable>
  <!-- Une lettre -->
  <xsl:template match="xmlittre">
    <xsl:variable name="lettre" select="translate(@lettre, $Â, $â)"/>
    <TEI>
      <xsl:attribute name="xml:id">
        <xsl:text>littre_</xsl:text>
        <xsl:value-of select="$lettre"/>
      </xsl:attribute>
      <teiHeader>
        <fileDesc>
          <titleStmt>
            <title>Littré, Dictionnaire de la Langue Française</title>
          </titleStmt>
          <publicationStmt>
            <date>2011</date>
            <idno>http://javacrim.svn.sourceforge.net/svnroot/javacrim/littre/xml/<xsl:value-of select="$lettre"/>.xml</idno>
            <publisher>http://javacrim.sourceforge.net/</publisher>
            <availability status="restricted">
              <p>
Licence Creative Commons : <ref target="http://creativecommons.org/licenses/by-sa/2.0/fr/">Paternité – Partage des Conditions Initiales à l'Identique – 2.0 France</ref>
              </p>
              <p>
Cette ressource électronique structurée est protégée en France par le code de la propriété intellectuelle sur les bases de données (L341-1). En adoptant une licence CreativeCommons by-sa, les contributeurs de ce travail souhaitent que la ressource soit librement diffusée, notamment pour la recherche. La clause « Partage des Conditions Initiales à l'Identique » invite les contributeurs futurs à rendre leurs améliorations publiques, par exemple en rejoignant le projet libre <ref target="https://sourceforge.net/projects/javacrim/">Javacrim</ref>.
              </p>
            </availability>
          </publicationStmt>
          <sourceDesc>
            <bibl>Littré, Dictionnaire de la Langue Française</bibl>
          </sourceDesc>
        </fileDesc>
      </teiHeader>
      <text>
        <body>
          <xsl:apply-templates/>
        </body>
      </text>
    </TEI>
  </xsl:template>
  <!-- Un article -->
  <xsl:template match="entree">
    <xsl:variable name="apos">',</xsl:variable>
    <xsl:variable name="vedette" select="translate(normalize-space(translate(@terme, $apos, '-' )), $Â, $â)"/> 
    <entry>
      <!-- identifiant d'article, ascii minuscule, pour ordre alphabétique -->
      <xsl:attribute name="xml:id">
        <xsl:choose>
          <xsl:when test="contains($vedette, ' ')">
            <xsl:value-of select="substring-before($vedette, ' ')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$vedette"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="@sens"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </entry>
  </xsl:template>
  <!-- Entête morphologique -->
  <xsl:template match="entete">
      <form>
        <orth>
          <xsl:value-of select="../@terme"/>
        </orth>
        <xsl:apply-templates/>
      </form>    
  </xsl:template>
  <!-- Phonétique -->
  <xsl:template match="prononciation">
    <pron>
      <xsl:apply-templates/>
    </pron>
  </xsl:template>
  <!-- nature morpho-syntaxique -->
  <xsl:template match="nature">
    <gram>
      <xsl:apply-templates/>
    </gram>
  </xsl:template>
  <!-- note morphologique -->
  <xsl:template match="entete/indent">
    <note>
      <xsl:apply-templates/>
    </note>
  </xsl:template>
  <!-- traverser -->
  <xsl:template match="corps">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- sens de premier et second niveau. C'est ici le plus compliqué,
pour enchâsser les gloses (textes ou renvois) -->
  <xsl:template match="variante | variante/indent">
    <sense>
      <xsl:apply-templates select="@*"/>
      <xsl:for-each select="node()">
        <xsl:choose>
          <!-- citation, procéder normalement -->
          <xsl:when test="self::cit">
            <xsl:apply-templates select="."/>
          </xsl:when>
          <!-- sous-sens, procéder normalement -->
          <xsl:when test="self::indent">
            <xsl:apply-templates select="."/>
          </xsl:when>
          <!-- espace d'indentation, passer -->
          <xsl:when test="normalize-space(.) = ''"/>
          <!-- pas le premier noeud d'une glose (exemple, renvoi) -->
          <xsl:when test="preceding-sibling::node()[normalize-space(.) != ''][1][local-name() != 'cit' and  local-name() != 'indent']"/>
          <!-- Premier noeud d'une glose, ouvrir le conteneur, appeler un template nommé -->
          <xsl:otherwise>
            <dictScrap>
              <xsl:apply-templates select="." mode="suivant"/>
            </dictScrap>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </sense>
  </xsl:template>
  <!-- numéro de sens -->
  <xsl:template match="@num">
    <xsl:attribute name="n">
      <xsl:apply-templates/>
    </xsl:attribute>
  </xsl:template>
  <!-- Ne s'applique en théorie qu'au premier noeud d'une glose. Si le noeud suivant n'est pas une citation ou un sous-sens, l'ajouter à la suite. -->
  <xsl:template match="node()" mode="suivant">
    <xsl:apply-templates select="."/>
    <xsl:variable name="suivant" select="local-name(following-sibling::node()[1])"/>
    <xsl:if test="$suivant != 'cit' and $suivant != 'indent'">
      <xsl:apply-templates select="following-sibling::node()[1]" mode="suivant"/>
    </xsl:if>
  </xsl:template>
  <!-- Plan d'article -->
  <xsl:template match="résumé">
    <note type="plan">
      <list>
        <xsl:apply-templates/>
      </list>
    </note>
  </xsl:template>
  <!-- Item de plan -->
  <xsl:template match="résumé/variante">
    <item n="{@num}">
      <xsl:apply-templates/>
    </item>
  </xsl:template>
  <!-- étymologie -->
  <xsl:template match="rubrique[@nom='ÉTYMOLOGIE']">
    <etym>
      <xsl:apply-templates/>
    </etym>
  </xsl:template>
  <xsl:template match="rubrique[@nom='ÉTYMOLOGIE']/indent">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- Section historique -->
  <xsl:template match="rubrique[@nom='HISTORIQUE']">
    <note type="historique">
      <xsl:apply-templates/>
    </note>
  </xsl:template>
  <!-- découpage du fil historique -->
  <xsl:template match="rubrique[@nom='HISTORIQUE']/indent">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  <!-- siècle -->
  <xsl:template match="rubrique[@nom='HISTORIQUE']/indent/text()">
    <xsl:variable name="text" select="normalize-space(.)"/>
    <xsl:choose>
      <xsl:when test="$text=''"/>
      <xsl:otherwise>
        <label>
          <xsl:value-of select="normalize-space(.)"/>
        </label>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Remarque -->
  <xsl:template match="rubrique[@nom='REMARQUE']">
    <note type="remarque">
      <xsl:choose>
        <!-- 2 éléments, à traiter comme des paragraphes -->
        <xsl:when test="*[2]">
          <xsl:apply-templates/>
        </xsl:when>
        <xsl:when test="indent">
          <xsl:apply-templates select="indent/node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </note>    
  </xsl:template>
  <!-- Paragraphe dans une remarque -->
  <xsl:template match="rubrique[@nom='REMARQUE']/indent">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  <!-- Proverbe -->
  <xsl:template match="rubrique[@nom='PROVERBES']">
    <re type="proverbes">
      <xsl:apply-templates/>
    </re>    
  </xsl:template>
  <xsl:template match="rubrique[@nom='PROVERBE'] | rubrique[@nom='PROVERBES']/indent ">
    <re type="proverbe">
      <xsl:apply-templates/>
    </re>    
  </xsl:template>
  <xsl:template match="rubrique[@nom='PROVERBE']/exemple | rubrique[@nom='PROVERBES']/indent/exemple">
    <form>
      <xsl:apply-templates/>
    </form>      
  </xsl:template>
  <!-- Nuances -->
  <xsl:template match="rubrique[@nom='SYNONYME']">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="rubrique[@nom='SYNONYME']/indent">
    <re type="nuance">
      <xsl:apply-templates/>
    </re>
  </xsl:template>
  <!-- Suppléments, mis comme sous-entrée poru supporter des éléments à réordonner -->
  <xsl:template match="rubrique[@nom='SUPPLÉMENT AU DICTIONNAIRE']">
    <re type="supplement">
      <xsl:apply-templates/>
    </re>
  </xsl:template>
  <xsl:template match="rubrique[@nom='SUPPLÉMENT AU DICTIONNAIRE']/indent">
    <re>
      <xsl:apply-templates/>
    </re>
  </xsl:template>
  <xsl:template match="rubrique[@nom='SUPPLÉMENT AU DICTIONNAIRE']/text()">
    <xsl:variable name="text" select="normalize-space(.)"/>
    <xsl:choose>
      <xsl:when test="$text=''"/>
      <xsl:otherwise>
        <form>
          <xsl:value-of select="."/>
        </form>          
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Renvoi  -->
  <xsl:template match="a">
    <ref>
      <xsl:apply-templates select="@*|node()"/>
    </ref>
  </xsl:template>
  <!-- Renvoi, identifiant de vedette, pas de point pour le n° d'homographe, problème prévisible pour les affixes (-ment) -->
  <xsl:template match="a/@ref">
    <xsl:attribute name="target">
      <xsl:value-of select="translate(., '.', '')"/>
    </xsl:attribute>
  </xsl:template>
  <!-- Citation -->
  <xsl:template match="cit">
    <cit>
      <quote>
        <xsl:apply-templates/>
      </quote>
      <!-- Dans le Littré papier, la référence est après -->
      <xsl:if test="@*">
        <bibl>
          <xsl:apply-templates select="@*"/>
        </bibl>
      </xsl:if>
    </cit>      
  </xsl:template>
  <!-- auteur -->
  <xsl:template match="@aut">
    <xsl:if test=". != ''">
      <author>
        <xsl:value-of select="."/>
      </author>
    </xsl:if>
  </xsl:template>
  <!-- précision biblio -->
  <xsl:template match="cit/@ref">
    <biblScope>
      <xsl:value-of select="."/>
    </biblScope>
  </xsl:template>
  <!-- Encore très irrégulier -->
  <xsl:template match="exemple">
    <q>
      <xsl:apply-templates/>
    </q>
  </xsl:template>
  <!-- Par défaut, tout recopier -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
</xsl:transform>