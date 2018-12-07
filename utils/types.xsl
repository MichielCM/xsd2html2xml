<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<!-- Returns the type directly specified by the calling node -->
	<xsl:template name="get-type">
		<xsl:call-template name="log">
			<xsl:with-param name="reference">get-type</xsl:with-param>
		</xsl:call-template>
		
		<xsl:if test="@type">
			<xsl:value-of select="@type"/>
		</xsl:if>
	</xsl:template>
	
	<!-- Returns the base type (e.g. @type, extensions' @base, restrictions' @base) of the calling node -->
	<xsl:template name="get-base-type">
		<xsl:call-template name="log">
			<xsl:with-param name="reference">get-base-type</xsl:with-param>
		</xsl:call-template>
		
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
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">get-primitive-type</xsl:with-param>
		</xsl:call-template>
		
		<xsl:variable name="type">
			<xsl:call-template name="get-base-type" />
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="not(contains($type, ':')) or (contains($type, ':') and not(starts-with($type, $root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix)))">
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
					<xsl:with-param name="stylesheet" select="$types-stylesheet" />
					<xsl:with-param name="template">get-primitive-type-forwardee</xsl:with-param>
					
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
					
					<xsl:with-param name="type-suffix">
						<xsl:call-template name="get-suffix">
							<xsl:with-param name="string" select="$type" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="translate($type, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="get-primitive-type-forwardee" match="xsl:template[@name = 'get-primitive-type-forwardee']">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		
		<xsl:param name="type-suffix" /> <!-- contains element base type -->
		
		<xsl:param name="node" />
		
		<xsl:choose>
			<!-- if called from forward, call it again with with $node as calling node -->
			<xsl:when test="name() = 'xsl:template'">
				<xsl:for-each select="$node">
					<xsl:call-template name="get-primitive-type-forwardee">
						<xsl:with-param name="root-document" select="$root-document" />
						<xsl:with-param name="root-path" select="$root-path" />
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						
						<xsl:with-param name="namespace-documents" select="$namespace-documents" />
						
						<xsl:with-param name="type-suffix" select="$type-suffix" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<!-- else continue processing -->
			<xsl:otherwise>
				<xsl:call-template name="log">
					<xsl:with-param name="reference">get-primitive-type-recursively</xsl:with-param>
				</xsl:call-template>
				
				<!-- call get-primitive-type on all matching types named type suffix -->
				<xsl:for-each select="$namespace-documents//xs:simpleType[@name=$type-suffix]
					|$namespace-documents//xs:complexType[@name=$type-suffix]">
					<xsl:call-template name="get-primitive-type">
						<xsl:with-param name="root-document" select="$root-document" />
						<xsl:with-param name="root-path" select="$root-path" />
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>