<?xml version="1.0" encoding="ISO-8859-15"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	exclude-result-prefixes="xsl dc">

	<xsl:output method="xml" encoding="ISO-8859-15" cdata-section-elements="script" indent="yes"/> 
	
	<!-- Working functions -->
	<xsl:template name="getTelNumber">
		<xsl:param name="number"/>
		<a>
			<xsl:attribute name="href">
				<xsl:text>tel:</xsl:text>
				<xsl:value-of select="translate($number,' ','')"/>
			</xsl:attribute>
		
			<xsl:choose>
				<xsl:when test="substring($number,1,4) = '+33 '">
					0<xsl:value-of select="substring($number,5)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$number"/>
				</xsl:otherwise>
			</xsl:choose>
		</a>
	</xsl:template>
	
	
	<!-- ORGANISME -->
	<xsl:template match="Organisme">
		<div class="spOrganisme">
		
		<xsl:attribute name="class">
			<xsl:text>spOrganisme local </xsl:text>
			<xsl:value-of select="PivotLocal"/>
		</xsl:attribute>
		
		<xsl:if test="Nom">
			<div class="spOrganisme-title">
			<span class="expand"><xsl:text> </xsl:text></span>
		  	<h3><xsl:value-of select="Nom"/></h3>
		  	</div>
		  	
		  	<xsl:variable name="title">
		  		<xsl:value-of select="Nom"/>
		  	</xsl:variable>
		</xsl:if>
		
		<div class="spOrganisme-content">
			<xsl:apply-templates/>
		</div>
		
		</div>
	</xsl:template>
	
	<xsl:template match="Nom"/> <!-- On ne re-affiche pas le nom -->
	<xsl:template match="EditeurSource"/> <!-- On affiche pas l'editeur -->
	
	<!-- Template for display the google Map -->
	<xsl:template name="Localisation">
		
		<xsl:param name="dataTitle"/>
		<!-- <xsl:param name="dataContent"/> -->

		<div class="spGoogleMap">
			
			<xsl:attribute name="data-lat">
				<xsl:value-of select="Localisation/Latitude"/>
			</xsl:attribute>
			
			<xsl:attribute name="data-lng">
				<xsl:value-of select="Localisation/Longitude"/>
			</xsl:attribute>
			
			<xsl:attribute name="data-precision">
				<xsl:value-of select="Localisation/Précision"/>
			</xsl:attribute>
			
			<xsl:attribute name="data-title">
				<xsl:value-of select="$dataTitle"/>
			</xsl:attribute>
			
			<xsl:attribute name="data-content">
				<xsl:value-of select="$dataTitle"/>
			</xsl:attribute>
			
			<xsl:text> </xsl:text>
		</div>
		
	</xsl:template>
	
	
	<!-- Template for display address and informations -->
	<xsl:template match="Adresse">
		
		<xsl:variable name="adresse">
			<xsl:if test="Ligne">
				<xsl:for-each select="Ligne">
					<xsl:value-of select="text()"/>
					<xsl:text> - </xsl:text>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="CodePostal">
				<xsl:value-of select="CodePostal"/>
			</xsl:if>
			<xsl:if test="NomCommune">
				<xsl:text> </xsl:text>
				<xsl:value-of select="NomCommune"/>
			</xsl:if>
		</xsl:variable>
		
		
		<!-- Map -->
		<xsl:if test="Localisation">
			<xsl:call-template name="Localisation">
				<xsl:with-param name="dataTitle"><xsl:value-of select="../Nom"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		
		<!-- Address -->
		<address class="address">
			<p>
			<xsl:if test="Ligne">
				<xsl:for-each select="Ligne">
					<xsl:value-of select="text()"/><br/>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="CodePostal">
				<xsl:value-of select="CodePostal"/>
			</xsl:if>
			<xsl:if test="NomCommune">
				<xsl:text> </xsl:text>
				<xsl:value-of select="NomCommune"/>
			</xsl:if>
			</p>
		</address>
		
	</xsl:template>
	
	<xsl:template match="CoordonnéesNum">
		<xsl:if test="Téléphone">
			
			<xsl:text> tél. : </xsl:text>
			<xsl:call-template name="getTelNumber">
				<xsl:with-param name="number"><xsl:value-of select="Téléphone"/></xsl:with-param>
			</xsl:call-template>
			
			<xsl:if test="./@coût">
				<span class="cout"> (<xsl:value-of select="./@coût"/>)</span>
			</xsl:if>
			<br/>
		</xsl:if>
		
		<xsl:if test="Télécopie">
			<xsl:text> fax : </xsl:text>
			<xsl:call-template name="getTelNumber">
				<xsl:with-param name="number"><xsl:value-of select="Télécopie"/></xsl:with-param>
			</xsl:call-template>
			<br/>
		</xsl:if>
	
		<xsl:if test="Email">
			<xsl:text> courriel : </xsl:text>
			<a>
				<xsl:attribute name="href">
					<xsl:text>mailto:</xsl:text>
					<xsl:value-of select="Email"/>
				</xsl:attribute>
				<xsl:value-of select="Email"/>
			</a><br/>
		</xsl:if>

		<xsl:if test="Url">
			<xsl:text> site Internet : </xsl:text>
			<xsl:call-template name="getSiteLink">
				<xsl:with-param name="href"><xsl:value-of select="Url"/></xsl:with-param>
				<xsl:with-param name="title"><xsl:value-of select="Url"/></xsl:with-param>
				<xsl:with-param name="text"><xsl:value-of select="substring(Url,8)"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Ouverture">
		<h4> Horaires d'ouverture : </h4>
		<div class="ouverture">
			
			<xsl:for-each select="PlageJ">
			<p>	
				<span class="day">
				<xsl:choose>
					<xsl:when test="@début != @fin">
						<xsl:value-of select="@début"/> à <xsl:value-of select="@fin"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@début"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> :</xsl:text>
				</span>

				<xsl:for-each select="PlageH">
					<xsl:text> de </xsl:text><xsl:value-of select="substring(@début,0,6)"/><xsl:text> à </xsl:text><xsl:value-of select="substring(@fin,0,6)"/>
				</xsl:for-each>
				
				<xsl:if test="Note">
					<span class="note"><xsl:value-of select="Note"/></span>
				</xsl:if>
			</p>
			</xsl:for-each>
		</div>
	</xsl:template>

</xsl:stylesheet>