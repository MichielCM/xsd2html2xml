<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<xsl:template name="add-style">
		<xsl:element name="style">
			<xsl:attribute name="type">text/css</xsl:attribute>
			<xsl:text>
				[hidden] {
					display: none;
				}
				section {
					margin: 5px;
				}
				label {
					display: block;
				}
				label > span {
					float: left;
					margin-right: 5px;
					min-width: 200px;
				}
				button[type='submit']:before {
					content: "OK";
				}
				button.add:before {
					content: "+ ";
				}
				button.remove:before {
					content: "-";
				}
				input[data-xsd2html2xml-duration='days'] + span:after {
					content: " (days)";
				}
				input[data-xsd2html2xml-duration='minutes'] + span:after {
					content: " (minutes)";
				}
			</xsl:text>
		</xsl:element>	
	</xsl:template>
	
</xsl:stylesheet>