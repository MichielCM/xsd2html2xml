<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<xsl:template name="generate-select">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		
		<xsl:param name="description" /> <!-- contains preferred description for element -->
		<xsl:param name="type" /> <!-- contains primitive type -->
		<xsl:param name="attribute" /> <!-- boolean indicating whether or not node is an attribute -->
		<xsl:param name="multiple" /> <!-- boolean indicating whether or not generated element should be able to allow for multiple values -->
		<xsl:param name="disabled" /> <!-- boolean indicating whether or not generated element should be disabled -->
		
		<xsl:element name="select">
			<xsl:attribute name="onchange">
				<xsl:text>this.childNodes.forEach(function(o) { if (o.nodeType == Node.ELEMENT_NODE) o.removeAttribute("selected"); }); this.children[this.selectedIndex].setAttribute("selected","selected");</xsl:text>
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
			
			<xsl:attribute name="data-xsd2html2xml-description">
				<xsl:value-of select="$description" />
			</xsl:attribute>
			
			<!-- <xsl:if test="not($invisible = 'true')">
				<xsl:attribute name="data-xsd2html2xml-filled">true</xsl:attribute>
			</xsl:if> -->
			
			<!-- add multiple keyword if several selections are allowed -->
			<xsl:if test="$multiple = 'true'">
				<xsl:attribute name="multiple">multiple</xsl:attribute>
			</xsl:if>
			
			<xsl:attribute name="data-xsd2html2xml-primitive">
				<xsl:value-of select="$type" />
			</xsl:attribute>
			
			<!-- add option to select no value in case of optional attribute -->
			<xsl:if test="$attribute = 'true' and @use = 'optional'">
				<xsl:element name="option">-</xsl:element>
			</xsl:if>
			
			<!-- add options for each value; populate the element if there is corresponding data, or fill it with a fixed or default value -->
			<xsl:call-template name="handle-enumerations">
				<xsl:with-param name="root-document" select="$root-document" />
				<xsl:with-param name="root-path" select="$root-path" />
				<xsl:with-param name="root-namespaces" select="$root-namespaces" />
				
				<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				
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
	</xsl:template>
	
	<!-- Recursively searches for xs:enumeration elements and applies templates on them -->
	<xsl:template name="handle-enumerations">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		
		<xsl:param name="default" />
		<xsl:param name="disabled">false</xsl:param>
		
		<xsl:apply-templates select=".//xs:restriction/xs:enumeration">
			<xsl:with-param name="default" select="$default" />
			<xsl:with-param name="disabled" select="$disabled" />
		</xsl:apply-templates>
		
		<xsl:variable name="namespace">
			<xsl:call-template name="get-namespace">
				<xsl:with-param name="namespace-prefix">
					<xsl:call-template name="get-prefix">
						<xsl:with-param name="root-namespaces" select="$root-namespaces" />
						<xsl:with-param name="string" select="@type" />
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:call-template name="forward">
			<xsl:with-param name="stylesheet" select="$enumerations-stylesheet" />
			<xsl:with-param name="template">handle-enumerations-forwardee</xsl:with-param>
			
			<xsl:with-param name="root-document" select="$root-document" />
			<xsl:with-param name="root-path" select="$root-path" />
			<xsl:with-param name="root-namespaces" select="$root-namespaces" />
			
			<xsl:with-param name="namespace-documents">
				<xsl:choose>
					<xsl:when test="(not($namespace-documents = '') and count($namespace-documents//document) > 0 and $namespace-documents//document[1]/@namespace = $namespace) or (contains(@type, ':') and starts-with(@type, $root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix))">
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
											<xsl:with-param name="string" select="@type" />
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
					<xsl:with-param name="string" select="@type" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="default" select="$default" />
			<xsl:with-param name="disabled" select="$disabled" />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="handle-enumerations-forwardee" match="xsl:template[@name = 'handle-enumerations-forwardee']">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		
		<xsl:param name="type-suffix" />
		<xsl:param name="default" />
		<xsl:param name="disabled" />
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">handle-enumerations-forwardee</xsl:with-param>
		</xsl:call-template>
		
		<xsl:for-each select="$namespace-documents//xs:simpleType[@name=$type-suffix]">
			<xsl:call-template name="handle-enumerations">
				<xsl:with-param name="root-document" select="$root-document" />
				<xsl:with-param name="root-path" select="$root-path" />
				<xsl:with-param name="root-namespaces" select="$root-namespaces" />
				
				<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				
				<xsl:with-param name="default" select="$default" />
				<xsl:with-param name="disabled" select="$disabled" />
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>
