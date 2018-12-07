<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<xsl:template name="add-value-fixers">
		<xsl:element name="script">
			<xsl:attribute name="type">text/javascript</xsl:attribute>
			<xsl:text disable-output-escaping="yes">
				/* VALUE FIXERS */
				
				var setValues = function() {
					/* specifically set values on ranges */
					document.querySelectorAll("[type='range']").forEach(function(o) {
						if (o.getAttribute("value")) {
							o.value = o.getAttribute("value").replace(/\D/g, "");
						} else if (o.getAttribute("min")) {
							o.value = o.getAttribute("min");
						} else if (o.getAttribute("max")) {
							o.value = o.getAttribute("max");
						} else {
							o.value = 0;
							o.onchange();
						};
						
						o.previousElementSibling.textContent = o.value;
					});
					
					/* specifically set values on datepickers */
					document.querySelectorAll("[data-xsd2html2xml-primitive='gday']").forEach(function(o) {
						if (o.getAttribute("value")) {
							o.value = o.getAttribute("value").replace(/-+0?/g, "");
						}
					});
					document.querySelectorAll("[data-xsd2html2xml-primitive='gmonth']").forEach(function(o) {
						if (o.getAttribute("value")) {
							o.value = o.getAttribute("value").replace(/-+0?/g, "");
						}
					});
					document.querySelectorAll("[data-xsd2html2xml-primitive='gmonthday']").forEach(function(o) {
						if (o.getAttribute("value")) {
							o.value = new Date().getFullYear().toString().concat(o.getAttribute("value").substring(1));
						}
					});
				};
			</xsl:text>
		</xsl:element>	
	</xsl:template>
	
</xsl:stylesheet>