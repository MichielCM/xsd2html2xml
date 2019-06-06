<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<!-- Returns the first value that matches attr name; forward if not found -->
	<xsl:template name="attr-value">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		
		<xsl:param name="attr" /> <!-- contains attribute name whose value is to be returned -->
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">attr-value: <xsl:value-of select="$attr" /></xsl:with-param>
		</xsl:call-template>
		
		<xsl:variable name="type">
			<xsl:call-template name="get-base-type" />
		</xsl:variable>
		
		<xsl:choose>
			<!-- check if element itself contains attribute -->
			<xsl:when test="@*[contains(.,$attr)]">
				<xsl:value-of select="@*[contains(name(),$attr)]"/>
			</xsl:when>
			<!-- check if element restriction contains attribute -->
			<xsl:when test=".//xs:restriction/*[contains(name(),$attr)]">
				<xsl:value-of select=".//xs:restriction/*[contains(name(),$attr)]/@value"/>
			</xsl:when>
			<!-- else, check for inherited attribute values -->
			<xsl:otherwise>
				<xsl:variable name="namespace">
					<xsl:call-template name="get-namespace">
						<xsl:with-param name="namespace-prefix">
							<xsl:call-template name="get-prefix">
								<xsl:with-param name="root-namespaces" select="$root-namespaces" />
								<xsl:with-param name="string" select="$type" />
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				
				<xsl:call-template name="forward">
					<xsl:with-param name="stylesheet" select="$attr-value-stylesheet" />
					<xsl:with-param name="template">attr-value-forwardee</xsl:with-param>
					
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					
					<xsl:with-param name="namespace-documents">
						<xsl:choose>
							<xsl:when test="(not($namespace-documents = '') and count($namespace-documents//document) > 0 and $namespace-documents//document[1]/@namespace = $namespace) or (contains($type, ':') and starts-with($type, $root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix))">
								<xsl:call-template name="inform">
									<xsl:with-param name="message">Reusing loaded namespace documents</xsl:with-param>
								</xsl:call-template>
								
								<xsl:copy-of select="$namespace-documents" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="get-namespace-documents">
									<xsl:with-param name="namespace">
										<xsl:call-template name="get-namespace">
											<xsl:with-param name="namespace-prefix">
												<xsl:call-template name="get-prefix">
													<xsl:with-param name="root-namespaces" select="$root-namespaces" />
													<xsl:with-param name="string" select="$type" />
												</xsl:call-template>
											</xsl:with-param>
										</xsl:call-template>
									</xsl:with-param>
									<xsl:with-param name="root-document" select="$root-document" />
									<xsl:with-param name="root-path" select="$root-path" />
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					
					<xsl:with-param name="attr" select="$attr" />
					<xsl:with-param name="type" select="$type" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- recursive function to use with attr-value -->
	<xsl:template name="attr-value-forwardee" match="xsl:template[@name = 'attr-value-forwardee']">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		
		<xsl:param name="attr" /> <!-- contains attribute name whose value is to be returned -->
		<xsl:param name="type" /> <!-- contains element base type -->
		
		<xsl:param name="node" />
		
		<xsl:choose>
			<!-- if called from forward, call it again with with $node as calling node -->
			<xsl:when test="name() = 'xsl:template'">
				<xsl:for-each select="$node">
					<xsl:call-template name="attr-value-forwardee">
						<xsl:with-param name="root-document" select="$root-document" />
						<xsl:with-param name="root-path" select="$root-path" />
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						
						<xsl:with-param name="namespace-documents" select="$namespace-documents" />
						
						<xsl:with-param name="attr" select="$attr" />
						<xsl:with-param name="type" select="$type" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<!-- else continue processing -->
			<xsl:otherwise>
				<xsl:call-template name="log">
					<xsl:with-param name="reference">attr-value-forwardee</xsl:with-param>
				</xsl:call-template>
				
				<!-- retrieve type suffix for use with matching -->
				<xsl:variable name="type-suffix">
					<xsl:call-template name="get-suffix">
						<xsl:with-param name="string" select="$type" />
					</xsl:call-template>
				</xsl:variable>
				
				<!-- call attr-value on all matching simple types named type suffix -->
				<xsl:for-each select="$namespace-documents//xs:complexType[@name=$type-suffix]
					|$namespace-documents//xs:simpleType[@name=$type-suffix]">
					<xsl:call-template name="attr-value">
						<xsl:with-param name="root-document" select="$root-document" />
						<xsl:with-param name="root-path" select="$root-path" />
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						
						<xsl:with-param name="namespace-documents" select="$namespace-documents" />
						
						<xsl:with-param name="attr" select="$attr" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>