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
				<xsl:value-of select="//xs:schema/@targetNamespace" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$namespace" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Returns an element's namespace documents -->
	<xsl:template name="get-namespace-documents">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		
		<xsl:param name="namespace" /> <!-- namespace name whose documents are returned -->
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">get-namespace-documents</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="inform">
			<xsl:with-param name="message">
				<xsl:text>Resolving documents for namespace </xsl:text>
				<xsl:value-of select="$namespace" />
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:variable name="target-namespace">
			<xsl:value-of select="(//xs:schema)[1]/@targetNamespace" />
		</xsl:variable>
		
		<xsl:element name="documents">
			<xsl:for-each select="//xs:import[@namespace = $namespace]">
				<xsl:call-template name="inform">
					<xsl:with-param name="message">
						<xsl:text>Resolving </xsl:text>
						<xsl:value-of select="string(@schemaLocation)" />
					</xsl:with-param>
				</xsl:call-template>
				
				<xsl:element name="document">
					<xsl:attribute name="namespace">
						<xsl:value-of select="$namespace" />
					</xsl:attribute>
					
					<xsl:copy-of select="document(string(@schemaLocation), $root-document)" />
				</xsl:element>
			</xsl:for-each>
			
			<xsl:if  test="$namespace = $target-namespace">
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
					
					<xsl:copy-of select="//xs:schema" />
				</xsl:element>
				
				<xsl:for-each select="//xs:include">
					<xsl:call-template name="inform">
						<xsl:with-param name="message">
							<xsl:text>Resolving </xsl:text>
							<xsl:value-of select="string(@schemaLocation)" />
						</xsl:with-param>
					</xsl:call-template>
					
					<xsl:element name="document">
						<xsl:attribute name="namespace">
							<xsl:value-of select="$namespace" />
						</xsl:attribute>
						
						<xsl:copy-of select="document(string(@schemaLocation), $root-document)" />
					</xsl:element>
				</xsl:for-each>
			</xsl:if>
		</xsl:element>
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