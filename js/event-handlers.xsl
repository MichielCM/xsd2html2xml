<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<xsl:template name="add-event-handlers">
		<xsl:element name="script">
			<xsl:attribute name="type">text/javascript</xsl:attribute>
			<xsl:text disable-output-escaping="yes">
				/* EVENT HANDLERS */
				
				var clickAddButton = function(button) {
					var newNode = button.previousElementSibling.cloneNode(true);
					
					newNode.removeAttribute("hidden");
					
					newNode.querySelectorAll("input, select, textarea").forEach(function(o) {
						if (o.closest("[hidden]") == null)
							o.removeAttribute("disabled");
					});
					
					//set a new random id for radio buttons
					newNode.querySelectorAll("input[type='radio']").forEach(function(o) {
						if (o.parentElement.previousElementSibling != null
						&amp;&amp; o.parentElement.previousElementSibling.previousElementSibling != null
						&amp;&amp; o.parentElement.previousElementSibling.previousElementSibling.children.length &gt; 0
						&amp;&amp; o.parentElement.previousElementSibling.previousElementSibling.children[0].hasAttribute("type")
						&amp;&amp; o.parentElement.previousElementSibling.previousElementSibling.children[0].getAttribute("type") === "radio") {
							o.setAttribute("name", o.parentElement.previousElementSibling.previousElementSibling.children[0].getAttribute("name"));
						} else {
							o.setAttribute("name", o.getAttribute("name").concat(
								Math.random().toString().substring(2)
							));
						};
						
						o.setAttribute("onclick", "clickRadioInput(this, '".concat(o.getAttribute("name")).concat("');"));
					});
					
					button.parentNode.insertBefore(
						newNode, button.previousElementSibling
					);
					
					if ((button.parentNode.children.length - 2) == button.getAttribute("data-xsd2html2xml-max"))
						button.setAttribute("disabled", "disabled");
						
					if (newNode.querySelectorAll("[data-xsd2html2xml-primitive='id']").length &gt; 0)
						updateIdentifiers();
				}
				
				var clickRemoveButton = function(button) {
					var section = button.closest("section");
					
					if ((button.closest("section").children.length - 2) == button.closest("section").lastElementChild.getAttribute("data-xsd2html2xml-min"))
						button.closest("section").lastElementChild.click();
					
					if ((button.closest("section").children.length - 2) == button.closest("section").lastElementChild.getAttribute("data-xsd2html2xml-max"))
						button.closest("section").lastElementChild.removeAttribute("disabled");
					
					button.closest("section").removeChild(
						button.closest("fieldset, label")
					);
					
					if (section.querySelectorAll("[data-xsd2html2xml-primitive = 'id']").length &gt; 0)
						updateIdentifiers();
				}
				
				var clickRadioInput = function(input, name) {
					var activeSections = [];
					var currentSection = input.parentElement.nextElementSibling;
					
					while (currentSection &amp;&amp; currentSection.hasAttribute("data-xsd2html2xml-choice")) {
						activeSections.push(currentSection);
						currentSection = currentSection.nextElementSibling;
					};
					
					document.querySelectorAll("[name=".concat(name).concat("]")).forEach(function(o) {
						o.removeAttribute("checked");
						
						var section = o.parentElement.nextElementSibling;
						
						while (section &amp;&amp; section.hasAttribute("data-xsd2html2xml-choice")) {
							section.querySelectorAll("input, select, textarea").forEach(function(p) {
								var contained = false;
								activeSections.forEach(function(q) {
									if (q.contains(p)) contained = true;
								});
								
								if (contained) {
									if (p.closest("[data-xsd2html2xml-choice]") === section) {
										if (p.closest("*[hidden]") === null)
											p.removeAttribute("disabled");
										else
											p.setAttribute("disabled", "disabled");
									}
								} else {
									p.setAttribute("disabled", "disabled");
								};
							});
							
							section = section.nextElementSibling;
						};
					});
					
					input.setAttribute("checked","checked");
				}
				
				var updateIdentifiers = function() {
					var globalIdentifiers = [];
					
					document.querySelectorAll("[data-xsd2html2xml-primitive='id']:not([disabled])").forEach(function(o) {
						if (o.hasAttribute("value")) {
							globalIdentifiers.push(o.getAttribute("value"));
						}
					});
					
					globalIdentifiers = globalIdentifiers.filter(
						function uniques(value, index, self) { 
							return self.indexOf(value) === index;
						}
					);
					
					document.querySelectorAll("[data-xsd2html2xml-primitive='idref'], [data-xsd2html2xml-primitive='idrefs']").forEach(function(o) {
						while(o.firstChild) {
							o.removeChild(o.firstChild);
						}
						
						for (var i=0; i&lt;globalIdentifiers.length; i++) {
							var option = document.createElement('option');
							option.textContent = globalIdentifiers[i];
							option.setAttribute("value", globalIdentifiers[i]);
							o.append(option);
						}
					});
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
								(type.endsWith(":base64binary"))
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
			</xsl:text>
		</xsl:element>	
	</xsl:template>
	
</xsl:stylesheet>