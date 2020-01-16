<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<xsl:template name="generate-textarea">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		
		<xsl:param name="description" /> <!-- contains preferred description for element -->
		<xsl:param name="min-length" /> <!-- minLength attribute used to determine if generated element should be optional -->
		<xsl:param name="attribute" /> <!-- boolean indicating whether or not node is an attribute -->
		<xsl:param name="disabled" /> <!-- boolean indicating whether or not generated element should be disabled -->
		<xsl:param name="whitespace" /> <!-- whitespace rule to be applied to element input -->
		
		<xsl:element name="textarea">
			<xsl:attribute name="onchange">
				<xsl:text>this.textContent = this.value</xsl:text><xsl:if test="$whitespace = 'replace'">.replace(/\s/g, " ")</xsl:if><xsl:if test="$whitespace = 'collapse'">.replace(/\s+/g, " ").trim()</xsl:if>
			</xsl:attribute>
			
			<!-- attribute can have optional use=required values; normal elements are always required -->
			<xsl:choose>
				<xsl:when test="$attribute = 'true'">
					<xsl:if test="@use = 'required'">
						<xsl:attribute name="required">required</xsl:attribute>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$min-length = '' or $min-length > 0">
					<xsl:attribute name="required">required</xsl:attribute>
				</xsl:when>
			</xsl:choose>
			
			<!-- attributes can be prohibited, rendered as readonly -->
			<xsl:if test="@use = 'prohibited'">
				<xsl:attribute name="readonly">readonly</xsl:attribute>
			</xsl:if>
			
			<xsl:attribute name="data-xsd2html2xml-description">
				<xsl:value-of select="$description" />
			</xsl:attribute>
			
			<xsl:call-template name="set-type-specifics">
				<xsl:with-param name="root-document" select="$root-document" />
				<xsl:with-param name="root-path" select="$root-path" />
				<xsl:with-param name="root-namespaces" select="$root-namespaces" />
				
				<xsl:with-param name="namespace-documents" select="$namespace-documents" />
			</xsl:call-template>
			
			<!-- disabled elements are used to omit invisible placeholders from inclusion in the validation and generated xml data -->
			<xsl:if test="$disabled = 'true'">
				<xsl:attribute name="disabled">disabled</xsl:attribute>
			</xsl:if>
			
			<!-- populate the element if there is corresponding data, or fill it with a fixed or default value -->
			<xsl:choose>
				<xsl:when test="@fixed">
					<xsl:attribute name="readonly">readonly</xsl:attribute>
					<xsl:value-of select="@fixed"/>
				</xsl:when>
				<xsl:when test="@default">
					<xsl:value-of select="@default"/>
				</xsl:when>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
</xsl:stylesheet>