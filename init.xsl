<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<xsl:template name="init">
		<xsl:call-template name="inform">
			<xsl:with-param name="message">---</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="inform">
			<xsl:with-param name="message">Running XSD2HTML2XML version 3</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="inform">
			<xsl:with-param name="message">Michiel Meulendijk (mail@michielmeulendijk.nl) / Leiden University Medical Center</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="inform">
			<xsl:with-param name="message">MIT License</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="inform">
			<xsl:with-param name="message">https://github.com/MichielCM/xsd2html2xml</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="inform">
			<xsl:with-param name="message">---</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="inform">
			<xsl:with-param name="message">XSLT Processor: <xsl:value-of select="system-property('xsl:vendor')" /></xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="inform">
			<xsl:with-param name="message">XSLT Version: <xsl:value-of select="system-property('xsl:version')" /></xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="inform">
			<xsl:with-param name="message">Debug Options: <xsl:value-of select="$config-debug" /></xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="inform">
			<xsl:with-param name="message">---</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
</xsl:stylesheet>