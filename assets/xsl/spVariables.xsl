<?xml version="1.0" encoding="ISO-8859-15"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	exclude-result-prefixes="xsl dc">

	<xsl:output method="xml" encoding="UTF-8" cdata-section-elements="script" indent="yes"/> 
  	
  	<!-- Code de la cat�gorie
  		* part : particuliers
  		* asso : associations
  		* pro : entreprises et professionnels
  	 -->
	<xsl:param name="CATEGORIE"/>

  	<!-- Nom associ� � 1 des 3 cat�gories : particuliers, associations et professionnels -->
	<xsl:variable name="CATEGORIE_NOM">
		<xsl:choose>
			<xsl:when test="$CATEGORIE = 'part'">
				<xsl:text>particuliers</xsl:text>
			</xsl:when>
			<xsl:when test="$CATEGORIE = 'asso'">
				<xsl:text>associations</xsl:text>
			</xsl:when>
			<xsl:when test="$CATEGORIE = 'pro'">
				<xsl:text>entreprises et professionnels</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>

  	<!-- Hyperlien principal du guide des particuliers -->
	<xsl:param name="HYPERLIEN_PART"/>

  	<!-- Hyperlien principal du guide des associations -->
	<xsl:param name="HYPERLIEN_ASSO"/>

  	<!-- Hyperlien principal du guide des entreprises et professionnels -->
	<xsl:param name="HYPERLIEN_PRO"/>

 	<!-- Hyperlien du r�pertoire contenant les pictogrammes
 		* courriel, t�l�phone, fax...
 	 -->
	<xsl:param name="PICTOS"/>

	<!-- Hyperlien du r�pertoire contenant les donn�es XML -->
	<xsl:param name="DONNEES"/>

	<!-- Hyperlien principal de la cat�gorie en cours -->
	<xsl:variable name="HYPERLIEN_COURANT">
		<xsl:choose>
			<xsl:when test="$CATEGORIE = 'part'">
				<xsl:value-of select="$HYPERLIEN_PART"/>
			</xsl:when>
			<xsl:when test="$CATEGORIE = 'asso'">
				<xsl:value-of select="$HYPERLIEN_ASSO"/>
			</xsl:when>
			<xsl:when test="$CATEGORIE = 'pro'">
				<xsl:value-of select="$HYPERLIEN_PRO"/>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
 	
	<!-- URL du r�pertoire contenant le fichier XML � afficher -->
	<xsl:variable name="XML_COURANT">
		<xsl:value-of select="$DONNEES"/>
		<xsl:choose>
			<xsl:when test="$CATEGORIE = 'part'">
				<xsl:text>/part/</xsl:text>
			</xsl:when>
			<xsl:when test="$CATEGORIE = 'asso'">
				<xsl:text>/asso/</xsl:text>
			</xsl:when>
			<xsl:when test="$CATEGORIE = 'pro'">
				<xsl:text>/pro/</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>

  	<!-- Texte des comment faire... -->
	<xsl:variable name="TEXTE_CFS">
		<xsl:choose>
			<xsl:when test="$CATEGORIE = 'pro'">
				<xsl:text>Comment faire pour...</xsl:text>
			</xsl:when>
			<xsl:when test="$CATEGORIE = 'asso'">
				<xsl:text>Comment faire si...</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Comment faire si...</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- Identifiant du noeud affichant tous les comment faire... -->
	<xsl:variable name="ACCUEIL_CFS">
		<xsl:choose>
			<xsl:when test="$CATEGORIE = 'pro'">N23971</xsl:when>
			<xsl:when test="$CATEGORIE = 'asso'">N31000</xsl:when>
			<xsl:otherwise>N13042</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- Nom du fichier XML g�rant les pages d'accueil des 3 guides
		* arborescence : flux V2.3
		* Themes : flux V2.2
	-->
	<xsl:variable name="THEME_ARBORESCENCE">
		<xsl:text>000-PTA-Themes</xsl:text>
	</xsl:variable>

	<!-- Indique si un fichier g�re l'ensemble des ressources R*
		* true : oui
		* false : non
	-->
	<xsl:variable name="AFF_RESSOURCES">
		<xsl:value-of select="true()"/>
	</xsl:variable>

	<!-- Active ou d�sactive l'affichage du fil d'ariane
		* true : activation
		* false : d�sactivation
	-->
	<xsl:variable name="AFF_FIL_ARIANE">
		<xsl:value-of select="true()"/>
	</xsl:variable>

	<!-- Active ou d�sactive l'affichage du menu du sommaire et des dossiers
		* true : activation
		* false : d�sactivation
	-->
	<xsl:variable name="AFF_SOMMAIRE">
		<xsl:value-of select="true()"/>
	</xsl:variable>

	<!-- Active ou d�sactive l'affichage de la date
		* true : activation
		* false : d�sactivation
	-->
	<xsl:variable name="AFF_DATE">
		<xsl:value-of select="true()"/>
	</xsl:variable>

	<!-- Active ou d�sactive l'affichage de la barre des th�mes principaux
		* true : activation
		* false : d�sactivation
	-->
	<xsl:variable name="AFF_BARRE_THEME">
		<xsl:value-of select="false()"/>
	</xsl:variable>

	<!-- Active ou d�sactive l'affichage des images des th�mes et des cat�gories
		* fonctions : imageOfTheme et imageOfPartie
		* true : activation
		* false : d�sactivation
	-->
	<xsl:variable name="AFF_IMAGES">
		<xsl:value-of select="true()"/>
	</xsl:variable>
	
	<!-- Active ou d�sactive l'affichage des images des th�mes et des cat�gories
	* fonctions : imageOfTheme et imageOfPartie
	* true : activation
	* false : d�sactivation
	-->
	<xsl:variable name="AFF_IMAGES_PARTIE">
		<xsl:value-of select="false()"/>
	</xsl:variable>
	

	<!-- Active ou d�sactive l'affichage des pictogrammes pr�sents dans les pivots locaux
		* true : activation
		* false : d�sactivation
	-->
	<xsl:variable name="AFF_PICTOS">
		<xsl:value-of select="true()"/>
	</xsl:variable>

	<!-- R�pertoire contenant les images -->
	<xsl:variable name="IMAGES">
		<xsl:value-of select="$DONNEES"/><xsl:text>images/</xsl:text>
	</xsl:variable>



	<!-- Gestion des pivots de type PivotLocal
		* pivot : pour afficher des � fichiers pivots locaux � au format XML
		* web : pour afficher les liens g�n�riques produits par service-public.fr
	-->
	<xsl:variable name="MODE_PIVOT">
		<xsl:text>pivot</xsl:text>
	</xsl:variable>

	<!-- URL for the PIVOTS Directory -->
	<xsl:variable name="PIVOTS_DONNEES">
		<xsl:text>http://lecomarquage.service-public.fr/donnees_locales_v2/all/</xsl:text>
	</xsl:variable>

	<!-- Code DEPARTEMENT -->
	<xsl:variable name="PIVOT_DEP">
		<xsl:text>75</xsl:text>
	</xsl:variable>

	<!-- Code INSEE -->
	<xsl:variable name="PIVOT_INSEE">
		<xsl:text>75056</xsl:text>
	</xsl:variable>

	<!-- Fichier contenant les pivots locaux pour le code INSEE specifi� -->
	<xsl:variable name="PIVOTS_LIST">
		<xsl:value-of select="$PIVOTS_DONNEES"/>
		<xsl:text>communes/</xsl:text>
		<xsl:value-of select="$PIVOT_DEP"/>
		<xsl:text>/</xsl:text>
		<xsl:value-of select="$PIVOT_INSEE"/>
		<xsl:text>.xml</xsl:text>
	</xsl:variable>

	<!-- R�pertoire contenant les pivots -->
	<xsl:variable name="PIVOTS_DONNEES_ORGANISMES">
		<xsl:value-of select="$PIVOTS_DONNEES"/>
		<xsl:text>organismes/</xsl:text>
	</xsl:variable>

<!--
		<xsl:value-of select="$DONNEES"/><xsl:text>pivots/</xsl:text>
	</xsl:variable>
-->
	
</xsl:stylesheet>