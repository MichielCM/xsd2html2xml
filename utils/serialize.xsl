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
	    <xsl:value-of select="."/>
	    <xsl:text>"</xsl:text>
	</xsl:template>
	
	<!-- match content -->
	<xsl:template match="text()" mode="serialize">
	    <xsl:value-of select="."/>
	</xsl:template>
	
</xsl:stylesheet>