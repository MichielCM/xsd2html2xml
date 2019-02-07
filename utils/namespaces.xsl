<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<!-- Returns namespace name corresponding to supplied prefix -->
	<!-- Optionally returns targetNamespace if no namespace is specified -->
	<xsl:template name="get-namespace">
		<xsl:param name="namespace-prefix" /> <!-- Prefix of namespace that should be returned -->
		<xsl:param name="default-targetnamespace">true</xsl:param> <!-- optionally return targetNamespace if no namespace is specified -->
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">get-namespace</xsl:with-param>
		</xsl:call-template>
		
		<xsl:variable name="namespace">
			<xsl:for-each select="namespace::*">
				<xsl:choose>
					<xsl:when test="contains($namespace-prefix, ':')">
						<xsl:if test="name() = substring-before($namespace-prefix,':')">
							<xsl:value-of select="." />
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="name() = $namespace-prefix">
							<xsl:value-of select="." />
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$namespace = '' and $default-targetnamespace = 'true'">
				<xsl:value-of select="(//xs:schema)[1]/@targetNamespace" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$namespace" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- removes duplicate document elements -->
	<xsl:template name="remove-duplicates" match="xsl:template[@name = 'remove-duplicates']">
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">remove-duplicates</xsl:with-param>
		</xsl:call-template>
		
		<xsl:element name="documents">
			<xsl:for-each select="$namespace-documents//document">
				<xsl:variable name="url" select="@url" />
				
				<!-- copy document only if it has no preceding siblings with the same url -->
				<xsl:if test="count(preceding-sibling::document[@url=$url]) = 0">
					<xsl:copy-of select="." />
				</xsl:if>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	
	<!-- returns documents belonging to a specific namespace -->
	<xsl:template name="get-namespace-documents">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		
		<xsl:param name="namespace" /> <!-- namespace name whose documents are returned -->
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">get-namespace-documents</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="forward">
			<xsl:with-param name="stylesheet" select="$namespaces-stylesheet" />
			<xsl:with-param name="template">remove-duplicates</xsl:with-param>

			<xsl:with-param name="namespace-documents">
				<xsl:call-template name="get-namespace-documents-recursively">
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					
					<xsl:with-param name="namespace" select="$namespace" />
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- Returns an element's namespace documents recursively -->
	<xsl:template name="get-namespace-documents-recursively">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		
		<xsl:param name="namespace" /> <!-- namespace name whose documents are returned -->
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">get-namespace-documents-recursively</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="inform">
			<xsl:with-param name="message">
				<xsl:choose>
					<xsl:when test="$namespace = ''">
						<xsl:text>Resolving documents for default namespace</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Resolving documents for namespace </xsl:text>
						<xsl:value-of select="$namespace" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:variable name="target-namespace">
			<xsl:value-of select="(//xs:schema)[1]/@targetNamespace" />
		</xsl:variable>
		
		<xsl:element name="documents">
			<xsl:if test="$namespace = $target-namespace">
				<!-- add current document -->
				<xsl:call-template name="inform">
					<xsl:with-param name="message">
						<xsl:text>Resolving calling document</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				
				<xsl:element name="document">
					<xsl:attribute name="namespace">
						<xsl:value-of select="$namespace" />
					</xsl:attribute>
					
					<xsl:copy-of select="(//xs:schema)[1]" />
				</xsl:element>
			</xsl:if>
			
			<xsl:call-template name="add-namespace-document-recursively">
				<xsl:with-param name="document" select="//xs:schema" />
				<xsl:with-param name="root-document" select="$root-document" />
				<xsl:with-param name="namespace" select="$namespace" />
			</xsl:call-template>
		</xsl:element>
	</xsl:template>

	<!-- recursively returns documents from specific include or import elements -->
	<xsl:template name="add-namespace-document-recursively">
		<xsl:param name="document" />
		<xsl:param name="root-document" />
		<xsl:param name="namespace" />
		
		<!-- add each document referenced through include or import -->
		<xsl:for-each select="$document//xs:include|$document//xs:import[@namespace = $namespace]">
			<!-- add only include elements that have the correct namespace -->
			<xsl:if test="local-name() = 'import' or 
				(local-name() = 'include' and
					(not($namespace = '') and $document/@targetNamespace = $namespace) or
					($namespace = '' and count($document[not(@targetNamespace)]) &gt; 0))">
			
				<xsl:call-template name="inform">
					<xsl:with-param name="message">
						<xsl:text>Resolving </xsl:text>
						<xsl:value-of select="string(@schemaLocation)" />
					</xsl:with-param>
				</xsl:call-template>
	
				<xsl:element name="document">
					<xsl:attribute name="url">
						<xsl:value-of select="string(@schemaLocation)" />
					</xsl:attribute>
					
					<xsl:attribute name="namespace">
						<xsl:value-of select="$namespace" />
					</xsl:attribute>
	
					<xsl:copy-of select="document(string(@schemaLocation), $root-document)" />
				</xsl:element>
	
			<!-- add documents recursively: add documents in referenced documents -->
				<xsl:call-template name="add-namespace-document-recursively">
					<xsl:with-param name="document" select="document(string(@schemaLocation), $root-document)//xs:schema" />
					<xsl:with-param name="root-document" select="document(string(@schemaLocation), $root-document)" />
					<xsl:with-param name="namespace" select="$namespace" />
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
		
	<!-- Returns the current element's namespace documents -->
	<!-- Shortcut method for getting prefix, getting namespace, and loading namespace documents -->
	<xsl:template name="get-my-namespace-documents">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">get-my-namespace-documents</xsl:with-param>
		</xsl:call-template>
		
		<xsl:variable name="type">
			<xsl:call-template name="get-type"/>
		</xsl:variable>
		
		<xsl:if test="not(contains($type, ':')) or not(starts-with($type, $root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix))">
			<xsl:call-template name="get-namespace-documents">
				<xsl:with-param name="namespace">
					<xsl:call-template name="get-namespace">
						<xsl:with-param name="namespace-prefix">
							<xsl:call-template name="get-prefix">
								<xsl:with-param name="root-namespaces" select="$root-namespaces" />
								<xsl:with-param name="string" select="$type" />
								<xsl:with-param name="include-colon">true</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="root-document" select="$root-document" />
				<xsl:with-param name="root-path" select="$root-path" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>