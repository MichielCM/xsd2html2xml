<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<xsl:template name="add-style">
		<xsl:element name="style">
			<xsl:attribute name="type">text/css</xsl:attribute>
			<xsl:text>
				form.xsd2html2xml [hidden] {
					display: none;
				}
				form.xsd2html2xml section {
					margin: 5px;
				}
				form.xsd2html2xml label {
					display: block;
				}
				form.xsd2html2xml label > span {
					float: left;
					margin-right: 5px;
					min-width: 200px;
				}
				form.xsd2html2xml button[type='submit']:before {
					content: "OK";
				}
				form.xsd2html2xml button.add:before {
					content: "+ ";
				}
				form.xsd2html2xml button.remove:before {
					content: "-";
				}
				form.xsd2html2xml input[data-xsd2html2xml-duration='days'] + span:after {
					content: " (days)";
				}
				form.xsd2html2xml input[data-xsd2html2xml-duration='minutes'] + span:after {
					content: " (minutes)";
				}
			</xsl:text>
		</xsl:element>	
	</xsl:template>
	
</xsl:stylesheet>