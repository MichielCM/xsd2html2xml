<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">

	<!-- handle simple elements -->
	<!-- handle minOccurs and maxOccurs, calls handle-simple-element for further processing -->
	<xsl:template name="handle-simple-elements">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		<xsl:param name="namespace-prefix" /> <!-- contains inherited namespace prefix -->
		
		<xsl:param name="id" /> <!-- contains node name, or references node name in case of groups; select="@name" -->
		<xsl:param name="min-occurs" /> <!-- contains @minOccurs attribute (for referenced elements) -->
		<xsl:param name="max-occurs" /> <!-- contains @maxOccurs attribute (for referenced elements) -->
		<xsl:param name="choice" /> <!-- handles xs:choice elements and descendants; contains a unique ID for radio buttons of the same group to share -->
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		<xsl:param name="xpath" /> <!-- contains an XPath query relative to the current node, to be used with xml document -->
		
		<!-- ensure any declarations within annotation elements are ignored -->
		<xsl:if test="count(ancestor::xs:annotation) = 0">
			<xsl:call-template name="log">
				<xsl:with-param name="reference">handle-simple-elements</xsl:with-param>
			</xsl:call-template>
			
			<!-- determine type namespace-prefix -->
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
			
			<!-- wrap simple element in section element -->
			<xsl:element name="section">
				<!-- add an attribute to indicate a choice element -->
				<xsl:if test="$choice = 'true'">
					<xsl:attribute name="data-xsd2html2xml-choice">true</xsl:attribute>
				</xsl:if>
				
				<xsl:call-template name="handle-simple-element">
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
					<xsl:with-param name="static">false</xsl:with-param>
					<xsl:with-param name="disabled" select="$disabled" />
					<!-- <xsl:with-param name="xpath" select="concat($xpath,'/*[name() = &quot;',$local-namespace-prefix,@name,'&quot;]')" /> -->
					<xsl:with-param name="xpath" select="concat($xpath,'/',$local-namespace-prefix,@name)" />
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
	
	<!-- handle simple element -->
	<xsl:template name="handle-simple-element">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		<xsl:param name="namespace-prefix"></xsl:param> <!-- contains inherited namespace prefix -->
		<xsl:param name="local-namespace" />
		<xsl:param name="local-namespace-prefix" />
		
		<xsl:param name="id" select="@name" /> <!-- contains node name, or references node name in case of groups -->
		<xsl:param name="min-occurs" /> <!-- contains @minOccurs attribute (for referenced elements) -->
		<xsl:param name="max-occurs" /> <!-- contains @maxOccurs attribute (for referenced elements) -->
		<xsl:param name="description" /> <!-- contains preferred description for element -->
		<xsl:param name="static" /> <!-- indicates whether or not the element may be removed or is 'static' -->
		<xsl:param name="attribute">false</xsl:param> <!-- indicates if the node is an element or an attribute -->
		<xsl:param name="disabled">false</xsl:param> <!-- is used to disable elements that are copies for additional occurrences -->
		<xsl:param name="node-type" select="local-name()" /> <!-- contains the element name, or 'content' in the case of simple content -->
		<xsl:param name="xpath" /> <!-- contains an XPath query relative to the current node, to be used with xml document -->
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">handle-simple-element</xsl:with-param>
		</xsl:call-template>
		
		<xsl:variable name="type"> <!-- holds the primive type (xs:*) with which the element type will be determined -->
			<xsl:call-template name="get-suffix">
				<xsl:with-param name="string">
					<xsl:call-template name="get-primitive-type">
						<xsl:with-param name="root-document" select="$root-document" />
						<xsl:with-param name="root-path" select="$root-path" />
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						<xsl:with-param name="namespace-documents" select="$namespace-documents" />
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:element name="label">
			<!-- metadata required for compiling the xml when the form is submitted -->
			<xsl:attribute name="data-xsd2html2xml-namespace">
				<xsl:value-of select="$local-namespace" />
			</xsl:attribute>
			<xsl:attribute name="data-xsd2html2xml-type">
				<xsl:value-of select="$node-type" />
			</xsl:attribute>
			<xsl:attribute name="data-xsd2html2xml-name">
				<xsl:value-of select="concat($local-namespace-prefix, @name)" />
			</xsl:attribute>
			<xsl:attribute name="data-xsd2html2xml-xpath">
				<xsl:value-of select="$xpath" />
			</xsl:attribute>
			
			<!-- add custom appinfo data -->
			<xsl:for-each select="xs:annotation/xs:appinfo/*">
				<xsl:call-template name="add-appinfo" />
			</xsl:for-each>
			
			<!-- pattern is used later to determine multiline text fields -->
			<xsl:variable name="pattern">
				<xsl:call-template name="attr-value">
					<xsl:with-param name="attr"><xsl:value-of select="$root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix" />pattern</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:variable>
			
			<!-- enumerations are rendered as select elements -->
			<xsl:variable name="choice">
				<xsl:call-template name="attr-value">
					<xsl:with-param name="attr"><xsl:value-of select="$root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix" />enumeration</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:variable>
			
			<!-- in case of xs:duration, an output element is added to show the selected value of the user -->
			<xsl:if test="$type = 'duration'">
				<xsl:element name="output">
					<xsl:attribute name="data-xsd2html2xml-description">
						<xsl:value-of select="$description" />
					</xsl:attribute>
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
						<xsl:with-param name="attr"><xsl:value-of select="$root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix" />whiteSpace</xsl:with-param>
						<xsl:with-param name="root-document" select="$root-document" />
						<xsl:with-param name="root-path" select="$root-path" />
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						<xsl:with-param name="namespace-documents" select="$namespace-documents" />
					</xsl:call-template>
				</xsl:variable>
				
				<xsl:choose>
					<xsl:when test="not($specified-whitespace = '')">
						<xsl:value-of select="$specified-whitespace" />
					</xsl:when>
					<xsl:when test="$type = 'string'">preserve</xsl:when>
					<xsl:when test="$type = 'normalizedstring'">replace</xsl:when>
					<xsl:otherwise>collapse</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:choose>
				<!-- enumerations are rendered as select elements -->
				<xsl:when test="not($choice='')">
					<xsl:call-template name="generate-select">
						<xsl:with-param name="root-document" select="$root-document" />
						<xsl:with-param name="root-path" select="$root-path" />
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						
						<xsl:with-param name="namespace-documents" select="$namespace-documents" />
						
						<xsl:with-param name="description" select="$description" />
						<xsl:with-param name="attribute" select="$attribute" />
						<xsl:with-param name="disabled" select="$disabled" />
					</xsl:call-template>
				</xsl:when>
				<!-- multiline patterns are rendered as textarea elements -->
				<xsl:when test="contains($pattern,'\n')">
					<xsl:call-template name="generate-textarea">
						<xsl:with-param name="root-document" select="$root-document" />
						<xsl:with-param name="root-path" select="$root-path" />
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						
						<xsl:with-param name="namespace-documents" select="$namespace-documents" />
						
						<xsl:with-param name="description" select="$description" />
						<xsl:with-param name="whitespace" select="$whitespace" />
						<xsl:with-param name="attribute" select="$attribute" />
						<xsl:with-param name="disabled" select="$disabled" />
					</xsl:call-template>
				</xsl:when>
				<!-- all other primitive types become input elements -->
				<xsl:otherwise>
					<xsl:call-template name="generate-input">
						<xsl:with-param name="root-document" select="$root-document" />
						<xsl:with-param name="root-path" select="$root-path" />
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						
						<xsl:with-param name="namespace-documents" select="$namespace-documents" />
						
						<xsl:with-param name="description" select="$description" />
						<xsl:with-param name="pattern" select="$pattern" />
						<xsl:with-param name="whitespace" select="$whitespace" />
						<xsl:with-param name="type" select="$type" />
						<xsl:with-param name="attribute" select="$attribute" />
						<xsl:with-param name="disabled" select="$disabled" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- add label description and GUI widgets -->
			<xsl:element name="span">
				<xsl:value-of select="$description"/>
				<!-- <xsl:if test="$type = 'duration'">
					<xsl:text> (</xsl:text>
					<xsl:call-template name="get-duration-info">
						<xsl:with-param name="type">description</xsl:with-param>
						<xsl:with-param name="pattern" select="$pattern" />
					</xsl:call-template>
					<xsl:text>)</xsl:text>
				</xsl:if> -->
				<xsl:if test="not($static = 'true')"> <!-- non-static elements with variable occurrences can be removed -->
					<xsl:call-template name="add-remove-button">
						<xsl:with-param name="min-occurs" select="$min-occurs" />
						<xsl:with-param name="max-occurs" select="$max-occurs" />
					</xsl:call-template>
				</xsl:if>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:stylesheet>