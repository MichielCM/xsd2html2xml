<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<!-- adds appinfo data to data-appinfo attributes -->
	<xsl:template name="add-appinfo">
		<xsl:param name="relative-name"></xsl:param>

		<xsl:call-template name="log">
			<xsl:with-param name="reference">add-appinfo</xsl:with-param>
		</xsl:call-template>
		
		<xsl:choose>
			<!-- if appinfo is specifically meant for XSD2HTML2XML, add the attributes directly to the element -->
			<xsl:when test="ancestor::*[1]/@source = 'https://github.com/MichielCM/xsd2html2xml'">
				<!-- use local name to remove any colons -->
				<xsl:attribute name="{local-name()}">
					<xsl:value-of select="." />
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<!-- add data attribute if there are no further nodes -->
				<xsl:if test="count(*) = 0">
					<!-- use local name to remove any colons -->
					<xsl:attribute name="{concat('data-appinfo-',$relative-name,local-name())}">
						<xsl:value-of select="." />
					</xsl:attribute>
				</xsl:if>

				<!-- call add-appinfo on children, if any -->
				<xsl:for-each select="*">
					<xsl:call-template name="add-appinfo">
						<xsl:with-param name="relative-name" select="concat($relative-name,local-name(ancestor::*[1]),'-')" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>