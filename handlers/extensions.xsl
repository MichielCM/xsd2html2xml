<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<xsl:template name="handle-extensions">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-prefix" /> <!-- contains inherited namespace prefix -->
		
		<xsl:param name="base" /> <!-- contains element's base type -->
		<xsl:param name="xpath" /> <!-- contains an XPath query relative to the current node, to be used with xml document -->
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">handle-extensions</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="forward">
			<xsl:with-param name="stylesheet" select="$extensions-stylesheet" />
			<xsl:with-param name="template">handle-extensions-forwardee</xsl:with-param>
			
			<xsl:with-param name="root-document" select="$root-document" />
			<xsl:with-param name="root-path" select="$root-path" />
			<xsl:with-param name="root-namespaces" select="$root-namespaces" />
			
			<xsl:with-param name="namespace-documents">
				<xsl:call-template name="get-namespace-documents">
					<xsl:with-param name="namespace">
						<xsl:call-template name="get-namespace">
							<xsl:with-param name="namespace-prefix">
								<xsl:call-template name="get-prefix">
									<xsl:with-param name="root-namespaces" select="$root-namespaces" />
									<xsl:with-param name="string" select="$base" />
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
					<xsl:with-param name="string" select="$base" />
					<xsl:with-param name="include-colon">true</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			
			<xsl:with-param name="base" select="$base" />
			<xsl:with-param name="disabled" select="$disabled" />
			<xsl:with-param name="xpath" select="$xpath" />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="handle-extensions-forwardee" match="xsl:template[@name = 'handle-extensions-forwardee']">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		<xsl:param name="namespace-prefix" /> <!-- contains inherited namespace prefix -->
		
		<xsl:param name="base" /> <!-- contains element's base type -->
		<xsl:param name="disabled" /> <!-- is used to disable elements that are copies for additional occurrences -->
		<xsl:param name="xpath" /> <!-- contains an XPath query relative to the current node, to be used with xml document -->
		
		<xsl:param name="node" />
		
		<xsl:choose>
			<!-- if called from forward, call it again with with $node as calling node -->
			<xsl:when test="name() = 'xsl:template'">
				<xsl:for-each select="$node">
					<xsl:call-template name="handle-extensions-forwardee">
						<xsl:with-param name="root-document" select="$root-document" />
						<xsl:with-param name="root-path" select="$root-path" />
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						
						<xsl:with-param name="namespace-documents" select="$namespace-documents" />
						<xsl:with-param name="namespace-prefix" select="$namespace-prefix" />
						
						<xsl:with-param name="base" select="$base" />
						<xsl:with-param name="disabled" select="$disabled" />
						<xsl:with-param name="xpath" select="$xpath" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<!-- else continue processing -->
			<xsl:otherwise>
				<xsl:call-template name="log">
					<xsl:with-param name="reference">handle-extensions-forwardee</xsl:with-param>
				</xsl:call-template>
				
				<xsl:variable name="base-suffix">
					<xsl:call-template name="get-suffix">
						<xsl:with-param name="string" select="$base" />
					</xsl:call-template>
				</xsl:variable>
				
				<!-- add inherited extensions -->
				<xsl:for-each select="$namespace-documents//*[@name=$base-suffix]/*/xs:extension">
					<xsl:call-template name="handle-extensions">
						<xsl:with-param name="root-document" select="$root-document" />
						<xsl:with-param name="root-path" select="$root-path" />
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						
						<xsl:with-param name="namespace-prefix" select="$namespace-prefix" />
						
						<xsl:with-param name="base" select="@base" />
						<xsl:with-param name="disabled" select="$disabled" />
						<xsl:with-param name="xpath" select="$xpath" />
					</xsl:call-template>
				</xsl:for-each>
				
				<!-- add added elements -->
				<xsl:apply-templates select="$namespace-documents//*[@name=$base-suffix]/*
					|$namespace-documents//*[@name=$base-suffix]/*/*/*">
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					
					<xsl:with-param name="namespace-prefix" select="$namespace-prefix" />
					
					<xsl:with-param name="disabled" select="$disabled" />
					<xsl:with-param name="xpath" select="$xpath" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>