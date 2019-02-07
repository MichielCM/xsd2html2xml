<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">

	<!-- handle complex elements, which optionally contain simple content -->
	<!-- handle minOccurs and maxOccurs, calls handle-complex-element for further processing -->
	<xsl:template name="handle-complex-elements">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		<xsl:param name="namespace-prefix" /> <!-- contains inherited namespace prefix -->
		
		<xsl:param name="id" /> <!-- contains node name, or references node name in case of groups; select="@name" -->
		<xsl:param name="min-occurs" /> <!-- contains @minOccurs attribute (for referenced elements) -->
		<xsl:param name="max-occurs" /> <!-- contains @maxOccurs attribute (for referenced elements) -->
		<xsl:param name="simple" /> <!-- indicates if an element allows simple content -->
		<xsl:param name="choice" /> <!-- handles xs:choice elements and descendants; contains a unique ID for radio buttons of the same group to share -->
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		<xsl:param name="reference">false</xsl:param> <!-- identifies elements that only refer to other elements (e.g. xs:group) -->
		<xsl:param name="xpath" /> <!-- contains an XPath query relative to the current node, to be used with xml document -->
		
		<!-- ensure any declarations within annotation elements are ignored -->
		<xsl:if test="count(ancestor::xs:annotation) = 0">
			<xsl:call-template name="log">
				<xsl:with-param name="reference">handle-complex-elements</xsl:with-param>
			</xsl:call-template>
			
			<!-- determine type namespace prefix -->
			<xsl:variable name="type-namespace-prefix">
				<xsl:choose>
					<!-- reset it if the current element has a non-default prefix -->
					<xsl:when test="contains(@type, ':') and not(starts-with(@type, $root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix))">
						<xsl:call-template name="get-prefix">
							<xsl:with-param name="root-namespaces" select="$root-namespaces" />
							<xsl:with-param name="string" select="@type" />
							<xsl:with-param name="include-colon">true</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<!-- otherwise, use the inherited prefix -->
					<xsl:otherwise>
						<xsl:value-of select="$namespace-prefix" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<!-- determine locally declared namespace -->
			<xsl:variable name="local-namespace">
				<xsl:call-template name="get-namespace">
					<xsl:with-param name="namespace-prefix">
						<xsl:call-template name="get-prefix">
							<xsl:with-param name="root-namespaces" select="$root-namespaces" />
							<xsl:with-param name="string" select="@name" />
							<xsl:with-param name="include-colon">true</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="default-targetnamespace">true</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			
			<!-- extract locally declared namespace prefix from schema declarations -->
			<xsl:variable name="local-namespace-prefix">
				<xsl:choose>
					<xsl:when test="$root-namespaces//root-namespace[@namespace=$local-namespace]">
						<xsl:value-of select="$root-namespaces//root-namespace[@namespace=$local-namespace]/@prefix" />
					</xsl:when>
					<!-- <xsl:otherwise>
						<xsl:value-of select="generate-id()" />
						<xsl:text>:</xsl:text>
					</xsl:otherwise> -->
				</xsl:choose>
			</xsl:variable>
			
			<!-- wrap complex elements in section elements -->
			<xsl:element name="section">
				<!-- add an attribute to indicate a choice element -->
				<xsl:if test="$choice = 'true'">
					<xsl:attribute name="data-xsd2html2xml-choice">true</xsl:attribute>
				</xsl:if>
				
				<!-- call handle-complex-element with loaded documents -->
				<xsl:call-template name="handle-complex-element">
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
					<xsl:with-param name="namespace-prefix" select="$type-namespace-prefix" />
					<xsl:with-param name="local-namespace" select="$local-namespace" />
					<xsl:with-param name="local-namespace-prefix" select="$local-namespace-prefix" />
					
					<xsl:with-param name="id" select="$id" />
					<xsl:with-param name="description">
						<xsl:call-template name="get-description" />
					</xsl:with-param>
					<xsl:with-param name="min-occurs" select="$min-occurs" />
					<xsl:with-param name="max-occurs" select="$max-occurs" />
					<xsl:with-param name="simple" select="$simple" />
					<xsl:with-param name="disabled" select="$disabled" />
					<xsl:with-param name="reference" select="$reference" />
					<xsl:with-param name="xpath">
						<xsl:choose>
							<xsl:when test="$reference = 'true'">
								<xsl:value-of select="$xpath" />
							</xsl:when>
							<xsl:otherwise>
								<!-- <xsl:value-of select="concat($xpath,'/*[name() = &quot;',$local-namespace-prefix,$id,'&quot;]')" /> -->
								<xsl:value-of select="concat($xpath,'/',$local-namespace-prefix,$id)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
				
				<!-- add another element to be used for dynamically inserted elements -->
				<xsl:call-template name="add-add-button">
					<xsl:with-param name="description">
						<xsl:call-template name="get-description" />
					</xsl:with-param>
					<xsl:with-param name="min-occurs" select="$min-occurs" />
					<xsl:with-param name="max-occurs" select="$max-occurs" />
				</xsl:call-template>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<!-- handle complex element -->
	<xsl:template name="handle-complex-element" match="xsl:template[@name = 'handle-complex-element']">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		<xsl:param name="namespace-prefix" /> <!-- contains inherited namespace prefix -->
		<xsl:param name="local-namespace" />
		<xsl:param name="local-namespace-prefix" />
		
		<xsl:param name="id" /> <!-- contains the 'name' attribute of the element; select="$node/@name" -->
		<xsl:param name="description" /> <!-- contains the node's description, either @name or annotation/documentation -->
		<xsl:param name="min-occurs" /> <!-- contains @minOccurs attribute (for referenced elements) -->
		<xsl:param name="max-occurs" /> <!-- contains @maxOccurs attribute (for referenced elements) -->
		<xsl:param name="simple" /> <!-- indicates whether this complex element has simple content -->
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		<xsl:param name="reference" /> <!-- identifies elements that only refer to other elements (e.g. xs:group) -->
		<xsl:param name="xpath" /> <!-- contains an XPath query relative to the current node, to be used with xml document -->
		
		<xsl:param name="node" />
		
		<xsl:choose>
			<!-- if called from forward, call it again with with $node as calling node -->
			<xsl:when test="name() = 'xsl:template'">
				<xsl:for-each select="$node">
					<xsl:call-template name="handle-complex-element">
						<xsl:with-param name="root-document" select="$root-document" />
						<xsl:with-param name="root-path" select="$root-path" />
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						
						<xsl:with-param name="namespace-documents" select="$namespace-documents" />
						<xsl:with-param name="namespace-prefix" select="$namespace-prefix" />
						<xsl:with-param name="local-namespace" select="$local-namespace" />
						<xsl:with-param name="local-namespace-prefix" select="$local-namespace-prefix" />
						
						<xsl:with-param name="id" select="$id"/>
						<xsl:with-param name="description" select="$description" />
						<xsl:with-param name="min-occurs" select="$min-occurs" />
						<xsl:with-param name="max-occurs" select="$max-occurs" />
						<xsl:with-param name="simple" select="$simple"/>
						<xsl:with-param name="disabled" select="$disabled" />
						<xsl:with-param name="reference" select="$reference" />
						<xsl:with-param name="xpath" select="$xpath"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<!-- else continue processing -->
			<xsl:otherwise>
				<xsl:call-template name="log">
					<xsl:with-param name="reference">handle-complex-element</xsl:with-param>
				</xsl:call-template>
				
				<xsl:variable name="type-suffix">
					<xsl:call-template name="get-suffix">
						<xsl:with-param name="string" select="@type" />
					</xsl:call-template>
				</xsl:variable>
				
				<!-- wrap complex element in fieldset element -->
				<xsl:element name="fieldset">
					<!-- add attributes for XML generation -->
					<xsl:if test="not($reference = 'true')">
						<xsl:attribute name="data-xsd2html2xml-namespace">
							<xsl:value-of select="$local-namespace" />
						</xsl:attribute>
						<xsl:attribute name="data-xsd2html2xml-type">
							<xsl:value-of select="local-name()" />
						</xsl:attribute>
						<xsl:attribute name="data-xsd2html2xml-name">
							<xsl:value-of select="concat($local-namespace-prefix, @name)" />
						</xsl:attribute>
						<xsl:attribute name="data-xsd2html2xml-xpath">
							<xsl:value-of select="$xpath" />
						</xsl:attribute>
					</xsl:if>
					
					<!-- add custom appinfo data -->
					<xsl:for-each select="xs:annotation/xs:appinfo/*">
						<xsl:call-template name="add-appinfo" />
					</xsl:for-each>
					
					<!-- use a legend element to contain the description -->
					<xsl:element name="legend">
						<xsl:value-of select="$description" />
						<xsl:call-template name="add-remove-button">
							<xsl:with-param name="min-occurs" select="$min-occurs" />
							<xsl:with-param name="max-occurs" select="$max-occurs" />
						</xsl:call-template>
					</xsl:element>
					
					<xsl:variable name="ref-suffix">
						<xsl:call-template name="get-suffix">
							<xsl:with-param name="string" select="@ref" />
						</xsl:call-template>
					</xsl:variable>
					
					<!-- let child elements be handled by their own templates -->
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
						|xs:complexType/xs:simpleContent/xs:restriction/xs:anyAttribute
						|$namespace-documents//xs:complexType[@name=$type-suffix]/xs:sequence
						|$namespace-documents//xs:complexType[@name=$type-suffix]/xs:all
						|$namespace-documents//xs:complexType[@name=$type-suffix]/xs:choice
						|$namespace-documents//xs:complexType[@name=$type-suffix]/xs:attribute
						|$namespace-documents//xs:complexType[@name=$type-suffix]/xs:attributeGroup
						|$namespace-documents//xs:complexType[@name=$type-suffix]/xs:anyAttribute
						|$namespace-documents//xs:complexType[@name=$type-suffix]/xs:complexContent/xs:restriction/xs:sequence
						|$namespace-documents//xs:complexType[@name=$type-suffix]/xs:complexContent/xs:restriction/xs:all
						|$namespace-documents//xs:complexType[@name=$type-suffix]/xs:complexContent/xs:restriction/xs:choice
						|$namespace-documents//xs:complexType[@name=$type-suffix]/xs:complexContent/xs:restriction/xs:attribute
						|$namespace-documents//xs:complexType[@name=$type-suffix]/xs:complexContent/xs:restriction/xs:attributeGroup
						|$namespace-documents//xs:complexType[@name=$type-suffix]/xs:simpleContent/xs:restriction/xs:attribute
						|$namespace-documents//xs:complexType[@name=$type-suffix]/xs:simpleContent/xs:restriction/xs:attributeGroup
						|$namespace-documents//xs:complexType[@name=$type-suffix]/xs:simpleContent/xs:restriction/xs:anyAttribute
						|$namespace-documents//xs:group[@name=$ref-suffix]/*">
						<xsl:with-param name="root-document" select="$root-document" />
						<xsl:with-param name="root-path" select="$root-path" />
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						
						<xsl:with-param name="namespace-documents" select="$namespace-documents" />
						<xsl:with-param name="namespace-prefix" select="$namespace-prefix" />
						
						<xsl:with-param name="disabled" select="$disabled" />
						<xsl:with-param name="xpath" select="$xpath" />
					</xsl:apply-templates>
					
					<!-- add simple element if the element allows simpleContent -->
					<xsl:if test="$simple = 'true'">
						<xsl:call-template name="handle-simple-element">
							<xsl:with-param name="root-document" select="$root-document" />
							<xsl:with-param name="root-path" select="$root-path" />
							<xsl:with-param name="root-namespaces" select="$root-namespaces" />
							
							<xsl:with-param name="namespace-documents" select="$namespace-documents" />
							<xsl:with-param name="namespace-prefix" select="$namespace-prefix" />
							<xsl:with-param name="local-namespace" select="$local-namespace" />
							<xsl:with-param name="local-namespace-prefix" select="$local-namespace-prefix" />
							
							<xsl:with-param name="description" select="$description" />
							<xsl:with-param name="static">true</xsl:with-param>
							<xsl:with-param name="node-type">content</xsl:with-param>
							<xsl:with-param name="disabled" select="$disabled" />
							<xsl:with-param name="xpath" select="$xpath" />
						</xsl:call-template>
					</xsl:if>
					
					<!-- add inherited extensions to the element -->
					<xsl:call-template name="handle-extensions">
						<xsl:with-param name="root-document" select="$root-document" />
						<xsl:with-param name="root-path" select="$root-path" />
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						
						<xsl:with-param name="namespace-prefix" select="$namespace-prefix" />
						<xsl:with-param name="base">
							<xsl:value-of select="*/*/xs:extension/@base
								|$namespace-documents//xs:complexType[@name=$type-suffix]/*/xs:extension/@base" />
						</xsl:with-param>
						<xsl:with-param name="disabled" select="$disabled" />
						<xsl:with-param name="xpath" select="$xpath" />
					</xsl:call-template>
					
					<!-- add added elements -->
					<xsl:apply-templates select="*/*/xs:extension/*
						|$namespace-documents//xs:complexType[@name=$type-suffix]/*/xs:extension/*">
						<xsl:with-param name="root-document" select="$root-document" />
						<xsl:with-param name="root-path" select="$root-path" />
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						
						<xsl:with-param name="namespace-prefix" select="$namespace-prefix" />
						
						<xsl:with-param name="disabled" select="$disabled" />
						<xsl:with-param name="xpath" select="$xpath" />
					</xsl:apply-templates>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>