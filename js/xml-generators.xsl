<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<xsl:template name="add-xml-generators">
		<xsl:element name="script">
			<xsl:attribute name="type">text/javascript</xsl:attribute>
			<xsl:text disable-output-escaping="yes">
				/* XML GENERATORS */
				
				var htmlToXML = function(root) {
					var namespaces = [];
				    var prefixes = [];
				    
				    document.querySelectorAll("[data-xsd2html2xml-namespace]:not([data-xsd2html2xml-namespace=''])").forEach(function(o) {
				    	if (namespaces.indexOf(
				    		o.getAttribute("data-xsd2html2xml-namespace")
				    	) == -1) {
					    	namespaces.push(
					    		o.getAttribute("data-xsd2html2xml-namespace")
					    	);
					    	
					    	prefixes.push(
					    		o.getAttribute("data-xsd2html2xml-name").substring(
				    				0, o.getAttribute("data-xsd2html2xml-name").indexOf(":")
				    			)
				    		);
				    	}
				    });
				    
				    var namespaceString = "";
				    
				    namespaces.forEach(function(o,i) {
				    	namespaceString = namespaceString.concat(
				    		"xmlns".concat(
				    			(prefixes[i] == "" ? "=" : ":".concat(prefixes[i].concat("=")))
				    		).concat(
				    			"\"".concat(namespaces[i]).concat("\" ")
				    		)
				    	)
				    });
				    
				    return String.fromCharCode(60).concat("?xml version=\"1.0\"?").concat(String.fromCharCode(62)).concat(getXML(root, false, namespaceString.trim()));
				};
				
				var getXML = function(parent, attributesOnly, namespaceString) {
				    var xml = "";
				    var children = [].slice.call(parent.children);
				    children.forEach(function(o) {
				        if (!o.hasAttribute("hidden")) {
				            switch (o.getAttribute("data-xsd2html2xml-type")) {
				                case "element":
				                    if (!attributesOnly) xml = xml.concat(String.fromCharCode(60)).concat(o.getAttribute("data-xsd2html2xml-name")).concat(getXML(o, true)).concat(String.fromCharCode(62)).concat(function() {
				                        if (o.nodeName.toLowerCase() === "label") {
				                            return getContent(o);
				                        } else return getXML(o)
				                    }()).concat(String.fromCharCode(60)).concat("/").concat(o.getAttribute("data-xsd2html2xml-name")).concat(String.fromCharCode(62));
				                    break;
				                case "attribute":
				                	if (attributesOnly)
										if (getContent(o)
											|| (o.getElementsByTagName("input").length > 0
												? o.getElementsByTagName("input")[0].getAttribute("data-xsd2html2xml-primitive").toLowerCase() === "boolean"
												: false
											))
											xml = xml.concat(" ").concat(o.getAttribute("data-xsd2html2xml-name")).concat("=\"").concat(getContent(o)).concat("\"");
				                    break;
				                case "content":
				                    if (!attributesOnly) xml = xml.concat(getContent(o));
				                    break;
				                default:
				                    if (!attributesOnly) {
				                    	if (!o.getAttribute("data-xsd2html2xml-choice"))
				                    		xml = xml.concat(getXML(o));
				                    		
				                    	if (o.getAttribute("data-xsd2html2xml-choice")) {
				                    		var node = o.previousElementSibling;
				                    		while (node.hasAttribute("data-xsd2html2xml-choice")) {
				                    			node = node.previousElementSibling;
				                    		};
				                    		
				                    		if (node.getElementsByTagName("input")[0].checked)
				                    			xml = xml.concat(getXML(o));
				                    	};
				                    }
				                    break;
				            }
				        }
				    });
				    
				    if (namespaceString) {
				    	xml = xml.substring(0, xml.indexOf(String.fromCharCode(62))).concat(" ").concat(namespaceString).concat(xml.substring(xml.indexOf(String.fromCharCode(62))));
				    }
				    
				    return xml;
				};
				
				var getContent = function(node) {
				    if (node.getElementsByTagName("input").length != 0) {
				        switch (node.getElementsByTagName("input")[0].getAttribute("type").toLowerCase()) {
				            case "checkbox":
				                return node.getElementsByTagName("input")[0].checked;
				            case "file":
				            case "range":
				            case "date":
				            case "time":
				            case "datetime-local":
				            	return node.getElementsByTagName("input")[0].getAttribute("value");
				            default:
				            	switch (node.getElementsByTagName("input")[0].getAttribute("data-xsd2html2xml-primitive").toLowerCase()) {
						            case "gday":
						            case "gmonth":
						            case "gmonthday":
						            case "gyear":
						            case "gyearmonth":
						            	return node.getElementsByTagName("input")[0].getAttribute("value");
						            default:
						            	return escapeContent(node.getElementsByTagName("input")[0].value);
				            	}
				        }
				    } else if (node.getElementsByTagName("select").length != 0) {
						if (node.getElementsByTagName("select")[0].hasAttribute("multiple")) {
							return [].map.call(node.getElementsByTagName("select")[0].selectedOptions, function(o) {
								return o.getAttribute("value");
							}).join(" ");
						} else if (node.getElementsByTagName("select")[0].getElementsByTagName("option")[node.getElementsByTagName("select")[0].selectedIndex].hasAttribute("value")) {
							return node.getElementsByTagName("select")[0].value;
						} else {
							return null;
						}
				    } else if (node.getElementsByTagName("textarea").length != 0) {
				    	return node.getElementsByTagName("textarea")[0].value;
				    }
				};

				var characterToXmlSafe = {
					"&lt;": "&amp;lt;",
					"&gt;": "&amp;gt;",
					"&amp;": "&amp;amp;",
					"\&quot;": "&amp;quot;",
					"&apos;": "&amp;apos;" /* This doesn't seem to work, so turned off in escapeContent function */
				};

				var escapeContent = function(content)
				{
					return content.replace(/[&lt;&gt;&amp;&quot;]/g, function(character)
					{
						return characterToXmlSafe[character];
					});
				}
			</xsl:text>
		</xsl:element>	
	</xsl:template>
	
</xsl:stylesheet>