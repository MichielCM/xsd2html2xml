<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<!-- handles groups existing of other elements; note that 'ref' is used as id overriding local-name() -->
	<xsl:template match="xs:group[@ref]">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="choice" /> <!-- handles xs:choice elements and descendants; contains a unique ID for radio buttons of the same group to share -->
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		<xsl:param name="xpath" /> <!-- contains an XPath query relative to the current node, to be used with xml document -->
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">xs:group[@ref]</xsl:with-param>
		</xsl:call-template>
		
		<!-- forward -->
		<xsl:call-template name="forward">
			<xsl:with-param name="stylesheet" select="$group-stylesheet" />
			<xsl:with-param name="template">group-ref-forwardee</xsl:with-param>
			
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
					<xsl:with-param name="string" select="@ref" />
					<xsl:with-param name="include-colon">true</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			
			<xsl:with-param name="ref" select="@ref" />
			<xsl:with-param name="min-occurs" select="@minOccurs" />
			<xsl:with-param name="max-occurs" select="@maxOccurs" />
			<xsl:with-param name="choice" select="$choice" />
			<xsl:with-param name="disabled" select="$disabled" />
			<xsl:with-param name="xpath" select="$xpath" />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="group-ref-forwardee" match="xsl:template[@name = 'group-ref-forwardee']">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		<xsl:param name="namespace-prefix" /> <!-- contains inherited namespace prefix -->
		
		<xsl:param name="ref" /> <!-- contains element reference -->
		<xsl:param name="min-occurs" /> <!-- contains @minOccurs attribute (for referenced elements) -->
		<xsl:param name="max-occurs" /> <!-- contains @maxOccurs attribute (for referenced elements) -->
		<xsl:param name="choice" /> <!-- handles xs:choice elements and descendants; contains a unique ID for radio buttons of the same group to share -->
		<xsl:param name="disabled" /> <!-- is used to disable elements that are copies for additional occurrences -->
		<xsl:param name="xpath" /> <!-- contains an XPath query relative to the current node, to be used with xml document -->
		
		<xsl:param name="node" />
		
		<xsl:choose>
			<!-- if called from forward, call it again with with $node as calling node -->
			<xsl:when test="name() = 'xsl:template'">
				<xsl:for-each select="$node">
					<xsl:call-template name="group-ref-forwardee">
						<xsl:with-param name="root-document" select="$root-document" />
						<xsl:with-param name="root-path" select="$root-path" />
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						
						<xsl:with-param name="namespace-documents" select="$namespace-documents" />
						<xsl:with-param name="namespace-prefix" select="$namespace-prefix" />
						
						<xsl:with-param name="ref" select="$ref" />
						<xsl:with-param name="min-occurs" select="$min-occurs" />
						<xsl:with-param name="max-occurs" select="$max-occurs" />
						<xsl:with-param name="choice" select="$choice" />
						<xsl:with-param name="disabled" select="$disabled" />
						<xsl:with-param name="xpath" select="$xpath" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<!-- else continue processing -->
			<xsl:otherwise>
				<xsl:call-template name="log">
					<xsl:with-param name="reference">xs:group[@ref]-forwardee</xsl:with-param>
				</xsl:call-template>
				
				<!-- add radio button if $choice is specified -->
				<xsl:if test="not($choice = '') and not($choice = 'true')">
					<xsl:call-template name="add-choice-button">
						<!-- $choice contains a unique id and is used for the options name -->
						<xsl:with-param name="name" select="$choice" />
						<xsl:with-param name="description">
							<xsl:value-of select="count(preceding-sibling::*) + 1" />
						</xsl:with-param>
						<xsl:with-param name="disabled" select="$disabled" />
					</xsl:call-template>
				</xsl:if>
				
				<xsl:call-template name="handle-complex-elements">
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
					<xsl:with-param name="namespace-prefix" select="$namespace-prefix" />
					
					<xsl:with-param name="id" select="$ref" />
					<xsl:with-param name="min-occurs" select="$min-occurs" />
					<xsl:with-param name="max-occurs" select="$max-occurs" />
					<xsl:with-param name="simple">false</xsl:with-param>
					<xsl:with-param name="choice">
						<xsl:if test="not($choice = '')">true</xsl:if>
					</xsl:with-param>
					<xsl:with-param name="disabled" select="$disabled" />
					<xsl:with-param name="reference">true</xsl:with-param>
					<xsl:with-param name="xpath" select="$xpath" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>