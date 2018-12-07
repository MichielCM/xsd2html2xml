<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<!-- adds a remove button for dynamic elements -->
	<xsl:template name="add-remove-button">
		<xsl:param name="min-occurs" /> <!-- contains @minOccurs attribute (for referenced elements) -->
		<xsl:param name="max-occurs" /> <!-- contains @maxOccurs attribute (for referenced elements) -->
		
		<!-- <xsl:if test="(not($min-occurs = '') or not($max-occurs = '')) and not($min-occurs = $max-occurs) and not($min-occurs = '1' and $max-occurs = '') and not($max-occurs = '1' and $min-occurs = '')"> -->
		<xsl:if test="(number($min-occurs) or $min-occurs = '0' or number($max-occurs) or $max-occurs = 'unbounded') and not($min-occurs = $max-occurs) and not($min-occurs = '1' and $max-occurs = '') and not($max-occurs = '1' and $min-occurs = '')">
			<xsl:element name="button">
				<xsl:attribute name="type">button</xsl:attribute>
				<xsl:attribute name="class">remove</xsl:attribute>
				<xsl:attribute name="onclick">clickRemoveButton(this);</xsl:attribute>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<!-- adds and add button for dynamic elements -->
	<xsl:template name="add-add-button">
		<xsl:param name="description" />
		<xsl:param name="disabled" /> <!-- indicates if the button should be disabled by default; used when the max number of maxOccurs has been reached in xml-doc -->
		<xsl:param name="min-occurs" /> <!-- contains @minOccurs attribute (for referenced elements) -->
		<xsl:param name="max-occurs" /> <!-- contains @maxOccurs attribute (for referenced elements) -->
		
		<!-- <xsl:if test="(not($min-occurs = '') or not($max-occurs = '')) and not($min-occurs = $max-occurs) and not($min-occurs = '1' and $max-occurs = '') and not($max-occurs = '1' and $min-occurs = '')"> -->
		<xsl:if test="(number($min-occurs) or $min-occurs = '0' or number($max-occurs) or $max-occurs = 'unbounded') and not($min-occurs = $max-occurs) and not($min-occurs = '1' and $max-occurs = '') and not($max-occurs = '1' and $min-occurs = '')">
			<xsl:element name="button">
				<xsl:attribute name="type">button</xsl:attribute>
				<xsl:attribute name="class">add</xsl:attribute>
				<xsl:if test="$disabled = 'true'">
					<xsl:attribute name="disabled">disabled</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="data-xsd2html2xml-min">
					<xsl:choose>
						<xsl:when test="$min-occurs = '0' or number($min-occurs)"><xsl:value-of select="$min-occurs" /></xsl:when>
						<xsl:otherwise>1</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="data-xsd2html2xml-max">
					<xsl:choose>
						<xsl:when test="$max-occurs = '0' or number($max-occurs) or $max-occurs = 'unbounded'"><xsl:value-of select="$max-occurs" /></xsl:when>
						<xsl:otherwise>1</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="onclick">clickAddButton(this);</xsl:attribute>
				<xsl:value-of select="$description" />
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<!-- adds a radio button for choice groups -->
	<xsl:template name="add-choice-button">
		<xsl:param name="name" />
		<xsl:param name="description" />
		<xsl:param name="disabled">false</xsl:param>
		
		<xsl:element name="label">
			<xsl:element name="input">
				<xsl:attribute name="type">radio</xsl:attribute>
				<xsl:attribute name="name">
					<xsl:value-of select="$name"/>
				</xsl:attribute>
				<xsl:attribute name="required">required</xsl:attribute>
				<xsl:if test="$disabled = 'true'">
					<xsl:attribute name="disabled">disabled</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="onclick">clickRadioInput(this, '<xsl:value-of select="$name" />');</xsl:attribute>
				<xsl:attribute name="data-xsd2html2xml-description">
					<xsl:value-of select="$description" />
				</xsl:attribute>
			</xsl:element>
			
			<xsl:element name="span">
				<xsl:value-of select="$description" />
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:stylesheet>