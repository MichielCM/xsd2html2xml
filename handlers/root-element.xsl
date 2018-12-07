<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<xsl:template name="handle-root-element" match="xsl:template[@name = 'handle-root-element']">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		
		<xsl:param name="node" />
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">handle-root-element</xsl:with-param>
		</xsl:call-template>
		
		<xsl:apply-templates select="$node">
			<xsl:with-param name="root-document" select="$root-document" />
			<xsl:with-param name="root-path" select="$root-path" />
			<xsl:with-param name="root-namespaces" select="$root-namespaces" />
			
			<xsl:with-param name="namespace-documents" select="$namespace-documents" />
		</xsl:apply-templates>
	</xsl:template>
	
	
</xsl:stylesheet>