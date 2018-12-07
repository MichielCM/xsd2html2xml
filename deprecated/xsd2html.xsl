<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
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
	
	<xsl:strip-space elements="*"/>
	
	<!-- set method as either html or xhtml (xml). Note: if you want to process the results
	with html2xml.xsl, you need to use xhtml. Note 2: browsers won't display the form correctly if
	it does not contain a valid XHTML doctype and if it is not served with content type application/xhtml+xml -->
	<!-- <xsl:output method="xml" omit-xml-declaration="no" /> -->
	<xsl:output method="html" omit-xml-declaration="yes" indent="no" />
	
	<!-- choose the JavaScript (js) or XSLT (xslt) option for processing the form results -->
	<!-- <xsl:variable name="config-to-xml">xslt</xsl:variable> -->
	<xsl:variable name="config-xml-generator">xslt</xsl:variable>
	
	<!-- choose a JavaScript function to be called when the form is submitted.
	it should accept a string argument containing the xml or html -->
	<xsl:variable name="config-js-callback">console.log</xsl:variable>
	
	<!-- optionally specify a css stylesheet to use for the form.
	it will be inserted as a link tag inside the form element. -->
	<xsl:variable name="config-css">style.css</xsl:variable>
	
	<!-- optionally specify whether you want the span element before or after the input / select element within the label tag -->
	<!-- entering 'true' enables you to use the CSS next-sibling selector '+' to style the span based on the input's attributes -->
	<!-- use 'float: left' or something similar on the span to still make it appear before the input element -->
	<xsl:variable name="config-label-after-input">false</xsl:variable>
	
	<!-- optionally specify which annotation/documentation language (determined by xml:lang) should be used -->
	<xsl:variable name="config-language" />
	
	<!-- optionally specify text for interactive elements -->
	<xsl:variable name="config-add-button-label">+</xsl:variable>
	<xsl:variable name="config-remove-button-label">-</xsl:variable>
	<xsl:variable name="config-submit-button-label">OK</xsl:variable>
	<xsl:variable name="config-seconds">seconds</xsl:variable>
	<xsl:variable name="config-minutes">minutes</xsl:variable>
	<xsl:variable name="config-hours">hours</xsl:variable>
	<xsl:variable name="config-days">days</xsl:variable>
	<xsl:variable name="config-months">months</xsl:variable>
	<xsl:variable name="config-years">years</xsl:variable>
	
	<!-- override default matching template -->
	<xsl:template match="*"/>
	
	<!-- root match from which all other templates are invoked -->
	<xsl:template match="/xs:schema">
		<xsl:element name="form">
			<!-- disable action attribute -->
			<xsl:attribute name="action">javascript:void(0);</xsl:attribute>
			
			<!-- call JS or XSLT functions based on configuration -->
			<xsl:attribute name="onsubmit">
				<xsl:if test="$config-xml-generator='js'">
					<xsl:value-of select="$config-js-callback" />(htmlToXML(this));
				</xsl:if>
				<xsl:if test="$config-xml-generator='xslt'">
					<xsl:value-of select="$config-js-callback" />(this.outerHTML);
				</xsl:if>
			</xsl:attribute>
			
			<!-- start parsing the XSD from the top -->
			<xsl:apply-templates select="xs:element" />
			
			<!-- add submit button -->
			<xsl:element name="input">
				<xsl:attribute name="type">submit</xsl:attribute>
				<xsl:attribute name="value">
					<xsl:value-of select="$config-submit-button-label" />
				</xsl:attribute>
			</xsl:element>
			
			<!-- add optional CSS file reference -->
			<xsl:if test="$config-css">
				<xsl:element name="link">
					<xsl:attribute name="rel">stylesheet</xsl:attribute>
					<xsl:attribute name="type">text/css</xsl:attribute>
					<xsl:attribute name="href">
						<xsl:value-of select="$config-css" />
					</xsl:attribute>
				</xsl:element>
			</xsl:if>
			
			<!-- add initial scripts that run after all elements have been generated -->
			<!-- note that lt, gt, amp may not be used as operators, because of output escaping issues -->
			<xsl:element name="script">
				<xsl:attribute name="type">text/javascript</xsl:attribute>
					<xsl:text disable-output-escaping="yes">
					/* POLYFILLS */
					
					/* add .matches if not natively supported */
					if (!Element.prototype.matches)
						Element.prototype.matches = Element.prototype.msMatchesSelector || 
													Element.prototype.webkitMatchesSelector;
													
					/* add .closest if not natively supported */
					if (!Element.prototype.closest)
						Element.prototype.closest = function(s) {
							var el = this;
							do {
								if (el.nodeType !== 1) return null;
								if (el.matches(s)) return el;
								el = el.parentElement || el.parentNode;
							} while (el !== null);
							return null;
						};
					
					/* add .forEach if not natively supported */
					if (!NodeList.prototype.forEach) {
						NodeList.prototype.forEach = function(callback){
							var i = 0;
							while (i != this.length) {
								callback.apply(this, [this[i], i, this]);
								i++;
							}
						};
					}
					
					/* VALUE SETTERS */
					
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
						}
					});
					
					/* specifically set values on datepickers */
					document.querySelectorAll("[data-xsd2html2xml-primitive='xs:gday']").forEach(function(o) {
						if (o.getAttribute("value")) {
							o.value = o.getAttribute("value").replace(/-+0?/g, "");
						}
					});
					document.querySelectorAll("[data-xsd2html2xml-primitive='xs:gmonth']").forEach(function(o) {
						if (o.getAttribute("value")) {
							o.value = o.getAttribute("value").replace(/-+0?/g, "");
						}
					});
					document.querySelectorAll("[data-xsd2html2xml-primitive='xs:gmonthday']").forEach(function(o) {
						if (o.getAttribute("value")) {
							o.value = new Date().getFullYear().toString().concat(o.getAttribute("value").substring(1));
						}
					});
					
					/* EVENT HANDLERS */
					
					var clickAddButton = function(button) {
						var newNode = button.previousElementSibling.cloneNode(true);
						
						newNode.removeAttribute("style");
						
						newNode.querySelectorAll("input, select, textarea").forEach(function(o) {
							if (o.closest("[style]") == null)
								o.removeAttribute("disabled");
						});
						
						button.parentNode.insertBefore(
							newNode, button.previousElementSibling
						);
						
						if ((button.parentNode.children.length - 2) == button.getAttribute("data-xsd2html2xml-max"))
							button.setAttribute("disabled", "disabled");
					}
					
					var clickRemoveButton = function(button) {
						if ((button.closest("section").children.length - 2) == button.closest("section").lastElementChild.getAttribute("data-xsd2html2xml-min"))
							button.closest("section").lastElementChild.click();
						
						if ((button.closest("section").children.length - 2) == button.closest("section").lastElementChild.getAttribute("data-xsd2html2xml-max"))
							button.closest("section").lastElementChild.removeAttribute("disabled");
						
						button.closest("section").removeChild(
							button.closest("fieldset, label")
						);
					}
					
					var clickRadioInput = function(input, name) {
						document.querySelectorAll("[name=".concat(name).concat("]")).forEach(function(o) {
							o.removeAttribute("checked");
							var section = o.parentElement.nextElementSibling;
							
							section.querySelectorAll("input, select, textarea").forEach(function(p) {
								if (input.parentElement.nextElementSibling.contains(p)) {
									if (p.closest("[data-xsd2html2xml-choice]") === section) {
										if (p.closest("*[style]") === null)
											p.removeAttribute("disabled");
										else
											p.setAttribute("disabled", "disabled");
									}
								} else
									p.setAttribute("disabled", "disabled");
							});
						});
						input.setAttribute("checked","checked");
					}
					
					var pickFile = function(input, file, type) {
						var resetFilePicker = function(input) {
							input.removeAttribute("value");
							input.removeAttribute("type");
							input.setAttribute("type", "file");
						}
						
						var fileReader = new FileReader();
						
						fileReader.onloadend = function() {
							if (fileReader.error) {
								alert(fileReader.error);
								resetFilePicker(input);
							} else {
								input.setAttribute("value",
									(type === "xs:base64binary")
									? fileReader.result.substring(fileReader.result.indexOf(",") + 1)
									//convert base64 to base16 (hexBinary)
									: atob(fileReader.result.substring(fileReader.result.indexOf(",") + 1))
								    	.split('')
								    	.map(function (aChar) {
								    		return ('0' + aChar.charCodeAt(0).toString(16)).slice(-2);
								    	})
										.join('')
										.toUpperCase()
								);
							};
						};
						
						if(file) {
							fileReader.readAsDataURL(file);
						} else {
							resetFilePicker(input);
						}
						
						if (input.getAttribute("data-xsd2html2xml-required")) input.setAttribute("required", "required");
					}
					
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
					        if (!o.getAttribute("style")) {
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
													? o.getElementsByTagName("input")[0].getAttribute("data-xsd2html2xml-primitive").toLowerCase() === "xs:boolean"
													: false
												))
												xml = xml.concat(" ").concat(o.getAttribute("data-xsd2html2xml-name")).concat("=\"").concat(getContent(o)).concat("\"");
					                    break;
					                case "cdata":
					                    if (!attributesOnly) xml = xml.concat(getContent(o));
					                    break;
					                default:
					                    if (!attributesOnly) {
					                    	if (!o.getAttribute("data-xsd2html2xml-choice"))
					                    		xml = xml.concat(getXML(o));
					                    		
					                    	if (o.getAttribute("data-xsd2html2xml-choice"))
					                    		if (o.previousElementSibling.getElementsByTagName("input")[0].checked)
					                    			xml = xml.concat(getXML(o));
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
							            case "xs:gday":
							            case "xs:gmonth":
							            case "xs:gmonthday":
							            case "xs:gyear":
							            case "xs:gyearmonth":
							            	return node.getElementsByTagName("input")[0].getAttribute("value");
							            default:
							            	return node.getElementsByTagName("input")[0].value;
					            	}
					        }
					    } else if (node.getElementsByTagName("select").length != 0) {
					        return node.getElementsByTagName("select")[0].value;
					    } else if (node.getElementsByTagName("textarea").length != 0) {
					    	return node.getElementsByTagName("textarea")[0].value;
					    }
					}
					
					/* INITIAL CALLS */
					
					document.querySelectorAll("[data-xsd2html2xml-filled='true']").forEach(function(o) {
						if (o.closest("[data-xsd2html2xml-choice]"))
							o.closest("[data-xsd2html2xml-choice]").previousElementSibling.querySelector("input[type='radio']").click();
					});
					</xsl:text>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<!-- handle elements with type attribute; determine if they're complex or simple and process them accordingly -->
	<xsl:template match="xs:element[@type]">
		<xsl:param name="choice" /> <!-- handles xs:choice elements and descendants; contains a unique ID for radio buttons of the same group to share --> <!-- handles xs:choice elements and descendants; contains a unique ID for radio buttons of the same group to share -->
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences --> <!-- is used to disable elements that are copies for additional occurrences -->
		
		<xsl:variable name="type">
			<xsl:value-of select="@type"/>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="//xs:complexType[@name=$type]/xs:simpleContent">
				<xsl:call-template name="handle-complex-elements">
					<xsl:with-param name="simple">true</xsl:with-param>
					<xsl:with-param name="choice" select="$choice"/>
					<xsl:with-param name="disabled" select="$disabled" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="//xs:complexType[@name=$type]">
				<xsl:call-template name="handle-complex-elements">
					<xsl:with-param name="simple">false</xsl:with-param>
					<xsl:with-param name="choice" select="$choice"/>
					<xsl:with-param name="disabled" select="$disabled" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="//xs:simpleType[@name=$type]">
				<xsl:call-template name="handle-simple-elements">
					<xsl:with-param name="choice" select="$choice"/>
					<xsl:with-param name="disabled" select="$disabled" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring-before($type, ':') = 'xs'">
				<xsl:call-template name="handle-simple-elements">
					<xsl:with-param name="choice" select="$choice"/>
					<xsl:with-param name="disabled" select="$disabled" />
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- handle complex elements with simple content -->
	<xsl:template match="xs:element[xs:complexType/xs:simpleContent]">
		<xsl:param name="choice" /> <!-- handles xs:choice elements and descendants; contains a unique ID for radio buttons of the same group to share -->
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		
		<xsl:call-template name="handle-complex-elements">
			<xsl:with-param name="simple">true</xsl:with-param>
			<xsl:with-param name="choice" select="$choice"/>
			<xsl:with-param name="disabled" select="$disabled" />
		</xsl:call-template>
	</xsl:template>
	
	<!-- handles elements referencing other elements -->
	<xsl:template match="xs:element[@ref]|xs:attribute[@ref]">
		<xsl:param name="choice" /> <!-- handles xs:choice elements and descendants; contains a unique ID for radio buttons of the same group to share -->
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		
		<xsl:variable name="ref" select="@ref" />
		
		<xsl:apply-templates select="//*[@name=$ref]">
			<xsl:with-param name="choice" select="$choice"/>
			<xsl:with-param name="disabled" select="$disabled" />
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- handles groups existing of other elements; note that 'ref' is used as id overriding local-name() -->
	<xsl:template match="xs:group[@ref]">
		<xsl:param name="choice" /> <!-- handles xs:choice elements and descendants; contains a unique ID for radio buttons of the same group to share -->
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		
		<xsl:call-template name="handle-complex-elements">
			<xsl:with-param name="id" select="@ref" />
			<xsl:with-param name="simple">false</xsl:with-param>
			<xsl:with-param name="choice" select="$choice"/>
			<xsl:with-param name="disabled" select="$disabled" />
		</xsl:call-template>
	</xsl:template>
	
	<!-- handles groups existing of other attributes; note that 'ref' is used as id overriding local-name() -->
	<xsl:template match="xs:attributeGroup[@ref]">
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		
		<xsl:variable name="ref" select="@ref" />
		
		<xsl:apply-templates select="//xs:attributeGroup[@name=$ref]/xs:attribute">
			<xsl:with-param name="id" select="@ref" />
			<xsl:with-param name="disabled" select="$disabled" />
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- handle complex elements, which optionally contain simple content -->
	<!-- handle minOccurs and maxOccurs, calls handle-complex-element for further processing -->
	<xsl:template name="handle-complex-elements" match="xs:element[xs:complexType/*[not(self::xs:simpleContent)]]">
		<xsl:param name="id" select="@name" /> <!-- contains node name, or references node name in case of groups -->
		<xsl:param name="simple" /> <!-- indicates whether this complex element has simple content --> <!-- indicates if an element allows simple content -->
		<xsl:param name="choice" /> <!-- handles xs:choice elements and descendants; contains a unique ID for radio buttons of the same group to share -->
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		
		<!-- add radio button if $choice is specified -->
		<xsl:if test="not($choice = '')">
			<xsl:call-template name="add-choice-button">
				<xsl:with-param name="name" select="$choice" />
				<xsl:with-param name="description">
					<xsl:call-template name="get-description" />
				</xsl:with-param>
				<xsl:with-param name="disabled" select="$disabled" />
			</xsl:call-template>
		</xsl:if>
		
		<xsl:element name="section">
			<xsl:if test="not($choice = '')">
				<xsl:attribute name="data-xsd2html2xml-choice">true</xsl:attribute>
			</xsl:if>
			
			<xsl:call-template name="handle-complex-element">
				<xsl:with-param name="id" select="$id" />
				<xsl:with-param name="description">
					<xsl:call-template name="get-description" />
				</xsl:with-param>
				<xsl:with-param name="simple" select="$simple" />
				<xsl:with-param name="count">
					<xsl:choose>
						<xsl:when test="@minOccurs">
							<xsl:value-of select="@minOccurs" />
						</xsl:when>
						<xsl:otherwise>1</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="disabled" select="$disabled" />
			</xsl:call-template>
			
			<xsl:if test="(@minOccurs or @maxOccurs) and not(@minOccurs = @maxOccurs) and not(@minOccurs = '1' and not(@maxOccurs)) and not(@maxOccurs = '1' and not(@minOccurs))">
				<xsl:call-template name="handle-complex-element">
					<xsl:with-param name="id" select="$id"/>
					<xsl:with-param name="description">
						<xsl:call-template name="get-description" />
					</xsl:with-param>
					<xsl:with-param name="simple" select="$simple" />
					<xsl:with-param name="count">1</xsl:with-param>
					<xsl:with-param name="invisible">true</xsl:with-param>
					<xsl:with-param name="disabled">true</xsl:with-param>
				</xsl:call-template>
				
				<xsl:call-template name="add-add-button">
					<xsl:with-param name="description">
						<xsl:call-template name="get-description" />
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<!-- handle complex element -->
	<xsl:template name="handle-complex-element">
		<xsl:param name="id" select="@name" /> <!-- contains the 'name' attribute of the element -->
		<xsl:param name="description" /> <!-- contains the node's description, either @name or annotation/documentation -->
		<xsl:param name="count" select="1"/>  <!-- counts down from maxOccurs -->
		<xsl:param name="simple" /> <!-- indicates whether this complex element has simple content -->
		<xsl:param name="invisible">false</xsl:param>
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		
		<xsl:if test="$count > 0">
			<xsl:variable name="type">
				<xsl:value-of select="@type"/>
			</xsl:variable>
			
			<xsl:element name="fieldset">
				<xsl:attribute name="data-xsd2html2xml-type">
					<xsl:value-of select="local-name()" />
				</xsl:attribute>
				<xsl:attribute name="data-xsd2html2xml-name">
					<xsl:value-of select="@name" />
				</xsl:attribute>
				
				<xsl:if test="$invisible = 'true'">
					<xsl:attribute name="style">display: none;</xsl:attribute>
				</xsl:if>
				
				<xsl:element name="legend">
					<xsl:value-of select="$description" />
					<xsl:call-template name="add-remove-button" />
				</xsl:element>
				
				<!-- let child elements be handled by their own templates -->
				<xsl:variable name="ref" select="@ref"/>
				<xsl:apply-templates select="xs:complexType/xs:sequence
					|xs:complexType/xs:all
					|xs:complexType/xs:choice
					|xs:complexType/xs:attribute
					|xs:complexType/xs:attributeGroup
					|xs:complexType/xs:complexContent/xs:restriction/xs:sequence
					|xs:complexType/xs:complexContent/xs:restriction/xs:all
					|xs:complexType/xs:complexContent/xs:restriction/xs:choice
					|xs:complexType/xs:complexContent/xs:restriction/xs:attribute
					|xs:complexType/xs:complexContent/xs:restriction/xs:attributeGroup
					|xs:complexType/xs:simpleContent/xs:restriction/xs:attribute
					|xs:complexType/xs:simpleContent/xs:restriction/xs:attributeGroup
					|//xs:group[@name=$ref]/*">
					<xsl:with-param name="disabled" select="$disabled" />
					</xsl:apply-templates>
				
				<xsl:choose>
					<!-- add simple element if the element allows simpleContent -->
					<xsl:when test="$simple = 'true'">
						<xsl:call-template name="handle-simple-element">
							<xsl:with-param name="description" select="$description" />
							<xsl:with-param name="static">true</xsl:with-param>
							<xsl:with-param name="count">1</xsl:with-param>
							<xsl:with-param name="html-type">cdata</xsl:with-param>
							<xsl:with-param name="disabled" select="$disabled" />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<!-- add extensions to the element -->
						<xsl:variable name="base">
							<xsl:value-of select="*/*/xs:extension/@base
							|//xs:complexType[@name=$type]/*/xs:extension/@base" />
						</xsl:variable>
						<!-- extension base elements -->
						<xsl:apply-templates select="//*[@name=$base]/*">
							<xsl:with-param name="disabled" select="$disabled" />
						</xsl:apply-templates>
						<!-- extension added elements -->
						<xsl:apply-templates select="*/*/xs:extension/*
							|//xs:complexType[@name=$type]/*/xs:extension/*">
							<xsl:with-param name="disabled" select="$disabled" />
						</xsl:apply-templates>
						<!-- add inherited extensions; superfluous: taken care of by statements above
						<xsl:call-template name="add-extensions-recursively">
							<xsl:with-param name="disabled" select="$disabled" />
						</xsl:call-template> -->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			
			<!-- call itself with count - 1 to account for multiple occurrences -->
			<xsl:call-template name="handle-complex-element">
				<xsl:with-param name="id" select="$id"/>
				<xsl:with-param name="description" select="$description" />
				<xsl:with-param name="simple" select="$simple"/>
				<xsl:with-param name="count" select="$count - 1"/>
				<xsl:with-param name="disabled" select="$disabled" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- handle simple elements -->
	<!-- handle minOccurs and maxOccurs, calls handle-simple-element for further processing -->
	<xsl:template name="handle-simple-elements" match="xs:element[xs:simpleType]">
		<xsl:param name="id" select="@name" />
		<xsl:param name="choice" /> <!-- handles xs:choice elements and descendants; contains a unique ID for radio buttons of the same group to share -->
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		
		<xsl:if test="not($choice = '')">
			<xsl:call-template name="add-choice-button">
				<xsl:with-param name="name" select="$choice" />
				<xsl:with-param name="description">
					<xsl:call-template name="get-description" />
				</xsl:with-param>
				<xsl:with-param name="disabled" select="$disabled" />
			</xsl:call-template>
		</xsl:if>
		
		<xsl:element name="section">
			<xsl:if test="not($choice = '')">
				<xsl:attribute name="data-xsd2html2xml-choice">true</xsl:attribute>
			</xsl:if>
			
			<xsl:call-template name="handle-simple-element">
				<xsl:with-param name="id" select="$id" />
				<xsl:with-param name="description">
					<xsl:call-template name="get-description" />
				</xsl:with-param>
				<xsl:with-param name="static">false</xsl:with-param>
				<xsl:with-param name="count">
					<xsl:choose>
						<xsl:when test="@minOccurs">
							<xsl:value-of select="@minOccurs" />
						</xsl:when>
						<xsl:otherwise>1</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="disabled" select="$disabled" />
			</xsl:call-template>
			
			<!-- add another element to be used for dynamically inserted elements -->
			<xsl:if test="(@minOccurs or @maxOccurs) and not(@minOccurs = @maxOccurs) and not(@minOccurs = '1' and not(@maxOccurs)) and not(@maxOccurs = '1' and not(@minOccurs))">
				<xsl:call-template name="handle-simple-element">
					<xsl:with-param name="id" select="$id"/>
					<xsl:with-param name="description">
						<xsl:call-template name="get-description" />
					</xsl:with-param>
					<xsl:with-param name="static">false</xsl:with-param>
					<xsl:with-param name="count">1</xsl:with-param>
					<xsl:with-param name="invisible">true</xsl:with-param>
					<xsl:with-param name="disabled">true</xsl:with-param>
				</xsl:call-template>
				
				<xsl:call-template name="add-add-button">
					<xsl:with-param name="description">
						<xsl:call-template name="get-description" />
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<!-- handle attribute as simple element, without option for minOccurs or maxOccurs -->
	<xsl:template name="handle-attributes" match="xs:attribute">
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		
		<xsl:call-template name="handle-simple-element">
			<xsl:with-param name="description">
				<xsl:call-template name="get-description" />
			</xsl:with-param>
			<xsl:with-param name="static">true</xsl:with-param>
			<xsl:with-param name="count">1</xsl:with-param>
			<xsl:with-param name="attribute">true</xsl:with-param>
			<xsl:with-param name="disabled" select="$disabled" />
		</xsl:call-template>
	</xsl:template>
	
	<!-- handle simple element -->
	<xsl:template name="handle-simple-element">
		<xsl:param name="id" select="@name" />
		<xsl:param name="description" />
		<xsl:param name="count"/>
		<xsl:param name="static" /> <!-- indicates whether or not the element may be removed or is 'static' -->
		<xsl:param name="attribute">false</xsl:param> <!-- indicates if the node is an element or an attribute -->
		<xsl:param name="invisible">false</xsl:param> <!-- indicates if the generated element should be invisible, for use with occurrences -->
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		<xsl:param name="html-type" select="local-name()"/> <!-- contains the element name, or 'cdata' in the case of simple content -->
		
		<xsl:if test="$count > 0">
			<xsl:variable name="type"> <!-- holds the primive type (xs:*) with which the element type will be determined -->
				<xsl:call-template name="get-primitive-type"/>
			</xsl:variable>
			
			<xsl:element name="label">
				<!-- metadata required for compiling the xml when the form is submitted -->
				<xsl:attribute name="data-xsd2html2xml-type">
					<xsl:value-of select="$html-type" />
				</xsl:attribute>
				<xsl:attribute name="data-xsd2html2xml-name">
					<xsl:value-of select="@name" />
				</xsl:attribute>
				
				<!-- invisible elements serve as placeholders for elements with variable occurrences -->
				<xsl:if test="$invisible = 'true'">
					<xsl:attribute name="style">display: none;</xsl:attribute>
				</xsl:if>
				
				<!-- pattern is used later to determine multiline text fields -->
				<xsl:variable name="pattern">
					<xsl:call-template name="attr-value">
						<xsl:with-param name="attr">xs:pattern</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				
				<!-- enumerations are rendered as select elements -->
				<xsl:variable name="choice">
					<xsl:call-template name="attr-value">
						<xsl:with-param name="attr">xs:enumeration</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				
				<!-- add label description etc. if label is configured to be placed before the input element -->
				<xsl:if test="not($config-label-after-input = 'true')">
					<xsl:element name="span">
						<xsl:value-of select="$description"/>
						<xsl:if test="$type = 'xs:duration'">
							<xsl:text> (</xsl:text> <!-- units for input[type=range] elements (xs:duration) are placed in brackets after the description -->
							<xsl:call-template name="get-duration-info">
								<xsl:with-param name="type">description</xsl:with-param>
								<xsl:with-param name="pattern" select="$pattern" />
							</xsl:call-template>
							<xsl:text>)</xsl:text>
						</xsl:if>
						<xsl:if test="not($static = 'true')"> <!-- non-static elements with variable occurrences can be removed -->
							<xsl:call-template name="add-remove-button" />
						</xsl:if>
					</xsl:element>
				</xsl:if>
				
				<!-- in case of xs:duration, an output element is added to show the selected value of the user -->
				<xsl:if test="$type = 'xs:duration'">
					<xsl:element name="output">
						<xsl:choose>
							<xsl:when test="@fixed">
								<xsl:value-of select="translate(@fixed,translate(@fixed, '0123456789.-', ''), '')"/>
							</xsl:when>
							<xsl:when test="@default">
								<xsl:value-of select="translate(@default,translate(@default, '0123456789.-', ''), '')"/>
							</xsl:when>
						</xsl:choose>
					</xsl:element>
				</xsl:if>
				
				<!-- handling whitespace as it is specified or default based on type -->
				<xsl:variable name="whitespace">
					<xsl:variable name="specified-whitespace">
						<xsl:call-template name="attr-value">
							<xsl:with-param name="attr">xs:whiteSpace</xsl:with-param>
						</xsl:call-template>
					</xsl:variable>
					
					<xsl:choose>
						<xsl:when test="not($specified-whitespace = '')">
							<xsl:value-of select="$specified-whitespace" />
						</xsl:when>
						<xsl:when test="$type = 'xs:string'">preserve</xsl:when>
						<xsl:when test="$type = 'xs:normalizedstring'">replace</xsl:when>
						<xsl:otherwise>collapse</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:choose>
					<!-- enumerations are rendered as select elements -->
					<xsl:when test="not($choice='')">
						<xsl:element name="select">
							<xsl:attribute name="onchange">
								<xsl:text>this.childNodes.forEach(function(o) { o.removeAttribute("selected"); }); this.children[this.selectedIndex].setAttribute("selected","selected");</xsl:text>
							</xsl:attribute>
							
							<!-- attribute can have optional use=required values; normal elements are always required -->
							<xsl:choose>
								<xsl:when test="$attribute = 'true'">
									<xsl:if test="@use = 'required'">
										<xsl:attribute name="required">required</xsl:attribute>
									</xsl:if>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="required">required</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
							
							<!-- disabled elements are used to omit invisible placeholders from inclusion in the validation and generated xml data -->
							<xsl:if test="$disabled = 'true'">
								<xsl:attribute name="disabled">disabled</xsl:attribute>
							</xsl:if>
							
							<!-- add options for each value; populate the element if there is corresponding data, or fill it with a fixed or default value -->
							<xsl:call-template name="handle-enumerations">
								<xsl:with-param name="default">
									<xsl:choose>
										<xsl:when test="@default"><xsl:value-of select="@default" /></xsl:when>
										<xsl:when test="@fixed"><xsl:value-of select="@fixed" /></xsl:when>
									</xsl:choose>
								</xsl:with-param>
								<xsl:with-param name="disabled">
									<xsl:choose>
										<xsl:when test="@fixed">true</xsl:when>
										<xsl:otherwise>false</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:element>
					</xsl:when>
					<!-- multiline patterns are rendered as textarea elements -->
					<xsl:when test="contains($pattern,'\n')">
						<xsl:element name="textarea">
							<xsl:attribute name="onchange">
								<xsl:text>this.textContent = this.value</xsl:text><xsl:if test="$whitespace = 'replace'">.replace(/\s/g, " ")</xsl:if><xsl:if test="$whitespace = 'collapse'">.replace(/\s+/g, " ").trim()</xsl:if>
							</xsl:attribute>
							
							<!-- attribute can have optional use=required values; normal elements are always required -->
							<xsl:choose>
								<xsl:when test="$attribute = 'true'">
									<xsl:if test="@use = 'required'">
										<xsl:attribute name="required">required</xsl:attribute>
									</xsl:if>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="required">required</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
							
							<!-- attributes can be prohibited, rendered as readonly -->
							<xsl:if test="@use = 'prohibited'">
								<xsl:attribute name="readonly">readonly</xsl:attribute>
							</xsl:if>
							
							<xsl:call-template name="set-type-specifics-recursively"/>
							
							<!-- disabled elements are used to omit invisible placeholders from inclusion in the validation and generated xml data -->
							<xsl:if test="$disabled = 'true'">
								<xsl:attribute name="disabled">disabled</xsl:attribute>
							</xsl:if>
							
							<!-- populate the element if there is corresponding data, or fill it with a fixed or default value -->
							<xsl:choose>
								<xsl:when test="@fixed">
									<xsl:attribute name="readonly">readonly</xsl:attribute>
									<xsl:value-of select="@fixed"/>
								</xsl:when>
								<xsl:when test="@default">
									<xsl:value-of select="@default"/>
								</xsl:when>
							</xsl:choose>
						</xsl:element>
					</xsl:when>
					<!-- all other primitive types become input elements -->
					<xsl:otherwise>
						<xsl:element name="input">
							<xsl:attribute name="type">
								<!-- primive type determines the input element type -->
								<xsl:choose>
									<xsl:when test="$type = 'xs:string' or $type = 'xs:normalizedstring' or $type = 'xs:token' or $type = 'xs:language'">
										<xsl:text>text</xsl:text>
									</xsl:when>
									<xsl:when test="$type = 'xs:decimal' or $type = 'xs:float' or $type = 'xs:double' or $type = 'xs:integer' or $type = 'xs:byte' or $type = 'xs:int' or $type = 'xs:long' or $type = 'xs:positiveinteger' or $type = 'xs:negativeinteger' or $type = 'xs:nonpositiveinteger' or $type = 'xs:nonnegativeinteger' or $type = 'xs:short' or $type = 'xs:unsignedlong' or $type = 'xs:unsignedint' or $type = 'xs:unsignedshort' or $type = 'xs:unsignedbyte' or $type = 'xs:gday' or $type = 'xs:gmonth' or $type = 'xs:gyear'">
										<xsl:text>number</xsl:text>
									</xsl:when>
									<xsl:when test="$type = 'xs:boolean'">
										<xsl:text>checkbox</xsl:text>
									</xsl:when>
									<xsl:when test="$type = 'xs:datetime'">
										<xsl:text>datetime-local</xsl:text>
									</xsl:when>
									<xsl:when test="$type = 'xs:date' or $type = 'xs:gmonthday'">
										<xsl:text>date</xsl:text>
									</xsl:when>
									<xsl:when test="$type = 'xs:time'">
										<xsl:text>time</xsl:text>
									</xsl:when>
									<xsl:when test="$type = 'xs:gyearmonth'">
										<xsl:text>month</xsl:text>
									</xsl:when>
									<xsl:when test="$type = 'xs:anyuri'">
										<xsl:text>url</xsl:text>
									</xsl:when>
									<xsl:when test="$type = 'xs:base64binary' or $type = 'xs:hexbinary'">
										<xsl:text>file</xsl:text>
									</xsl:when>
									<xsl:when test="$type = 'xs:duration'">
										<xsl:text>range</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>text</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							
							<!-- specifically set the value attribute in the HTML to enable XSLT processing of the form contents -->
							<xsl:attribute name="onchange">
								<xsl:choose>
									<xsl:when test="$type = 'xs:boolean'"> <!-- Use the checked value of checkboxes -->
										<xsl:text>if (this.checked) { this.setAttribute("checked","checked") } else { this.removeAttribute("checked") }</xsl:text>
									</xsl:when>
									<xsl:when test="$type = 'xs:base64binary' or $type = 'xs:hexbinary'"> <!-- Use the FileReader API to set the value of file inputs -->
										<xsl:text>pickFile(this, arguments[0].target.files[0], "</xsl:text>
										<xsl:value-of select="$type" />
										<xsl:text>");</xsl:text>
									</xsl:when>
									<xsl:when test="$type = 'xs:datetime' or $type = 'xs:time'"> 
										<xsl:text>if (this.value) { this.setAttribute("value", (this.value.match(/.*\d\d:\d\d:\d\d/) ? this.value : this.value.concat(":00"))); } else { this.removeAttribute("value"); };</xsl:text>
									</xsl:when>
									<xsl:when test="$type = 'xs:gday'"> 
										<xsl:text>if (this.value) { this.setAttribute("value", (this.value.length == 2 ? "---" : "---0").concat(this.value)); } else { this.removeAttribute("value"); };</xsl:text>
									</xsl:when>
									<xsl:when test="$type = 'xs:gmonth'"> 
										<xsl:text>if (this.value) { this.setAttribute("value", (this.value.length == 2 ? "--" : "--0").concat(this.value)); } else { this.removeAttribute("value"); };</xsl:text>
									</xsl:when>
									<xsl:when test="$type = 'xs:gmonthday'"> 
										<xsl:text>if (this.value) { this.setAttribute("value", this.value.replace(/^\d+/, "-")); } else { this.removeAttribute("value"); };</xsl:text>
									</xsl:when>
									<xsl:when test="$type = 'xs:duration'"> <!-- Use the output element for ranges -->
										<xsl:text>this.setAttribute("value", "</xsl:text><xsl:call-template name="get-duration-info"><xsl:with-param name="type">prefix</xsl:with-param><xsl:with-param name="pattern" select="$pattern" /></xsl:call-template>".concat(this.value).concat("<xsl:call-template name="get-duration-info"><xsl:with-param name="type">abbreviation</xsl:with-param><xsl:with-param name="pattern" select="$pattern" /></xsl:call-template><xsl:text>")); this.previousElementSibling.textContent = this.value;</xsl:text>
									</xsl:when>
									<xsl:otherwise> <!-- Use value if otherwise -->
										<xsl:text>if (this.value) { this.setAttribute("value", this.value</xsl:text><xsl:if test="$whitespace = 'replace'">.replace(/\s/g, " ")</xsl:if><xsl:if test="$whitespace = 'collapse'">.replace(/\s+/g, " ").trim()</xsl:if><xsl:text>); } else { this.removeAttribute("value"); };</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							
							<!-- attribute can have optional use=required values; normal elements are always required -->
							<xsl:choose>
								<xsl:when test="$attribute = 'true'">
									<xsl:if test="@use = 'required'">
										<xsl:choose><!-- in case of xs:base64binary or xs:hexbinary, default values cannot be set to an input[type=file] element; because of this, a required attribute on these elements is omitted when fixed, default, or data is found -->
											<xsl:when test="($type = 'xs:base64binary' or $type = 'xs:hexbinary') and (@fixed or @default)">
												<xsl:attribute name="data-xsd2html2xml-required">true</xsl:attribute>
											</xsl:when>
											<xsl:when test="not($type = 'xs:boolean')">
												<xsl:attribute name="required">required</xsl:attribute>
											</xsl:when>
										</xsl:choose>
									</xsl:if>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose><!-- in case of xs:base64binary or xs:hexbinary, default values cannot be set to an input[type=file] element; because of this, a required attribute on these elements is omitted when fixed, default, or data is found -->
										<xsl:when test="($type = 'xs:base64binary' or $type = 'xs:hexbinary') and (@fixed or @default)">
											<xsl:attribute name="data-xsd2html2xml-required">true</xsl:attribute>
										</xsl:when>
										<xsl:when test="not($type = 'xs:boolean')">
											<xsl:attribute name="required">required</xsl:attribute>
										</xsl:when>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
							
							<!-- attributes can be prohibited, rendered as readonly -->
							<xsl:if test="@use = 'prohibited'">
								<xsl:attribute name="readonly">readonly</xsl:attribute>
							</xsl:if>
							
							<xsl:call-template name="set-type-specifics-recursively"/>
							
							<xsl:call-template name="set-type-defaults">
								<xsl:with-param name="type">
									<xsl:value-of select="$type"/>
								</xsl:with-param>
							</xsl:call-template>
							
							<!-- disabled elements are used to omit invisible placeholders from inclusion in the validation and generated xml data -->
							<xsl:if test="$disabled = 'true'">
								<xsl:attribute name="disabled">disabled</xsl:attribute>
							</xsl:if>
							
							<xsl:attribute name="data-xsd2html2xml-primitive">
								<xsl:value-of select="$type" />
							</xsl:attribute>
							
							<xsl:if test="@fixed">
								<xsl:attribute name="readonly">readonly</xsl:attribute>
							</xsl:if>
							
							<xsl:choose>
								<!-- use fixed attribute as data if specified -->
								<xsl:when test="@fixed">
									<xsl:choose>
										<xsl:when test="$type = 'xs:boolean'">
											<xsl:if test="@fixed = 'true'">
												<xsl:attribute name="checked">checked</xsl:attribute>
											</xsl:if>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="value">
												<xsl:value-of select="@fixed"/>
											</xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<!-- use default attribute as data if specified; overridden later if populated -->
								<xsl:when test="@default">
									<xsl:choose>
										<xsl:when test="$type = 'xs:boolean'">
											<xsl:if test="@default = 'true'">
												<xsl:attribute name="checked">checked</xsl:attribute>
											</xsl:if>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="value">
												<xsl:value-of select="@default"/>
											</xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
							</xsl:choose>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
				
				<!-- add label description etc. if label is configured to be placed before the input element -->
				<xsl:if test="$config-label-after-input = 'true'">
					<xsl:element name="span">
						<xsl:value-of select="$description"/>
						<xsl:if test="$type = 'xs:duration'">
							<xsl:text> (</xsl:text> <!-- units for input[type=range] elements (xs:duration) are placed in brackets after the description -->
							<xsl:call-template name="get-duration-info">
								<xsl:with-param name="type">description</xsl:with-param>
								<xsl:with-param name="pattern" select="$pattern" />
							</xsl:call-template>
							<xsl:text>)</xsl:text>
						</xsl:if>
						<xsl:if test="not($static = 'true')"> <!-- non-static elements with variable occurrences can be removed -->
							<xsl:call-template name="add-remove-button" />
						</xsl:if>
					</xsl:element>
				</xsl:if>
			</xsl:element>
			
			<!-- add descending extensions -->
			<xsl:apply-templates select="*/*/xs:extension/*">
				<xsl:with-param name="disabled" select="$disabled" />
			</xsl:apply-templates>
			
			<!-- add inherited extensions; superfluous
			<xsl:call-template name="add-extensions-recursively">
				<xsl:with-param name="disabled" select="$disabled" />
			</xsl:call-template> -->
			
			<xsl:call-template name="handle-simple-element">
				<xsl:with-param name="id" select="$id" />
				<xsl:with-param name="description" select="$description" />
				<xsl:with-param name="static" select="$static" />
				<xsl:with-param name="count" select="$count - 1" />
				<xsl:with-param name="disabled" select="$disabled" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="xs:sequence">
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		
		<xsl:apply-templates select="xs:element|xs:attribute|xs:group|xs:choice|xs:sequence">
			<xsl:with-param name="disabled" select="$disabled" />
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="xs:all">
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		
		<xsl:apply-templates select="xs:element|xs:attribute|xs:group">
			<xsl:with-param name="disabled" select="$disabled" />
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="xs:choice">
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		
		<xsl:apply-templates select="xs:element|xs:attribute|xs:group">
			<xsl:with-param name="choice" select="generate-id()" />
			<xsl:with-param name="disabled" select="$disabled" />
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- Recursively searches for xs:enumeration elements and applies templates on them -->
	<xsl:template name="handle-enumerations">
		<xsl:param name="default" />
		<xsl:param name="disabled">false</xsl:param>
		
		<xsl:variable name="type">
			<xsl:call-template name="get-type"/>
		</xsl:variable>
		
		<xsl:apply-templates select=".//xs:restriction/xs:enumeration" mode="input">
			<xsl:with-param name="default" select="$default" />
			<xsl:with-param name="disabled" select="$disabled" />
		</xsl:apply-templates>
		
		<xsl:for-each select="//xs:simpleType[@name=$type]">
			<xsl:call-template name="handle-enumerations">
				<xsl:with-param name="default" select="$default" />
				<xsl:with-param name="disabled" select="$disabled" />
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<!-- Returns predetermined values for xs:duration specifics found in patterns -->
	<xsl:template name="get-duration-info">
		<xsl:param name="type" />
		<xsl:param name="pattern" />
		
		<xsl:choose>
			<xsl:when test="contains($pattern, 'T') and contains($pattern, 'S')">
				<xsl:if test="$type = 'prefix'">PT</xsl:if>
				<xsl:if test="$type = 'abbreviation'">S</xsl:if>
				<xsl:if test="$type = 'description'"><xsl:value-of select="$config-seconds" /></xsl:if>
			</xsl:when>
			<xsl:when test="contains($pattern, 'T') and contains($pattern, 'M')">
				<xsl:if test="$type = 'prefix'">PT</xsl:if>
				<xsl:if test="$type = 'abbreviation'">M</xsl:if>
				<xsl:if test="$type = 'description'"><xsl:value-of select="$config-minutes" /></xsl:if>
			</xsl:when>
			<xsl:when test="contains($pattern, 'T') and contains($pattern, 'H')">
				<xsl:if test="$type = 'prefix'">PT</xsl:if>
				<xsl:if test="$type = 'abbreviation'">H</xsl:if>
				<xsl:if test="$type = 'description'"><xsl:value-of select="$config-hours" /></xsl:if>
			</xsl:when>
			<xsl:when test="not(contains($pattern, 'T')) and contains($pattern, 'D')">
				<xsl:if test="$type = 'prefix'">P</xsl:if>
				<xsl:if test="$type = 'abbreviation'">D</xsl:if>
				<xsl:if test="$type = 'description'"><xsl:value-of select="$config-days" /></xsl:if>
			</xsl:when>
			<xsl:when test="not(contains($pattern, 'T')) and contains($pattern, 'M')">
				<xsl:if test="$type = 'prefix'">P</xsl:if>
				<xsl:if test="$type = 'abbreviation'">M</xsl:if>
				<xsl:if test="$type = 'description'"><xsl:value-of select="$config-months" /></xsl:if>
			</xsl:when>
			<xsl:when test="not(contains($pattern, 'T')) and contains($pattern, 'Y')">
				<xsl:if test="$type = 'prefix'">P</xsl:if>
				<xsl:if test="$type = 'abbreviation'">Y</xsl:if>
				<xsl:if test="$type = 'description'"><xsl:value-of select="$config-years" /></xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$type = 'prefix'">P</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Returns an element's description from xs:annotation/xs:documentation if it exists, @value in the case of enumerations, or @name otherwise -->
	<xsl:template name="get-description">
		<xsl:variable name="documentation">
			<xsl:call-template name="get-documentation" />
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$documentation = ''">
				<xsl:choose>
					<xsl:when test="@name">
						<xsl:value-of select="@name" />
					</xsl:when>
					<xsl:when test="@value">
						<xsl:value-of select="@value" />
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$documentation" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Returns an element's description from xs:annotation/xs:documentation if it exists, taking into account the specified preferred language -->
	<xsl:template name="get-documentation">
		<xsl:choose>
			<xsl:when test="not($config-language = '') and xs:annotation/xs:documentation[@xml:lang=$config-language]">
				<xsl:value-of select="xs:annotation/xs:documentation[@xml:lang=$config-language]/text()" />
			</xsl:when>
			<xsl:when test="not($config-language = '') and xs:annotation/xs:documentation[not(@xml:lang)]">
				<xsl:value-of select="xs:annotation/xs:documentation[not(@xml:lang)]/text()" />
			</xsl:when>
			<xsl:when test="$config-language = '' and xs:annotation/xs:documentation[not(@xml:lang)]">
				<xsl:value-of select="xs:annotation/xs:documentation[not(@xml:lang)]/text()" />
			</xsl:when>
			<xsl:when test="$config-language = '' and xs:annotation/xs:documentation">
				<xsl:value-of select="xs:annotation/xs:documentation/text()" />
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- Returns the first value that matches attr name -->
	<xsl:template name="attr-value">
		<xsl:param name="attr"/>
		
		<xsl:variable name="type">
			<xsl:call-template name="get-type"/>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="@*[contains(.,$attr)]">
				<xsl:value-of select="@*[contains(name(),$attr)]"/>
			</xsl:when>
			<xsl:when test=".//xs:restriction/*[contains(name(),$attr)]">
				<xsl:value-of select=".//xs:restriction/*[contains(name(),$attr)]/@value"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="//xs:simpleType[@name=$type]">
					<xsl:call-template name="attr-value">
						<xsl:with-param name="attr" select="$attr"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Returns the type directly specified by the calling node -->
	<xsl:template name="get-type">
		<xsl:choose>
			<xsl:when test="@type">
				<xsl:value-of select="@type"/>
			</xsl:when>
			<xsl:when test="xs:simpleType/xs:restriction/@base">
				<xsl:value-of select="xs:simpleType/xs:restriction/@base"/>
			</xsl:when>
			<xsl:when test="xs:restriction/@base">
				<xsl:value-of select="xs:restriction/@base"/>
			</xsl:when>
			<xsl:when test="xs:complexType/xs:simpleContent/xs:restriction/@base">
				<xsl:value-of select="xs:complexType/xs:simpleContent/xs:restriction/@base"/>
			</xsl:when>
			<xsl:when test="xs:simpleContent/xs:restriction/@base">
				<xsl:value-of select="xs:simpleContent/xs:restriction/@base"/>
			</xsl:when>
			<xsl:when test="xs:complexType/xs:simpleContent/xs:extension/@base">
				<xsl:value-of select="xs:complexType/xs:simpleContent/xs:extension/@base"/>
			</xsl:when>
			<xsl:when test="xs:simpleContent/xs:extension/@base">
				<xsl:value-of select="xs:simpleContent/xs:extension/@base"/>
			</xsl:when>
			<xsl:when test="xs:complexType/xs:complexContent/xs:extension/@base">
				<xsl:value-of select="xs:complexType/xs:complexContent/xs:extension/@base"/>
			</xsl:when>
			<xsl:when test="xs:complexContent/xs:extension/@base">
				<xsl:value-of select="xs:complexContent/xs:extension/@base"/>
			</xsl:when>
			<xsl:when test="xs:simpleType/xs:union/@memberTypes">
				<xsl:value-of select="xs:simpleType/xs:union/@memberTypes"/>
			</xsl:when>
			<xsl:when test="xs:union/@memberTypes">
				<xsl:value-of select="xs:simpleType/xs:union/@memberTypes"/>
			</xsl:when>
			<xsl:when test="@ref">
				<xsl:value-of select="@ref"/> <!-- a @ref attribute does not contain a type but an element reference. It does contain the prefix of the namespace where the element's type is declared, so it is required to look up the element specification -->
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- Returns the original xs:* type specified by the calling node, in lower case -->
	<xsl:template name="get-primitive-type">
		<xsl:variable name="type">
			<xsl:call-template name="get-type"/>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="not(starts-with($type, 'xs:'))">
				<xsl:for-each select="//xs:simpleType[@name=$type]|//xs:complexType[@name=$type]">
					<xsl:call-template name="get-primitive-type" />
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="translate($type, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Applies templates recursively, overwriting lower-level options -->
	<xsl:template name="set-type-specifics-recursively">
		<xsl:variable name="type">
			<xsl:call-template name="get-type"/>
		</xsl:variable>
		
		<xsl:if test="not(starts-with($type, 'xs:'))">
			<xsl:for-each select="//xs:simpleType[@name=$type]|//xs:complexType[@name=$type]">
				<xsl:call-template name="set-type-specifics-recursively" />
			</xsl:for-each>
		</xsl:if>
		
		<xsl:apply-templates select=".//xs:restriction/xs:minInclusive" mode="input"/>
		<xsl:apply-templates select=".//xs:restriction/xs:maxInclusive" mode="input"/>
		
		<xsl:apply-templates select=".//xs:restriction/xs:minExclusive" mode="input"/>
		<xsl:apply-templates select=".//xs:restriction/xs:maxExclusive" mode="input"/>
		
		<xsl:apply-templates select=".//xs:restriction/xs:pattern" mode="input"/>
		<xsl:apply-templates select=".//xs:restriction/xs:length" mode="input"/>
		<xsl:apply-templates select=".//xs:restriction/xs:maxLength" mode="input"/>
	</xsl:template>
	
	<!-- Adds elements and attributes in extension recursively -->
	<!--<xsl:template name="add-extensions-recursively">
		<xsl:param name="disabled">false</xsl:param>
		
		<xsl:variable name="type">
			<xsl:call-template name="get-type"/>
		</xsl:variable>
		
		<xsl:if test="not(starts-with($type, 'xs:'))">
			<xsl:for-each select="//xs:simpleType[@name=$type]|//xs:complexType[@name=$type]">
				<xsl:apply-templates select=".//xs:element|.//xs:attribute">
					<xsl:with-param name="disabled" select="$disabled" />
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>-->
	
	<xsl:template name="add-remove-button">
		<xsl:if test="(@minOccurs or @maxOccurs) and not(@minOccurs = @maxOccurs) and not(@minOccurs = '1' and not(@maxOccurs)) and not(@maxOccurs = '1' and not(@minOccurs))">
			<xsl:element name="button">
				<xsl:attribute name="type">button</xsl:attribute>
				<xsl:attribute name="class">remove</xsl:attribute>
				<xsl:attribute name="onclick">clickRemoveButton(this);</xsl:attribute>
				<xsl:value-of select="$config-remove-button-label" />
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="add-add-button">
		<xsl:param name="description" />
		
		<!--<xsl:if test="(@minOccurs or @maxOccurs) and not(@minOccurs = @maxOccurs) and not(@minOccurs = '1' and not(@maxOccurs)) and not(@maxOccurs = '1' and not(@minOccurs))">-->
			<xsl:element name="button">
				<xsl:attribute name="type">button</xsl:attribute>
				<xsl:attribute name="class">add</xsl:attribute>
				<xsl:attribute name="data-xsd2html2xml-min">
					<xsl:choose>
						<xsl:when test="@minOccurs"><xsl:value-of select="@minOccurs" /></xsl:when>
						<xsl:otherwise>1</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="data-xsd2html2xml-max">
					<xsl:choose>
						<xsl:when test="@maxOccurs"><xsl:value-of select="@maxOccurs" /></xsl:when>
						<xsl:otherwise>1</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="onclick">clickAddButton(this);</xsl:attribute>
				<xsl:value-of select="$config-add-button-label" /><xsl:text> </xsl:text><xsl:value-of select="$description" />
			</xsl:element>
		<!--</xsl:if>-->
	</xsl:template>
	
	<xsl:template name="add-choice-button">
		<xsl:param name="name" />
		<xsl:param name="description" />
		<xsl:param name="disabled">false</xsl:param>
		
		<xsl:element name="label">
			<xsl:if test="not($config-label-after-input = 'true')">
				<xsl:element name="span">
					<xsl:value-of select="$description" />
				</xsl:element>
			</xsl:if>
		
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
			</xsl:element>
			
			<xsl:if test="$config-label-after-input = 'true'">
				<xsl:element name="span">
					<xsl:value-of select="$description" />
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<!-- sets default values for xs:* types, but does not override already specified values -->
	<xsl:template name="set-type-defaults">
		<xsl:param name="type"/>
		
		<xsl:variable name="fractionDigits">
			<xsl:call-template name="attr-value">
				<xsl:with-param name="attr">xs:fractionDigits</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$type = 'xs:decimal'">
				<xsl:attribute name="step">
					<xsl:choose>
						<xsl:when test="$fractionDigits!='' and $fractionDigits!='0'">
							<xsl:value-of select="concat('0.',substring('00000000000000000000',1,$fractionDigits - 1),'1')" />
						</xsl:when>
						<xsl:otherwise>0.1</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">[-]?</xsl:with-param>
					<xsl:with-param name="allow-dot">true</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'xs:float'">
				<xsl:attribute name="step">
					<xsl:choose>
						<xsl:when test="$fractionDigits!='' and $fractionDigits!='0'">
							<xsl:value-of select="concat('0.',substring('00000000000000000000',1,$fractionDigits - 1),'1')" />
						</xsl:when>
						<xsl:otherwise>0.1</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">[-]?</xsl:with-param>
					<xsl:with-param name="allow-dot">true</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'xs:double'">
				<xsl:attribute name="step">
					<xsl:choose>
						<xsl:when test="$fractionDigits!='' and $fractionDigits!='0'">
							<xsl:value-of select="concat('0.',substring('00000000000000000000',1,$fractionDigits - 1),'1')" />
						</xsl:when>
						<xsl:otherwise>0.1</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">[-]?</xsl:with-param>
					<xsl:with-param name="allow-dot">true</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'xs:byte'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">-128</xsl:with-param>
					<xsl:with-param name="max-value">127</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">[-]?</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'xs:unsignedbyte'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">0</xsl:with-param>
					<xsl:with-param name="max-value">255</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'xs:short'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">-32768</xsl:with-param>
					<xsl:with-param name="max-value">32767</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">[-]?</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'xs:unsignedshort'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">0</xsl:with-param>
					<xsl:with-param name="max-value">65535</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'xs:int'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">-2147483648</xsl:with-param>
					<xsl:with-param name="max-value">2147483647</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">[-]?</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'xs:nonpositiveinteger'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">-2147483648</xsl:with-param>
					<xsl:with-param name="max-value">0</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">[-]?</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'xs:nonnegativeinteger'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">0</xsl:with-param>
					<xsl:with-param name="max-value">2147483647</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'xs:positiveinteger'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">1</xsl:with-param>
					<xsl:with-param name="max-value">2147483647</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'xs:negativeinteger'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">-2147483648</xsl:with-param>
					<xsl:with-param name="max-value">-1</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">[-]?</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'xs:unsignedint'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">0</xsl:with-param>
					<xsl:with-param name="max-value">4294967295</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'xs:long'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">-9223372036854775808</xsl:with-param>
					<xsl:with-param name="max-value">9223372036854775807</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">[-]?</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'xs:unsignedlong'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">0</xsl:with-param>
					<xsl:with-param name="max-value">18446744073709551615</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'xs:datetime'">
				<xsl:attribute name="step">1</xsl:attribute>
			</xsl:when>
			<xsl:when test="$type = 'xs:time'">
				<xsl:attribute name="step">1</xsl:attribute>
			</xsl:when>
			<xsl:when test="$type = 'xs:gday'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">1</xsl:with-param>
					<xsl:with-param name="max-value">31</xsl:with-param>
				</xsl:call-template>
				<xsl:attribute name="step">1</xsl:attribute>
			</xsl:when>
			<xsl:when test="$type = 'xs:gmonth'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">1</xsl:with-param>
					<xsl:with-param name="max-value">12</xsl:with-param>
				</xsl:call-template>
				<xsl:attribute name="step">1</xsl:attribute>
			</xsl:when>
			<xsl:when test="$type = 'xs:gyear'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">1000</xsl:with-param>
					<xsl:with-param name="max-value">9999</xsl:with-param>
				</xsl:call-template>
				<xsl:attribute name="step">1</xsl:attribute>
			</xsl:when>
			<xsl:when test="$type = 'xs:duration'">
				<xsl:attribute name="step">1</xsl:attribute>
			</xsl:when>
			<xsl:when test="$type = 'xs:language'">
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">([a-zA-Z]{2}|[iI]-[a-zA-Z]+|[xX]-[a-zA-Z]{1,8})(-[a-zA-Z]{1,8})*</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="set-pattern" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- sets min and max attributes if they have not been specified explicitly -->
	<xsl:template name="set-numeric-range">
		<xsl:param name="min-value"/>
		<xsl:param name="max-value"/>
		
		<xsl:variable name="minInclusive">
			<xsl:call-template name="attr-value">
				<xsl:with-param name="attr">xs:minInclusive</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="minExclusive">
			<xsl:call-template name="attr-value">
				<xsl:with-param name="attr">xs:minExclusive</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:if test="$minInclusive = '' and $minExclusive = ''">
			<xsl:attribute name="min">
				<xsl:value-of select="$min-value"/>
			</xsl:attribute>
		</xsl:if>
		
		<xsl:variable name="maxInclusive">
			<xsl:call-template name="attr-value">
				<xsl:with-param name="attr">xs:maxInclusive</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="maxExclusive">
			<xsl:call-template name="attr-value">
				<xsl:with-param name="attr">xs:maxExclusive</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:if test="$maxInclusive = '' and $maxExclusive = ''">
			<xsl:attribute name="max">
				<xsl:value-of select="$max-value"/>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>
	
	<!-- sets pattern attribute if it has not been specified explicitly -->
	<!-- numeric types (depending on totalDigits and fractionDigits) get regex patterns allowing digits and not counting the - and . -->
	<!-- other types (depending on minLength, maxLength, and length) get simpler regex patterns allowing any characters -->
	<xsl:template name="set-pattern">
		<xsl:param name="prefix">.</xsl:param>
		<xsl:param name="allow-dot">false</xsl:param>
		
		<xsl:variable name="pattern">
			<xsl:call-template name="attr-value">
				<xsl:with-param name="attr">xs:pattern</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:if test="$pattern=''">
			<xsl:variable name="length">
				<xsl:call-template name="attr-value">
					<xsl:with-param name="attr">xs:length</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="minLength">
				<xsl:call-template name="attr-value">
					<xsl:with-param name="attr">xs:minLength</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="maxLength">
				<xsl:call-template name="attr-value">
					<xsl:with-param name="attr">xs:maxLength</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="totalDigits">
				<xsl:call-template name="attr-value">
					<xsl:with-param name="attr">xs:totalDigits</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="fractionDigits">
				<xsl:call-template name="attr-value">
					<xsl:with-param name="attr">xs:fractionDigits</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:attribute name="pattern">
				<xsl:choose>
					<xsl:when test="$totalDigits!='' and $fractionDigits!=''">
						<xsl:value-of select="concat($prefix,'(?!\d{',$totalDigits + 1,'})(?!.*\.\d{',$totalDigits + 1 - $fractionDigits,',})[\d.]{0,',$totalDigits + 1,'}')" />
					</xsl:when>
					<xsl:when test="$totalDigits!='' and $allow-dot='true'">
						<xsl:value-of select="concat($prefix,'(?!\d{',$totalDigits + 1,'})[\d.]{0,',$totalDigits + 1,'}')" />
					</xsl:when>
					<xsl:when test="$totalDigits!='' and $allow-dot='false'">
						<xsl:value-of select="concat($prefix,'(?!\d{',$totalDigits,'})[\d]{0,',$totalDigits,'}')" />
					</xsl:when>
					<xsl:when test="$fractionDigits!=''">
						<xsl:value-of select="concat($prefix,'\d*(?:[.][\d]{0,',$fractionDigits,'})?')" />
					</xsl:when>
					<xsl:when test="not($length='')">
						<xsl:value-of select="concat($prefix,'{',$length,'}')" />
					</xsl:when>
					<!-- override lengths if pattern already ends with a number indicator -->
					<xsl:when test="substring($prefix, string-length($prefix)) = '*'">
						<xsl:value-of select="$prefix" />
					</xsl:when>
					<xsl:when test="$minLength=''">
						<xsl:value-of select="concat($prefix,'{0,',$maxLength,'}')" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($prefix,'{',$minLength,',',$maxLength,'}')" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="xs:minInclusive" mode="input">
		<xsl:attribute name="min">
			<xsl:value-of select="translate(@value,translate(@value, '0123456789.-', ''), '')"/> <!-- use double-translate function to extract numbers from possible regex input (e.g. for xs:duration) -->
		</xsl:attribute>
	</xsl:template> 
	
	<xsl:template match="xs:maxInclusive" mode="input">
		<xsl:attribute name="max">
			<xsl:value-of select="translate(@value,translate(@value, '0123456789.-', ''), '')"/> <!-- use double-translate function to extract numbers from possible regex input (e.g. for xs:duration) -->
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="xs:minExclusive" mode="input">
		<xsl:attribute name="min">
			<xsl:value-of select="translate(@value,translate(@value, '0123456789.-', ''), '') + 1"/> <!-- use double-translate function to extract numbers from possible regex input (e.g. for xs:duration) -->
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="xs:maxExclusive" mode="input">
		<xsl:attribute name="max">
			<xsl:value-of select="translate(@value,translate(@value, '0123456789.-', ''), '') - 1"/> <!-- use double-translate function to extract numbers from possible regex input (e.g. for xs:duration) -->
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="xs:enumeration" mode="input">
		<xsl:param name="default" />
		<xsl:param name="disabled" />
		
		<xsl:variable name="description">
			<xsl:call-template name="get-description" />
		</xsl:variable>
		
		<xsl:element name="option">
			<xsl:if test="$default = @value">
				<xsl:attribute name="selected">selected</xsl:attribute>
			</xsl:if>
			
			<xsl:if test="$disabled = 'true' and not($default = @value)">
				<xsl:attribute name="disabled">disabled</xsl:attribute>
			</xsl:if>
			
			<xsl:attribute name="value">
				<xsl:value-of select="@value"/>
			</xsl:attribute>
			
			<xsl:value-of select="$description"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="xs:pattern" mode="input">
		<xsl:attribute name="pattern">
			<xsl:value-of select="@value"/>
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="xs:length|xs:maxLength" mode="input">
		<xsl:attribute name="maxlength">
			<xsl:value-of select="@value"/>
		</xsl:attribute>
	</xsl:template>
	
</xsl:stylesheet>
