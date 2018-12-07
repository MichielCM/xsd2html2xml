<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<xsl:template name="has-prefix">
		<xsl:param name="string" />
		
		<xsl:value-of select="contains($string, ':')" />
	</xsl:template>
	
	<!-- Returns the prefix of a string -->
	<!-- Useful for extracting namespace prefixes -->
	<xsl:template name="get-prefix">
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="default-empty">true</xsl:param>
		<xsl:param name="exclude-schema">true</xsl:param>
		<xsl:param name="include-colon">false</xsl:param>
		<xsl:param name="string" />
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">get-prefix</xsl:with-param>
		</xsl:call-template>
		
		<xsl:choose>
			<xsl:when test="contains($string, ':')">
				<xsl:if test="not($exclude-schema = 'true' and (contains($string, ':') and starts-with($string, $root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix)))">
					<xsl:choose>
						<xsl:when test="$include-colon = 'true'">
							<xsl:value-of select="substring-before($string, ':')" /><xsl:text>:</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="substring-before($string, ':')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="not($default-empty = 'true')">
					<xsl:value-of select="$string" />
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Returns the substring of a string after its prefix -->
	<!-- Useful for stripping names off their namespace prefixes -->
	<xsl:template name="get-suffix">
		<xsl:param name="string" />
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">get-suffix</xsl:with-param>
		</xsl:call-template>
		
		<xsl:choose>
			<xsl:when test="contains($string, ':')">
				<xsl:value-of select="substring-after($string, ':')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$string" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>