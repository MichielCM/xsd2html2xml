<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<xsl:template name="add-initial-calls">
		<xsl:element name="script">
			<xsl:attribute name="type">text/javascript</xsl:attribute>
			<xsl:text disable-output-escaping="yes">
				var globalValuesMap = [];
				
				document.addEventListener("DOMContentLoaded",
					function() {
						/* INITIAL CALLS */
						
						addHiddenFields();
						xmlToHTML(document);
						updateIdentifiers();
						setDynamicValues();
						setValues();
						ensureMinimum();
						
						document.querySelectorAll("[data-xsd2html2xml-filled='true']").forEach(function(o) {
							if (o.closest("[data-xsd2html2xml-choice]")) {
								var node = o.closest("[data-xsd2html2xml-choice]").previousElementSibling;
								while (node) {
									if (!node.hasAttribute("data-xsd2html2xml-choice")) {
										node.querySelector("input[type='radio']").click();
										break;										
									} else {
										node = node.previousElementSibling;
									};
								};
							};
						});
					}
				);
			</xsl:text>
		</xsl:element>	
	</xsl:template>
	
</xsl:stylesheet>