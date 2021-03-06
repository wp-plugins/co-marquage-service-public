<?xml version="1.0" encoding="ISO-8859-15"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	exclude-result-prefixes="xsl dc">
  	
 	<xsl:import href="spVariables.xsl"/>
  	<xsl:import href="spCommon.xsl"/>
  	<xsl:import href="spActualite.xsl"/>
  	<xsl:import href="spAvertissement.xsl"/>
  	<xsl:import href="spChapitre.xsl"/>
 	<xsl:import href="spCommentFaireSi.xsl"/>
  	<xsl:import href="spDossier.xsl"/>
  	<xsl:import href="spFiche.xsl"/>
  	<xsl:import href="spFilDAriane.xsl"/>
  	<xsl:import href="spInformationComplementaire.xsl"/>
  	<xsl:import href="spIntroduction.xsl"/>
 	<xsl:import href="spLien.xsl"/>
 	<xsl:import href="spListe.xsl"/>
   	<xsl:import href="spOuSAdresser.xsl"/>
 	<xsl:import href="spParagraphe.xsl"/>
 	<xsl:import href="spPartenaire.xsl"/>
  	<xsl:import href="spPourEnSavoirPlus.xsl"/>
  	<xsl:import href="spQuestionReponse.xsl"/>
   	<xsl:import href="spReference.xsl"/>
  	<xsl:import href="spServiceEnLigne.xsl"/>
  	<xsl:import href="spSiteInternetPublic.xsl"/>
  	<xsl:import href="spSousDossier.xsl"/>
  	<xsl:import href="spSousTheme.xsl"/>
 	<xsl:import href="spTableau.xsl"/>
  	<xsl:import href="spTexte.xsl"/>
  	<xsl:import href="spTitre.xsl"/>
  	<xsl:import href="spVoirAussi.xsl"/>

	<xsl:output method="xml" encoding="UTF-8" cdata-section-elements="script" indent="yes"/> 

  	<!-- Publication -->
   	<xsl:template match="/Publication">

	   	<div id="cm-sidebar">
				<xsl:call-template name="affAvertissement"/>
				<xsl:call-template name="affInformationComplementaire"/>
				<xsl:call-template name="affServiceEnLigne"/>
				<xsl:call-template name="affCommentFaireSi"/>	
				<xsl:call-template name="affActualite"/>
				<xsl:call-template name="affSiteInternetPublic"/>
				<xsl:call-template name="affLienExterneCommente"/>
				<xsl:call-template name="affQuestionReponse"/>
				<xsl:text> </xsl:text>
		</div>
		<div id="cm-content">

			<xsl:call-template name="getBarreThemes"/>
			<xsl:choose>
				<xsl:when test="FilDAriane">
					<xsl:apply-templates select="FilDAriane"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="createFilDAriane"/>
				</xsl:otherwise>
			</xsl:choose>			
			
			<xsl:call-template name="getTitre"/>
			
			<xsl:choose>
				<xsl:when test="@type = 'Accueil Comment faire si'">
					<xsl:call-template name="mainNoeudACFS">
						<xsl:with-param name="col">
							<xsl:choose>
								<xsl:when test="$CATEGORIE = 'asso'">2</xsl:when>
								<xsl:otherwise>3</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>						
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="mainNoeudStandard"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:call-template name="affOuSAdresser"/>					
			<xsl:call-template name="affPourEnSavoirPlus"/>
			<xsl:call-template name="affVoirAussi"/>
			<xsl:call-template name="affReference"/>
			<xsl:call-template name="affPartenaire"/>	
					
			<xsl:text> </xsl:text>
	 		<!-- <xsl:call-template name="ancreTop"/> -->
		</div>

	</xsl:template>

	<xsl:template name="mainNoeudStandard">

			<xsl:if test="$AFF_SOMMAIRE = 'true'">
				<div class="spPublicationMenuDroite">
					<xsl:call-template name="createSommaire"/>
					<xsl:call-template name="affDossiers"/>
				</div>
			</xsl:if>

			<xsl:if test="$AFF_DATE = 'true'">
				<xsl:call-template name="getDate"/>
			</xsl:if>
						
			<xsl:apply-templates select="Introduction"/>
			<xsl:apply-templates select="Texte"/>
			
			<div class="spPublicationNoeud">
				
				<xsl:if test="count(SousTheme) > 0">
					<xsl:apply-templates select="SousTheme"/>
				</xsl:if>
				
				<xsl:if test="count(SousDossier) > 0">
					<xsl:apply-templates select="SousDossier"/>
				</xsl:if>
				
				<xsl:if test="count(Dossier)+count(Fiche) > 0">
					<div class="spPublicationNoeud" id="sp-informations">
						<h2>
							<xsl:call-template name="imageOfAPartie">
								<xsl:with-param name="nom">complement</xsl:with-param>
							</xsl:call-template>
							<!-- <xsl:text>Articles connexes</xsl:text> -->
						</h2>
						<ul class="spPublicationNoeud">
							<xsl:apply-templates select="Dossier"/>
							<xsl:apply-templates select="Fiche"/>
						</ul>
					</div>
				</xsl:if>
				<xsl:text> </xsl:text>			
			</div>

	</xsl:template>
	
	<!-- Comment Faire Si -->
	<xsl:template name="mainNoeudACFS">
		<xsl:param name="col"/>
		<div class="spPublicationACFS">
			<xsl:for-each select="Fiche">
				<xsl:variable name="classTheme">
					<xsl:text>spArborescenceItem</xsl:text><xsl:value-of select="$col"/><xsl:text>Col</xsl:text>
				</xsl:variable>
				<xsl:if test="((position() mod $col) = 1) and (position() > 1)">
					<br class="clearall"/>
				</xsl:if>
				<div class="{$classTheme}">
					<xsl:variable name="title">
						<xsl:value-of select="../dc:title"/>
						<xsl:value-of select="$sepFilDAriane"/>
						<xsl:value-of select="text()"/>
					</xsl:variable>
					<h2>
						<xsl:call-template name="getPublicationLink">
							<xsl:with-param name="href"><xsl:value-of select="@ID"/></xsl:with-param>
							<xsl:with-param name="title"><xsl:value-of select="$title"/></xsl:with-param>
							<xsl:with-param name="text"><xsl:value-of select="text()"/></xsl:with-param>
						</xsl:call-template>
					</h2>
					<!--
						<xsl:call-template name="getDescription">
						<xsl:with-param name="id"><xsl:value-of select="@ID"/></xsl:with-param>
					</xsl:call-template>
					-->
				</div>
			</xsl:for-each>
			<br class="clearall"/>
		</div>
	</xsl:template>
	
	
	<!-- ServiceComplementaire -->
   	<xsl:template match="/ServiceComplementaire">

		<div id="cm-content">
			
			<xsl:call-template name="getBarreThemes"/>
			<xsl:choose>
				<xsl:when test="FilDAriane">
					<xsl:apply-templates select="FilDAriane"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="createFilDAriane"/>
				</xsl:otherwise>
			</xsl:choose>			
			
			<xsl:apply-templates select="dc:title"/>
			<xsl:call-template name="getMAJDate"/>
			
			<xsl:apply-templates select="LienWeb" mode="ServiceComplementaire"/>

			<xsl:call-template name="mainNoeudStandard"/>
			<xsl:text> </xsl:text>
		</div>
	</xsl:template>

	
	<xsl:template match="dc:title">
        <h1><xsl:apply-templates /></h1>
    </xsl:template>
	
	<xsl:template match="LienWeb"  mode="ServiceComplementaire">
            
            <xsl:text></xsl:text>
            <div class="ServiceComplementaire">
           
           	<xsl:variable name="texte">
				<xsl:choose>
					<xsl:when test="../dc:type = 'Module de calcul'">
						<xsl:text> Acc�der au module de calcul </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="../dc:type"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
            
            
	            <xsl:call-template name="getSiteLink">
						<xsl:with-param name="href"><xsl:value-of select="@URL"/></xsl:with-param>
						<xsl:with-param name="title"><xsl:value-of select="$texte"/></xsl:with-param>
						<xsl:with-param name="text"><xsl:value-of select="$texte"/></xsl:with-param>
				</xsl:call-template>
	           <p> <xsl:value-of select="Source"/></p>
            </div>

    </xsl:template>
	
				<!--
<LienWeb URL="http://www.marel.fr/">
<Source>Groupement d'int�r�t public Info retraite</Source>
</LienWeb>
-->
	
	
	
	
</xsl:stylesheet>
