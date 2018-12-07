<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<!-- handle attribute as simple element, without option for minOccurs or maxOccurs -->
	<xsl:template match="xs:attribute">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-prefix" /> <!-- contains inherited namespace prefix -->
		
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		<xsl:param name="xpath" /> <!-- contains an XPath query relative to the current node, to be used with xml document -->
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">attribute</xsl:with-param>
		</xsl:call-template>
		
		<!-- determine local namespace -->
		<xsl:variable name="local-namespace">
			<xsl:call-template name="get-namespace">
				<xsl:with-param name="namespace-prefix">
					<xsl:call-template name="get-prefix">
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						<xsl:with-param name="string" select="@name" />
						<xsl:with-param name="include-colon">true</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="default-targetnamespace">true</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<!-- treat attribute as a simple element without dynamic occurrences -->
		<xsl:call-template name="handle-simple-element">
			<xsl:with-param name="root-document" select="$root-document" />
			<xsl:with-param name="root-path" select="$root-path" />
			<xsl:with-param name="root-namespaces" select="$root-namespaces" />
			
			<xsl:with-param name="namespace-prefix" select="$namespace-prefix" />
			<xsl:with-param name="local-namespace" select="$local-namespace" />
			<xsl:with-param name="local-namespace-prefix">
				<xsl:choose>
					<!-- no prefix if attributeFormDefault is unqualified (default) -->
					<xsl:when test="not(//xs:schema/@attributeFormDefault) or //xs:schema/@attributeFormDefault = 'unqualified'">
						<xsl:text></xsl:text>
					</xsl:when>
					<!-- use prefix from root namespaces if available -->
					<xsl:when test="$root-namespaces//root-namespace[@namespace=$local-namespace]">
						<xsl:value-of select="$root-namespaces//root-namespace[@namespace=$local-namespace]/@prefix" />
					</xsl:when>
					<!-- else generate a new namespace prefix -->
					<!-- <xsl:otherwise>
						<xsl:value-of select="generate-id()" />
						<xsl:text>:</xsl:text>
					</xsl:otherwise> -->
				</xsl:choose>
			</xsl:with-param>
			
			<xsl:with-param name="id" select="@name" />
			<xsl:with-param name="description">
				<xsl:call-template name="get-description" />
			</xsl:with-param>
			<xsl:with-param name="static">true</xsl:with-param>
			<xsl:with-param name="attribute">true</xsl:with-param>
			<xsl:with-param name="disabled" select="$disabled" />
			<xsl:with-param name="xpath">
				<xsl:choose>
					<xsl:when test="not(//xs:schema/@attributeFormDefault) or //xs:schema/@attributeFormDefault = 'unqualified'">
						<!-- <xsl:value-of select="concat($xpath,'/@*[name() = &quot;',@name,'&quot;]')" /> -->
						<xsl:value-of select="concat($xpath,'/@',@name)" />
					</xsl:when>
					<xsl:otherwise>
						<!-- <xsl:value-of select="concat($xpath,'/@*[name() = &quot;',$namespace-prefix,@name,'&quot;]')" /> -->
						<xsl:value-of select="concat($xpath,'/@',$namespace-prefix,@name)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
</xsl:stylesheet>