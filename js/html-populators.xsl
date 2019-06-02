<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<xsl:template name="add-html-populators">
		<xsl:element name="script">
			<xsl:attribute name="type">text/javascript</xsl:attribute>
			<xsl:text disable-output-escaping="yes">
				/* HTML POPULATORS */
				
				var addHiddenFields = function() {
					document.querySelectorAll("[data-xsd2html2xml-min], [data-xsd2html2xml-max]").forEach(function(o) {
						//add hidden element
						var newNode = o.previousElementSibling.cloneNode(true);
						
						newNode.setAttribute("hidden", "");
						
						newNode.querySelectorAll("input, textarea, select").forEach(function(p) {
							p.setAttribute("disabled", "");
						});
						
						o.parentElement.insertBefore(
							newNode, o
						);
					});
				};
				
				var ensureMinimum = function() {
					document.querySelectorAll("[data-xsd2html2xml-min], [data-xsd2html2xml-max]").forEach(function(o) {
						//add minimum number of elements
						if (o.hasAttribute("data-xsd2html2xml-min")) {
							//if no minimum, remove element
							if (o.getAttribute("data-xsd2html2xml-min") === "0"
								//check for input elements existing to handle empty elements
								&amp;&amp; o.previousElementSibling.previousElementSibling.querySelector("input, textarea, select")
								//check if element has been populated with data from an xml document
								&amp;&amp; !o.previousElementSibling.previousElementSibling.querySelector("input, textarea, select").hasAttribute("data-xsd2html2xml-filled")) {
								clickRemoveButton(
									o.parentElement.children[0].querySelector("legend &gt; button.remove, span &gt; button.remove")
								);
							//if there is only one allowed element that has been filled, disable the button
							} else if (o.getAttribute("data-xsd2html2xml-max") === "1"
								//check for input elements existing to handle empty elements
								&amp;&amp; o.previousElementSibling.previousElementSibling.querySelector("input, textarea, select")
								//check if element has been populated with data from an xml document
								&amp;&amp; o.previousElementSibling.previousElementSibling.querySelector("input, textarea, select").hasAttribute("data-xsd2html2xml-filled")) {
								o.setAttribute("disabled", "disabled");
							//else, add up to minimum number of elements
							} else {
								var remainder = o.getAttribute("data-xsd2html2xml-min") - (o.parentNode.children.length - 2);
								
								for (i=0; i&lt;remainder; i++) {
									clickAddButton(o);
								};
							};
						};
					});
				};
				
				var xmlToHTML = function(root) {
					var xmlDocument;
					
					//check if form was generated from an XML document 
					if (document.querySelector("meta[name='generator'][content='XSD2HTML2XML v3: https://github.com/MichielCM/xsd2html2xml']").getAttribute("data-xsd2html2xml-source")) {
						//parse xml document from attribute
						xmlDocument = new DOMParser().parseFromString(
							document.querySelector("meta[name='generator'][content='XSD2HTML2XML v3: https://github.com/MichielCM/xsd2html2xml']").getAttribute("data-xsd2html2xml-source"),
							"application/xml"
						);
						
						//start parsing nodes, providing the root node and the corresponding document element
						parseNode(
							xmlDocument.childNodes[0],
							document.querySelector("[data-xsd2html2xml-xpath = '/".concat(xmlDocument.childNodes[0].nodeName).concat("']"))
						);
					};
				};
				
				var setValue = function(element, value) {
					element.querySelector("input, textarea, select").setAttribute("data-xsd2html2xml-filled", "true");
					
					if (element.querySelector("input") !== null) {
						if (element.querySelector("input").getAttribute("data-xsd2html2xml-primitive") === "boolean") {
							if (value === "true") {
								element.querySelector("input").setAttribute("checked", "checked");
							};
						} else {
							element.querySelector("input").setAttribute("value", value);
						};
						
						if (element.querySelector("input").getAttribute("type") === "file") {
							element.querySelector("input").removeAttribute("required");
							element.querySelector("input").setAttribute("data-xsd2html2xml-required", "true");
						};
					};
					
					if (element.querySelector("textarea") !== null) {
						element.querySelector("textarea").textContent = value;
					};
					
					if (element.querySelector("select") !== null) {
						if (element.querySelector("select").getAttribute("data-xsd2html2xml-primitive") === "idref"
							|| element.querySelector("select").getAttribute("data-xsd2html2xml-primitive") === "idrefs") {
							globalValuesMap.push({
								object: element.querySelector("select"),
								values: value.split(/\s+/)
							});
							/*var values = value.split(/\\s+/);
							for (var i=0; i&lt;values.length; i++) {
								element.querySelector("select option[value = '".concat(values[i]).concat("']")).setAttribute("selected", "selected");
							}*/
						} else {
							element.querySelector("select option[value = '".concat(value).concat("']")).setAttribute("selected", "selected");
						}
					};
				};
				
				var parseNode = function(node, element) {
					//iterate through the node's attributes and fill them out
					for (var i=0; i&lt;node.attributes.length; i++) {
						var attribute = element.querySelector(
							"[data-xsd2html2xml-xpath = '".concat(
								element.getAttribute("data-xsd2html2xml-xpath").concat(
									"/@".concat(node.attributes[i].nodeName)
									//"/@*[name() = \"".concat(node.attributes[i].nodeName).concat("\"]")
								)
							).concat("']")
						);
						
						if (attribute !== null) {
							setValue(attribute, node.attributes[i].nodeValue);
						};
					};
					
					//if there is only one (non-element) node, it must contain the value; note: this will not work for potential mixed="true" support
					if (node.childNodes.length === 1 &amp;&amp; node.childNodes[0].nodeType === Node.TEXT_NODE) {
						//in the case of complexTypes with simpleContents, select the sub-element that actually contains the input element
						if (element.querySelectorAll("[data-xsd2html2xml-xpath='".concat(element.getAttribute("data-xsd2html2xml-xpath")).concat("']")).length &gt; 0) {
							setValue(element.querySelector("[data-xsd2html2xml-xpath='".concat(element.getAttribute("data-xsd2html2xml-xpath")).concat("']")), node.childNodes[0].nodeValue);
						} else {
							setValue(element, node.childNodes[0].nodeValue);
						};
					//else, iterate through the children
					} else {
						var previousChildName;
						
						for (var i=0; i&lt;node.childNodes.length; i++) {
							var childNode = node.childNodes[i];
							
							if (childNode.nodeType === Node.ELEMENT_NODE) {
								//find the corresponding element
								var childElement = element.querySelector(
									"[data-xsd2html2xml-xpath = '".concat(
										element.getAttribute("data-xsd2html2xml-xpath").concat(
											"/".concat(childNode.nodeName)
											//"/*[name() = \"".concat(childNode.nodeName).concat("\"]")
										)
									).concat("']")
								);
								
								//if there is an add-button (and it is not the first child node being parsed), add an element
								var button;
								
								if (childElement.parentElement.lastElementChild.nodeName.toLowerCase() === "button") {
									button = childElement.parentElement.lastElementChild;
								} else if (childElement.parentElement.parentElement.parentElement.lastElementChild.nodeName.toLowerCase() === "button"
									&amp;&amp; !childElement.parentElement.parentElement.parentElement.lastElementChild.hasAttribute("data-xsd2html2xml-element")) {
									button = childElement.parentElement.parentElement.parentElement.lastElementChild;
								};
								
								if (button !== null &amp;&amp; childNode.nodeName === previousChildName) {
									clickAddButton(button);
									
									parseNode(
										childNode,
										button.previousElementSibling.previousElementSibling
										//childElement.parentElement.lastElementChild.previousElementSibling.previousElementSibling
									);
								//else, use the already generated element
								} else {
									parseNode(
										childNode,
										childElement
									);
								};
								
								previousChildName = childNode.nodeName;
							}
						};
					}
				};
				
				var setDynamicValues = function() {
					for (var i=0; i&lt;globalValuesMap.length; i++) {
						for (var j=0; j&lt;globalValuesMap[i].values.length; j++) {
							globalValuesMap[i].object.querySelector(
								"select option[value = '".concat(globalValuesMap[i].values[j]).concat("']")
							).setAttribute("selected", "selected");
						}
					}
				};
			</xsl:text>
		</xsl:element>	
	</xsl:template>
	
</xsl:stylesheet>