<?xml version="1.0" encoding="ISO-8859-15"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	exclude-result-prefixes="xsl dc">

	<!-- 	<xsl:import href="spPivotLocal.xsl"/> -->
  	
  	<xsl:import href="spOrganisme.xsl"/>

	<xsl:output method="xml" encoding="ISO-8859-15" cdata-section-elements="script" indent="yes"/> 

	<xsl:template name="affOuSAdresser">
		<xsl:if test="count(OuSAdresser) > 0">
			<div class="spPublicationOSA block" id="sp-ou-sadresser">
				<h2>
					<i class="fa fa-map-marker"><xsl:text> </xsl:text></i>
					<xsl:call-template name="imageOfAPartie">
						<xsl:with-param name="nom">sadresser</xsl:with-param>
					</xsl:call-template>
					<xsl:text>Où s'adresser ?</xsl:text>
				</h2>
				<xsl:apply-templates select="OuSAdresser[@type='Centre de contact']" mode="web"/>
				
				<xsl:choose>
					<xsl:when test="$MODE_PIVOT = 'pivot'">
						<xsl:apply-templates select="OuSAdresser[@type!='Centre de contact']" mode="pivot"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="OuSAdresser[@type!='Centre de contact']" mode="web"/>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template match="OuSAdresser" mode="pivot">
		
		
			<!-- for DEBUG : URL de la liste des pivots locaux pour ma ville. Affiche le fichier XML pour le code INSEE.
			<span>PIVOTS_LIST: <xsl:value-of select="$PIVOTS_LIST"/></span> -->
			
			<!-- On test s'il existe ce PivotLocal dans la liste des pivots de notre ville (fichier xml lié au code INSEE) -->
			<xsl:variable name="isPivotInLIST">
				<xsl:value-of select="boolean(document($PIVOTS_LIST)/Commune/TypeOrganisme/@pivotLocal = PivotLocal)"/>
			</xsl:variable>
			
			
			
			<!-- Si le pivotLocal existe pour ma ville : on affiche. Sinon on utilise le pivot Web par defaut -->
			<xsl:choose>
				
				<xsl:when test="$isPivotInLIST = 'true'">

					<xsl:apply-templates select="document($PIVOTS_LIST)/Commune/TypeOrganisme">
						<xsl:with-param name="pivotLocal">
							<xsl:value-of select="PivotLocal"/>
						</xsl:with-param>						
					</xsl:apply-templates>
				
				</xsl:when>
				
				<xsl:otherwise>
					<div class="spOrganisme">

					<xsl:attribute name="class">
						<xsl:text>spOrganisme </xsl:text>
						<xsl:value-of select="PivotLocal"/>
					</xsl:attribute>
				
					<div class="spOrganisme-title">
						<xsl:choose>
							<xsl:when test="RessourceWeb">
								<h3>
					    			<xsl:call-template name="getSiteLink">
					    				<xsl:with-param name="href"><xsl:value-of select="RessourceWeb/@URL"/></xsl:with-param>
					    				<xsl:with-param name="title"><xsl:value-of select="RessourceWeb/@URL"/></xsl:with-param>
					    				<xsl:with-param name="text"><xsl:value-of select="Titre"/></xsl:with-param>
									</xsl:call-template>
								</h3>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="Texte">
									<span class="expand"><xsl:text> </xsl:text></span>
								</xsl:if>
								<h3><xsl:value-of select="Titre"/></h3>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="Complement">
							<xsl:value-of select="Complement"/>
						</xsl:if>
					</div>
					<xsl:if test="Texte">
						<xsl:apply-templates select="Texte" mode="OuSAdresser"/>
					</xsl:if>
					</div>
				</xsl:otherwise>
				
			</xsl:choose>
			
	</xsl:template>

	<!-- TYPE Organisme -->
	<xsl:template match="TypeOrganisme">
		<xsl:param name="pivotLocal"/>

		<xsl:if test="@pivotLocal = $pivotLocal">
		
			<xsl:for-each select="Organisme">
				
				<!-- Recuperation de l'URL du fichier d'information sur l'organisme -->
				<xsl:variable name="OrganismeFile">
			    	<xsl:value-of select="$PIVOTS_DONNEES_ORGANISMES"/>
			    	<xsl:value-of name="pText" select="substring(substring-before(substring-after(@id, '-'), '-'),0,3)"/> <!-- Get the departement -->
			    	<xsl:text>/</xsl:text>
			    	<xsl:value-of select="@id"/>
			    	<xsl:text>.xml</xsl:text>
				</xsl:variable>
				
				<!-- for DEBUG : Display the organisme file url
				<xsl:value-of select="$OrganismeFile"/> -->
				
				<!-- Affichage des infos sur l'Organisme -->
				<xsl:apply-templates select="document($OrganismeFile)/Organisme" />

			</xsl:for-each>
			
		</xsl:if>
		
	</xsl:template>
	
	<!-- Ou s'adresser web -->
	<xsl:template match="OuSAdresser" mode="web">
		<div class="spOrganisme">
			
			<div class="spOrganisme-title">
				<xsl:choose>
					<xsl:when test="RessourceWeb">
						<h3>
			    			<xsl:call-template name="getSiteLink">
			    				<xsl:with-param name="href"><xsl:value-of select="RessourceWeb/@URL"/></xsl:with-param>
			    				<xsl:with-param name="title"><xsl:value-of select="RessourceWeb/@URL"/></xsl:with-param>
			    				<xsl:with-param name="text"><xsl:value-of select="Titre"/></xsl:with-param>
							</xsl:call-template>
						</h3>
					</xsl:when>
					
					<xsl:otherwise>
						<xsl:if test="Texte">
						<span class="expand"><xsl:text> </xsl:text></span>
						</xsl:if>
						<h3><xsl:value-of select="Titre"/></h3>
					</xsl:otherwise>
				</xsl:choose>
				
				<xsl:if test="Complement">
					<xsl:value-of select="Complement"/>
				</xsl:if>
			</div>
			
			
			<xsl:if test="Texte">
				<div class="spOrganisme-content">
				<xsl:apply-templates select="Texte" mode="OuSAdresser"/>
				</div>
			</xsl:if>
			
		</div>
	</xsl:template>
	
		
	<xsl:template name="affOuSAdresserChapitre">
		<xsl:apply-templates mode="OuSAdresser"/>
	</xsl:template>
	
</xsl:stylesheet>
