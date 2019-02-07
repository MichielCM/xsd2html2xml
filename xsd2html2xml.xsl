<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	
	<xsl:include href="css/default-style.xsl" />
	
	<xsl:include href="js/event-handlers.xsl" />
	<xsl:include href="js/html-populators.xsl" />
	<xsl:include href="js/initial-calls.xsl" />
	<xsl:include href="js/polyfills.xsl" />
	<xsl:include href="js/value-fixers.xsl" />
	<xsl:include href="js/xml-generators.xsl" />
	
	<xsl:include href="init.xsl" />
	<xsl:include href="config.xsl" />
	
	<xsl:include href="utils/appinfo.xsl" />
	<xsl:include href="utils/attr-value.xsl" />
	<xsl:include href="utils/documentation.xsl" />
	<xsl:include href="utils/gui-attributes.xsl" />
	<xsl:include href="utils/gui.xsl" />
	<xsl:include href="utils/log.xsl" />
	<xsl:include href="utils/namespaces.xsl" />
	<xsl:include href="utils/nodeset-exsl.xsl" />
	<xsl:include href="utils/serialize.xsl" />
	<xsl:include href="utils/strings.xsl" />
	<xsl:include href="utils/types.xsl" />
	
	<xsl:include href="matchers/all.xsl" />
	<xsl:include href="matchers/attributeGroup@ref.xsl" />
	<xsl:include href="matchers/attributes.xsl" />
	<xsl:include href="matchers/choice.xsl" />
	<xsl:include href="matchers/element-attribute@ref.xsl" />
	<xsl:include href="matchers/element-complexType.xsl" />
	<xsl:include href="matchers/element-simpleContent.xsl" />
	<xsl:include href="matchers/element-simpleType.xsl" />
	<xsl:include href="matchers/element@type.xsl" />
	<xsl:include href="matchers/group@ref.xsl" />
	<xsl:include href="matchers/sequence.xsl" />
	<xsl:include href="matchers/unsupported.xsl" />
	
	<xsl:include href="handlers/complex-elements.xsl" />
	<xsl:include href="handlers/default-types.xsl" />
	<xsl:include href="handlers/enumerations.xsl" />
	<xsl:include href="handlers/extensions.xsl" />
	<xsl:include href="handlers/multiline-strings.xsl" />
	<xsl:include href="handlers/root-element.xsl" />
	<xsl:include href="handlers/simple-elements.xsl" />
	
	<xsl:variable name="templates" select="document('')/*/xsl:template"/>
	<xsl:variable name="root-element-stylesheet" select="document('handlers/root-element.xsl')" />
	<xsl:variable name="complex-elements-stylesheet" select="document('handlers/complex-elements.xsl')" />
	<xsl:variable name="enumerations-stylesheet" select="document('handlers/enumerations.xsl')" />
	<xsl:variable name="extensions-stylesheet" select="document('handlers/extensions.xsl')" />
	<xsl:variable name="element-stylesheet" select="document('matchers/element@type.xsl')" />
	<xsl:variable name="element-attribute-stylesheet" select="document('matchers/element-attribute@ref.xsl')" />
	<xsl:variable name="element-complexType-stylesheet" select="document('matchers/element-complexType.xsl')" />
	<xsl:variable name="element-simpleType-stylesheet" select="document('matchers/element-simpleType.xsl')" />
	<xsl:variable name="element-simpleContent-stylesheet" select="document('matchers/element-simpleContent.xsl')" />
	<xsl:variable name="group-stylesheet" select="document('matchers/group@ref.xsl')" />
	<xsl:variable name="attributeGroup-stylesheet" select="document('matchers/attributeGroup@ref.xsl')" />
	<xsl:variable name="attr-value-stylesheet" select="document('utils/attr-value.xsl')" />
	<xsl:variable name="gui-attributes-stylesheet" select="document('utils/gui-attributes.xsl')" />
 	<xsl:variable name="namespaces-stylesheet" select="document('utils/namespaces.xsl')" />
	<xsl:variable name="types-stylesheet" select="document('utils/types.xsl')" />
	
	<xsl:template match="*" />
	
	<xsl:template match="/*">
		<xsl:element name="html">
			<xsl:choose>
				<!-- check if noNamespaceSchemaLocation contains a value -->
				<xsl:when test="@xsi:noNamespaceSchemaLocation">
					<xsl:call-template name="inform">
						<xsl:with-param name="message">
							<xsl:text>XML file detected. Loading schema: </xsl:text><xsl:value-of select="@xsi:noNamespaceSchemaLocation" />
						</xsl:with-param>
					</xsl:call-template>
					
					<xsl:call-template name="add-metadata">
						<xsl:with-param name="xml-document" select="." />
					</xsl:call-template>
					
					<xsl:for-each select="document(@xsi:noNamespaceSchemaLocation)/*">
						<xsl:call-template name="handle-schema" />
					</xsl:for-each>
				</xsl:when>
				<!-- check if schemaLocation contains a value -->
				<xsl:when test="@xsi:schemaLocation">
					<xsl:choose>
						<!-- check if schemaLocation contains spaces (and thus namespace-location combinations) -->
						<xsl:when test="contains(@xsi:schemaLocation, ' ')">
							<!-- extract the namespace of the root element -->
							<xsl:variable name="default-namespace">
								<xsl:value-of select="namespace::*[name() = substring-before(name(), concat(':', local-name()))]" />
							</xsl:variable>
							
							<!-- extract schema location relative to default namespace -->
							<xsl:variable name="schema-location">
								<xsl:value-of select="normalize-space(substring-after(@xsi:schemaLocation, $default-namespace))" />
							</xsl:variable>
							
							<xsl:choose>
								<!-- if schema-location still contains spaces, break off before the first one to find the schema location -->
								<xsl:when test="contains($schema-location, ' ')">
									<xsl:call-template name="inform">
										<xsl:with-param name="message">
											<xsl:text>XML file detected. Loading schema: </xsl:text><xsl:value-of select="normalize-space(substring-before($schema-location, ' '))" />
										</xsl:with-param>
									</xsl:call-template>
									
									<xsl:call-template name="add-metadata">
										<xsl:with-param name="xml-document" select="." />
									</xsl:call-template>
									
									<xsl:for-each select="document(normalize-space(substring-before($schema-location, ' ')))/*">
										<xsl:call-template name="handle-schema" />
									</xsl:for-each>
								</xsl:when>
								<!-- otherwise, the remaining value should point to a schema -->
								<xsl:otherwise>
									<xsl:call-template name="inform">
										<xsl:with-param name="message">
											<xsl:text>XML file detected. Loading schema: </xsl:text><xsl:value-of select="$schema-location" />
										</xsl:with-param>
									</xsl:call-template>
									
									<xsl:call-template name="add-metadata">
										<xsl:with-param name="xml-document" select="." />
									</xsl:call-template>
									
									<xsl:for-each select="document($schema-location)/*">
										<xsl:call-template name="handle-schema" />
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<!-- if not, assume the value points to a schema -->
						<xsl:otherwise>
							<xsl:call-template name="inform">
								<xsl:with-param name="message">
									<xsl:text>XML file detected. Loading schema: </xsl:text><xsl:value-of select="@xsi:schemaLocation" />
								</xsl:with-param>
							</xsl:call-template>
							
							<xsl:call-template name="add-metadata">
								<xsl:with-param name="xml-document" select="." />
							</xsl:call-template>
							
							<xsl:for-each select="document(@xsi:schemaLocation)/*">
								<xsl:call-template name="handle-schema" />
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<!-- else, assume an XSD document -->
				<xsl:otherwise>
					<xsl:call-template name="add-metadata" />
					<xsl:call-template name="handle-schema" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	<!-- add metadata, including optionally xml document, to head section -->
	<xsl:template name="add-metadata">
		<xsl:param name="xml-document"></xsl:param>
		
		<xsl:element name="head">
			<xsl:element name="title">
				<xsl:value-of select="$config-title" />
			</xsl:element>
			
			<!-- add stylesheet and script elements -->
			<xsl:if test="not($config-style = '')">
				<xsl:element name="link">
					<xsl:attribute name="rel">stylesheet</xsl:attribute>
					<xsl:attribute name="type">text/css</xsl:attribute>
					<xsl:attribute name="href">
						<xsl:value-of select="$config-style" />
					</xsl:attribute>
				</xsl:element>
			</xsl:if>
			
			<xsl:call-template name="add-style" />
			
			<xsl:call-template name="add-polyfills" />
			<xsl:call-template name="add-xml-generators" />
			<xsl:call-template name="add-html-populators" />
			<xsl:call-template name="add-value-fixers" />
			<xsl:call-template name="add-event-handlers" />
			<xsl:call-template name="add-initial-calls" />
			
			<xsl:if test="not($config-script = '')">
				<xsl:element name="script">
					<xsl:attribute name="type">text/javascript</xsl:attribute>
					<xsl:attribute name="src">
						<xsl:value-of select="$config-script" />
					</xsl:attribute>
				</xsl:element>
			</xsl:if>
			
			<!-- add a generator meta element -->
			<xsl:element name="meta">
				<xsl:attribute name="name">generator</xsl:attribute>
				<xsl:attribute name="content">XSD2HTML2XML v3: https://github.com/MichielCM/xsd2html2xml</xsl:attribute>
				
				<!-- if an xml document has been provided, save it as an attribute to the meta element -->
				<xsl:if test="not($xml-document = '')">
					<xsl:attribute name="data-xsd2html2xml-source">
						<xsl:apply-templates select="$xml-document" mode="serialize" />
					</xsl:attribute>
				</xsl:if>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<!-- root match from which all other templates are invoked -->
	<xsl:template name="handle-schema">
		<xsl:call-template name="inform">
			<xsl:with-param name="message">
				<text>XSD file detected.</text>
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="init" />
			
		<xsl:call-template name="log">
			<xsl:with-param name="reference">xs:schema</xsl:with-param>
		</xsl:call-template>
		
		<!-- save root-document for future use -->
		<xsl:variable name="root-document" select="/*" />
		
		<!-- load root-namespaces for future use -->
		<xsl:variable name="root-namespaces">
			<xsl:call-template name="inform">
				<xsl:with-param name="message">
					<xsl:text>Namespaces in root document:</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			
			<xsl:for-each select="namespace::*">
				<xsl:element name="root-namespace">
					<xsl:call-template name="inform">
						<xsl:with-param name="message">
							<xsl:if test="not(name() = '')">
								<xsl:value-of select="name()" />
								<xsl:text>:</xsl:text>
							</xsl:if>
							<xsl:value-of select="." />
						</xsl:with-param>
					</xsl:call-template>
					
					<xsl:if test="not(name() = '')">
						<xsl:attribute name="prefix">
							<xsl:value-of select="name()" />
							<xsl:text>:</xsl:text>
						</xsl:attribute>
					</xsl:if>
					<xsl:attribute name="namespace">
						<xsl:value-of select="." />
					</xsl:attribute>
				</xsl:element>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:element name="body">
			<xsl:element name="form">
				<!-- disable default form action -->
				<xsl:attribute name="action">javascript:void(0);</xsl:attribute>
				
				<!-- add class for scoping -->
				<xsl:attribute name="class">xsd2html2xml</xsl:attribute>
				
				<!-- specify action on submit -->
				<xsl:attribute name="onsubmit">
					<xsl:value-of select="$config-callback" />
					<xsl:text>(htmlToXML(this));</xsl:text>
				</xsl:attribute>
				
				<!-- add custom appinfo data -->
				<xsl:for-each select="xs:annotation/xs:appinfo/*">
					<xsl:call-template name="add-appinfo" />
				</xsl:for-each>
				
				<!-- start parsing the XSD from the top -->
				<xsl:for-each select="xs:element">
					<!-- use the element with the position indicated in config-root as root, or default to the first (usually the only) root element -->
					<xsl:if test="($config-root = '' and position() = 1) or position() = $config-root">
						<xsl:call-template name="forward-root">
							<xsl:with-param name="stylesheet" select="$root-element-stylesheet" />
							<xsl:with-param name="template">handle-root-element</xsl:with-param>
							<xsl:with-param name="root-document" select="//xs:schema" />
							<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						</xsl:call-template>
					</xsl:if>
				</xsl:for-each>
				
				<xsl:element name="button">
					<xsl:attribute name="type">submit</xsl:attribute>
				</xsl:element>
			</xsl:element>
		</xsl:element>
		
		<xsl:call-template name="inform">
			<xsl:with-param name="message">
				<xsl:text>XSLT processing completed.</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
</xsl:stylesheet>