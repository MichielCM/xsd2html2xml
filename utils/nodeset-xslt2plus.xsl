<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<!-- forwards all provided parameters to $template in $stylesheet; forwards $namespace-documents as nodeset -->
	<xsl:template name="forward">
		<xsl:param name="stylesheet" /> <!-- stylesheet file in which template is declared; variable declared in xsd2html2xml.xsl -->
		<xsl:param name="template" /> <!-- template name to be called; must contain @name attribute in declaration -->
		
		<xsl:param name="namespace-documents" /> <!-- namespace documents as nodeset -->
		
		<!-- miscellanerous parameters -->
		<xsl:param name="root-document" />
		<xsl:param name="root-path" />
		<xsl:param name="root-namespaces" />
		<xsl:param name="namespace-prefix" />
		<xsl:param name="id" />
		<xsl:param name="ref" />
		<xsl:param name="ref-suffix" />
		<xsl:param name="base" />
		<xsl:param name="attr" />
		<xsl:param name="min-occurs" />
		<xsl:param name="max-occurs" />
		<xsl:param name="choice" />
		<xsl:param name="local-namespace" />
		<xsl:param name="local-namespace-prefix" />
		<xsl:param name="description" />
		<xsl:param name="count" />
		<xsl:param name="index" />
		<xsl:param name="simple" />
		<xsl:param name="invisible" />
		<xsl:param name="default" />
		<xsl:param name="disabled" />
		<xsl:param name="type" />
		<xsl:param name="type-suffix" />
		<xsl:param name="reference" />
		<xsl:param name="xpath" />
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">fwd (v2,3): <xsl:value-of select="$template" /></xsl:with-param>
		</xsl:call-template>
		
		<xsl:apply-templates select="$stylesheet/*/xsl:template[@name=$template]">
			<!-- calling node is provided as parameter $node -->
			<xsl:with-param name="node" select="." />
			
			<!-- namespace documents are forwarded as they are (nodeset) -->
			<xsl:with-param name="namespace-documents" select="$namespace-documents" />
			
			<!-- miscellaneous parameters are forwarded as they are -->
			<xsl:with-param name="root-document" select="$root-document" />
			<xsl:with-param name="root-path" select="$root-path" />
			<xsl:with-param name="root-namespaces" select="$root-namespaces" />
			<xsl:with-param name="id" select="$id" />
			<xsl:with-param name="ref" select="$ref" />
			<xsl:with-param name="ref-suffix" select="$ref-suffix" />
			<xsl:with-param name="base" select="$base" />
			<xsl:with-param name="attr" select="$attr" />
			<xsl:with-param name="min-occurs" select="$min-occurs" />
			<xsl:with-param name="max-occurs" select="$max-occurs" />
			<xsl:with-param name="choice" select="$choice" />
			<xsl:with-param name="namespace-prefix" select="$namespace-prefix" />
			<xsl:with-param name="local-namespace" select="$local-namespace" />
			<xsl:with-param name="local-namespace-prefix" select="$local-namespace-prefix" />
			<xsl:with-param name="description" select="$description" />
			<xsl:with-param name="simple" select="$simple" />
			<xsl:with-param name="count" select="$count" />
			<xsl:with-param name="index" select="$index" />
			<xsl:with-param name="invisible" select="$invisible" />
			<xsl:with-param name="default" select="$default" />
			<xsl:with-param name="disabled" select="$disabled" />
			<xsl:with-param name="type" select="$type" />
			<xsl:with-param name="type-suffix" select="$type-suffix" />
			<xsl:with-param name="reference" select="$reference" />
			<xsl:with-param name="xpath" select="$xpath" />
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- forwards all provided parameters to $template in $stylesheet; forwards $root-namespaces as nodeset -->
	<xsl:template name="forward-root">
		<xsl:param name="stylesheet" /> <!-- stylesheet file in which template is declared; variable declared in xsd2html2xml.xsl -->
		<xsl:param name="template" /> <!-- template name to be called; must contain @name attribute in declaration -->
		
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes as nodeset -->
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">fwd-root (v2,3): <xsl:value-of select="$template" /></xsl:with-param>
		</xsl:call-template>
		
		<xsl:apply-templates select="$stylesheet/*/xsl:template[@name=$template]">
			<!-- calling node is provided as parameter $node -->
			<xsl:with-param name="node" select="." />
			
			<!-- root namespaces are forwarded as they are (nodeset) -->
			<xsl:with-param name="root-namespaces" select="$root-namespaces" />
			
			<!-- miscellaneous parameters are forwarded as they are -->
			<xsl:with-param name="root-document" select="$root-document" />
		</xsl:apply-templates>
	</xsl:template>
	
</xsl:stylesheet>