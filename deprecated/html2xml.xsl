<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- MIT License

	Copyright (c) 2017 Michiel Meulendijk
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE. -->
	
	<xsl:output method="xml" omit-xml-declaration="no" />
	<xsl:strip-space elements="*"/>
	
	<xsl:template match="xhtml:style|xhtml:script|xhtml:legend|xhtml:span|xhtml:button|xhtml:output|xhtml:input|xhtml:select|xhtml:textarea" />
	
	<xsl:template match="*[@data-xsd2html2xml-type='element' and not(@style)]">
		<xsl:if test="not(ancestor::*[@style])">
			<xsl:if test="not(ancestor::*[@data-xsd2html2xml-choice]) or ancestor::*[@data-xsd2html2xml-choice]/preceding-sibling::*[1]/xhtml:input[@checked]">
				<xsl:element name="{@data-xsd2html2xml-name}" namespace="{@data-xsd2html2xml-namespace}">
					<xsl:for-each select="*[@data-xsd2html2xml-type='attribute']">
						<xsl:choose>
							<xsl:when test="xhtml:input[@type='checkbox']/@checked">
								<xsl:attribute name="{@data-xsd2html2xml-name}">true</xsl:attribute>
							</xsl:when>
							<xsl:when test="xhtml:input[@type='checkbox']">
								<xsl:attribute name="{@data-xsd2html2xml-name}">false</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="xhtml:input/@value|xhtml:textarea/text()|xhtml:select/xhtml:option[@selected]/text()">
									<xsl:attribute name="{@data-xsd2html2xml-name}">
										<xsl:value-of select="xhtml:input/@value|xhtml:textarea/text()|xhtml:select/xhtml:option[@selected]/text()" />
									</xsl:attribute>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
					
					<xsl:choose>
						<xsl:when test="*[@data-xsd2html2xml-type='cdata']/xhtml:input[@type='checkbox']/@checked|xhtml:input[@type='checkbox']/@checked">
							<xsl:text>true</xsl:text>
						</xsl:when>
						<xsl:when test="*[@data-xsd2html2xml-type='cdata']/xhtml:input[@type='checkbox']|xhtml:input[@type='checkbox']">
							<xsl:text>false</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="*[@data-xsd2html2xml-type='cdata']/xhtml:input/@value|xhtml:input/@value|*[@data-xsd2html2xml-type='cdata']/xhtml:textarea/text()|xhtml:textarea/text()|xhtml:select/xhtml:option[@selected]/@value|*[@data-xsd2html2xml-type='cdata']/xhtml:select/xhtml:option[@selected]/@value">
								<xsl:value-of select="*[@data-xsd2html2xml-type='cdata']/xhtml:input/@value|xhtml:input/@value|*[@data-xsd2html2xml-type='cdata']/xhtml:textarea/text()|xhtml:textarea/text()|xhtml:select/xhtml:option[@selected]/@value|*[@data-xsd2html2xml-type='cdata']/xhtml:select/xhtml:option[@selected]/@value" />
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
					
					<xsl:apply-templates />
				</xsl:element>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
