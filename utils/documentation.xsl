<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<!-- Returns an element's description from xs:annotation/xs:documentation if it exists, @value in the case of enumerations, or @name otherwise -->
	<xsl:template name="get-description">
		<!-- get corresponding documentation element -->
		<xsl:variable name="documentation">
			<xsl:call-template name="get-documentation" />
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$documentation = ''">
				<xsl:choose>
					<!-- if no documentation element exists, return @name -->
					<xsl:when test="@name">
						<xsl:value-of select="@name" />
					</xsl:when>
					<!-- or @ref, in case of groups -->
					<xsl:when test="@ref">
						<xsl:call-template name="get-suffix">
							<xsl:with-param name="string" select="@ref" />
						</xsl:call-template>
					</xsl:when>
					<!-- or @value -->
					<xsl:when test="@value">
						<xsl:value-of select="@value" />
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<!-- return documentation content if it exists -->
			<xsl:otherwise>
				<xsl:value-of select="$documentation" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Returns an element's description from xs:annotation/xs:documentation if it exists, taking into account the specified preferred language -->
	<xsl:template name="get-documentation">
		<xsl:if test="$config-documentation = 'true'">
			<xsl:choose>
				<xsl:when test="not($config-language = '') and xs:annotation/xs:documentation[@xml:lang=$config-language]">
					<xsl:value-of select="xs:annotation/xs:documentation[@xml:lang=$config-language]/text()" />
				</xsl:when>
				<xsl:when test="not($config-language = '') and xs:annotation/xs:documentation[not(@xml:lang)]">
					<xsl:value-of select="xs:annotation/xs:documentation[not(@xml:lang)]/text()" />
				</xsl:when>
				<xsl:when test="$config-language = '' and xs:annotation/xs:documentation[not(@xml:lang)]">
					<xsl:value-of select="xs:annotation/xs:documentation[not(@xml:lang)]/text()" />
				</xsl:when>
				<xsl:when test="$config-language = '' and xs:annotation/xs:documentation">
					<xsl:value-of select="xs:annotation/xs:documentation/text()" />
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<!-- Returns predetermined values for xs:duration specifics found in patterns -->
	<xsl:template name="get-duration-info">
		<xsl:param name="type" />
		<xsl:param name="pattern" />
		
		<xsl:choose>
			<xsl:when test="contains($pattern, 'T') and contains($pattern, 'S')">
				<xsl:if test="$type = 'prefix'">PT</xsl:if>
				<xsl:if test="$type = 'abbreviation'">S</xsl:if>
				<xsl:if test="$type = 'description'">seconds</xsl:if>
			</xsl:when>
			<xsl:when test="contains($pattern, 'T') and contains($pattern, 'M')">
				<xsl:if test="$type = 'prefix'">PT</xsl:if>
				<xsl:if test="$type = 'abbreviation'">M</xsl:if>
				<xsl:if test="$type = 'description'">minutes</xsl:if>
			</xsl:when>
			<xsl:when test="contains($pattern, 'T') and contains($pattern, 'H')">
				<xsl:if test="$type = 'prefix'">PT</xsl:if>
				<xsl:if test="$type = 'abbreviation'">H</xsl:if>
				<xsl:if test="$type = 'description'">hours</xsl:if>
			</xsl:when>
			<xsl:when test="not(contains($pattern, 'T')) and contains($pattern, 'D')">
				<xsl:if test="$type = 'prefix'">P</xsl:if>
				<xsl:if test="$type = 'abbreviation'">D</xsl:if>
				<xsl:if test="$type = 'description'">days</xsl:if>
			</xsl:when>
			<xsl:when test="not(contains($pattern, 'T')) and contains($pattern, 'M')">
				<xsl:if test="$type = 'prefix'">P</xsl:if>
				<xsl:if test="$type = 'abbreviation'">M</xsl:if>
				<xsl:if test="$type = 'description'">months</xsl:if>
			</xsl:when>
			<xsl:when test="not(contains($pattern, 'T')) and contains($pattern, 'Y')">
				<xsl:if test="$type = 'prefix'">P</xsl:if>
				<xsl:if test="$type = 'abbreviation'">Y</xsl:if>
				<xsl:if test="$type = 'description'">years</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$type = 'prefix'">P</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>