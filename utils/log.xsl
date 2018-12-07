<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<xsl:template name="log">
		<xsl:param name="reference" />
		
		<xsl:if test="contains($config-debug, 'stack')">
			<xsl:message>
				<xsl:text>RAN </xsl:text>
				<xsl:value-of select="substring(concat($reference, '                              '), 1, 30)" />
				
				<xsl:if test="name()">
					<xsl:text> ON </xsl:text>
					<xsl:value-of select="substring(concat(name(), '                    '), 1, 20)" />
				</xsl:if>
				
				<xsl:if test="@name">
					<xsl:text> NAMED </xsl:text>
					<xsl:value-of select="substring(concat(@name, '                    '), 1, 20)" />
				</xsl:if>
				
				<xsl:if test="@ref">
					<xsl:text> REFER </xsl:text>
					<xsl:value-of select="substring(concat(@ref, '                    '), 1, 20)" />
				</xsl:if>
				
				<xsl:if test="@type">
					<xsl:text> OF TYPE </xsl:text>
					<xsl:value-of select="substring(concat(@type, '                    '), 1, 20)" />
				</xsl:if>
			</xsl:message>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="inform">
		<xsl:param name="message" />
		
		<xsl:if test="contains($config-debug, 'info')">
			<xsl:message>
				<xsl:text>INF </xsl:text>
				<xsl:value-of select="$message" />
			</xsl:message>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="throw">
		<xsl:param name="message" />
		
		<xsl:if test="contains($config-debug, 'error')">
			<xsl:message>
				<xsl:text>ERR </xsl:text>
				<xsl:value-of select="$message" />
			</xsl:message>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>