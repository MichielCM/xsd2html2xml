<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<xsl:template match="xs:any|xs:anyAttribute">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		<xsl:param name="namespace-prefix" /> <!-- contains inherited namespace prefix -->
		
		<xsl:param name="xpath" /> <!-- contains an XPath query relative to the current node, to be used with xml document -->
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">xs:any|xs:anyAttribute</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="throw">
			<xsl:with-param name="message">
				<xsl:text>Element or attribute '</xsl:text>
				<xsl:value-of select="local-name() "/>
				<xsl:text>' not supported</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
</xsl:stylesheet>