<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<!-- handles groups existing of other attributes; forwards them with their referenced attribute's namespace documents -->
	<xsl:template match="xs:attributeGroup[@ref]">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		<xsl:param name="xpath" /> <!-- contains an XPath query relative to the current node, to be used with xml document -->
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">attributeGroup[@ref]</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="forward">
			<xsl:with-param name="stylesheet" select="$attributeGroup-stylesheet" />
			<xsl:with-param name="template">attributeGroup-forwardee</xsl:with-param>
			
			<xsl:with-param name="root-document" select="$root-document" />
			<xsl:with-param name="root-path" select="$root-path" />
			<xsl:with-param name="root-namespaces" select="$root-namespaces" />
			
			<xsl:with-param name="namespace-documents">
				<!-- retrieve namespace documents belonging to the referenced attribute -->
				<xsl:call-template name="get-namespace-documents">
					<xsl:with-param name="namespace">
						<xsl:call-template name="get-namespace">
							<xsl:with-param name="namespace-prefix">
								<xsl:call-template name="get-prefix">
									<xsl:with-param name="root-namespaces" select="$root-namespaces" />
									<xsl:with-param name="string" select="@ref" />
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="namespace-prefix">
				<xsl:call-template name="get-prefix">
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="string" select="@type" />
					<xsl:with-param name="include-colon">true</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			
			<xsl:with-param name="ref" select="@ref" />
			<xsl:with-param name="ref-suffix">
				<xsl:call-template name="get-suffix">
					<xsl:with-param name="string" select="@ref" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="disabled" select="$disabled" />
			<xsl:with-param name="xpath" select="$xpath" />
		</xsl:call-template>
	</xsl:template>
	
	<!-- handles groups existing of other attributes; note that 'ref' is used as id overriding local-name() -->
	<xsl:template name="attributeGroup-forwardee" match="xsl:template[@name = 'attributeGroup-forwardee']">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in attribute namespace -->
		<xsl:param name="namespace-prefix" /> <!-- contains inherited namespace prefix -->
		
		<xsl:param name="ref" /> <!-- contains element reference -->
		<xsl:param name="ref-suffix" /> <!-- contains referenced attribute's suffix -->
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		<xsl:param name="xpath" /> <!-- contains an XPath query relative to the current node, to be used with xml document -->
		
		<xsl:param name="node" />
		
		<xsl:choose>
			<!-- if called from forward, call it again with with $node as calling node -->
			<xsl:when test="name() = 'xsl:template'">
				<xsl:for-each select="$node">
					<xsl:call-template name="attributeGroup-forwardee">
						<xsl:with-param name="root-document" select="$root-document" />
						<xsl:with-param name="root-path" select="$root-path" />
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						
						<xsl:with-param name="namespace-documents" select="$namespace-documents" />
						<xsl:with-param name="namespace-prefix" select="$namespace-prefix" />
						
						<xsl:with-param name="ref" select="$ref" />
						<xsl:with-param name="ref-suffix" select="$ref-suffix" />
						<xsl:with-param name="disabled" select="$disabled" />
						<xsl:with-param name="xpath" select="$xpath" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<!-- else continue processing -->
			<xsl:otherwise>
				<xsl:call-template name="log">
					<xsl:with-param name="reference">attributeGroup[@ref]-forwardee</xsl:with-param>
				</xsl:call-template>
				
				<!-- find the referenced attribute through the id and let the matching templates handle it -->
				<xsl:apply-templates select="$namespace-documents//xs:attributeGroup[@name=$ref-suffix]/xs:attribute
					|$namespace-documents//xs:attributeGroup[@name=$ref-suffix]/xs:attributeGroup
					|$namespace-documents//xs:attributeGroup[@name=$ref-suffix]/xs:anyAttribute">
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					
					<xsl:with-param name="namespace-prefix" select="$namespace-prefix" />
					
					<xsl:with-param name="id" select="$ref" />
					<xsl:with-param name="disabled" select="$disabled" />
					<xsl:with-param name="xpath" select="$xpath" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>