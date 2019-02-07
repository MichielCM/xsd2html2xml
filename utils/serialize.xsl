<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<!-- match root element -->
	<xsl:template match="/*" mode="serialize">
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="name()"/>
		
		<!-- add namespaces -->
		<xsl:for-each select="namespace::*">
			<xsl:text> xmlns</xsl:text>
			
			<xsl:if test="not(name() = '')">
			<xsl:text>:</xsl:text>
				<xsl:value-of select="name()" />
			</xsl:if>
			
			<xsl:text>="</xsl:text>
			<xsl:value-of select="." />
			<xsl:text>"</xsl:text>
		</xsl:for-each>
		
		<xsl:apply-templates select="@*" mode="serialize" />
		
		<xsl:text>&gt;</xsl:text>
		
		<xsl:apply-templates mode="serialize" />
		
		<xsl:text>&lt;/</xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:text>&gt;</xsl:text>
	</xsl:template>
	
	<!-- match all other elements -->
	<xsl:template match="*" mode="serialize">
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:apply-templates select="@*" mode="serialize" />
		<xsl:choose>
			<xsl:when test="node()">
				<xsl:text>&gt;</xsl:text>
				<xsl:apply-templates mode="serialize" />
				<xsl:text>&lt;/</xsl:text>
				<xsl:value-of select="name()"/>
				<xsl:text>&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> /&gt;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- match attributes -->
	<xsl:template match="@*" mode="serialize">
		<xsl:text> </xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:text>="</xsl:text>
		<xsl:call-template name="double-escape">
			<xsl:with-param name="text" select="." />
		</xsl:call-template>
		<xsl:text>"</xsl:text>
	</xsl:template>
	
	<!-- match content -->
	<xsl:template match="text()" mode="serialize">
		<xsl:call-template name="double-escape">
			<xsl:with-param name="text" select="." />
		</xsl:call-template>
	</xsl:template>

	<!-- doubly escapes text (e.g. &lt; => &amp;lt;) -->
	<xsl:template name="double-escape">
		<xsl:param name="text" />
		
		<xsl:call-template name="replace">
			<xsl:with-param name="find" select="'&lt;'" />
			<xsl:with-param name="replace" select="'&amp;lt;'" />
				<xsl:with-param name="text">
					<xsl:call-template name="replace">
						<xsl:with-param name="find" select="'&gt;'" />
						<xsl:with-param name="replace" select="'&amp;gt;'" />
						<xsl:with-param name="text">
							<xsl:call-template name="replace">
								<xsl:with-param name="find" select="'&quot;'" />
								<xsl:with-param name="replace" select="'&amp;quot;'" />
								<xsl:with-param name="text">
									<xsl:call-template name="replace">
										<xsl:with-param name="find" select='"&apos;"' />
										<xsl:with-param name="replace" select="'&amp;apos;'" />
										<xsl:with-param name="text">
											<xsl:call-template name="replace">
												<xsl:with-param name="find" select="'&amp;'" />
												<xsl:with-param name="replace" select="'&amp;amp;'" />
												<xsl:with-param name="text" select="$text" />
											</xsl:call-template>
										</xsl:with-param>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- replaces strings with replaces -->
	<xsl:template name="replace">
		<xsl:param name="text" />
		<xsl:param name="find" />
		<xsl:param name="replace" />
		
		<xsl:choose>
			<xsl:when test="contains($text, $find)">
				<xsl:value-of select="substring-before($text, $find)"/>
				<xsl:value-of select="$replace" />
				<xsl:call-template name="replace">
					<xsl:with-param name="text" select="substring-after($text, $find)"/>
					<xsl:with-param name="find" select="$find" />
					<xsl:with-param name="replace" select="$replace" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>