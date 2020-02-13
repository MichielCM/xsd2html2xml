<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<!-- applies templates recursively, overwriting lower-level options -->
	<xsl:template name="set-type-specifics">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">set-type-specifics</xsl:with-param>
		</xsl:call-template>
		
		<xsl:variable name="type">
			<xsl:call-template name="get-base-type" />
		</xsl:variable>
		
		<xsl:if test="not(contains($type, ':')) or (contains($type, ':') and not(starts-with($type, $root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix)))">
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
				<xsl:with-param name="stylesheet" select="$gui-attributes-stylesheet" />
				<xsl:with-param name="template">set-type-specifics-forwardee</xsl:with-param>
				
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
		</xsl:if>
		
		<xsl:apply-templates select=".//xs:restriction/xs:minInclusive" />
		<xsl:apply-templates select=".//xs:restriction/xs:maxInclusive" />
		
		<xsl:apply-templates select=".//xs:restriction/xs:minExclusive" />
		<xsl:apply-templates select=".//xs:restriction/xs:maxExclusive" />
		
		<xsl:apply-templates select=".//xs:restriction/xs:pattern" />
		<xsl:apply-templates select=".//xs:restriction/xs:length" />
		<xsl:apply-templates select=".//xs:restriction/xs:maxLength" />
	</xsl:template>
	
	<xsl:template name="set-type-specifics-forwardee" match="xsl:template[@name = 'set-type-specifics-forwardee']">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		
		<xsl:param name="type-suffix" /> <!-- contains element's base type suffix -->
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">set-type-specifics-recursively</xsl:with-param>
		</xsl:call-template>
		
		<xsl:for-each select="$namespace-documents//xs:simpleType[@name=$type-suffix]
			|$namespace-documents//xs:complexType[@name=$type-suffix]">
			<xsl:call-template name="set-type-specifics">
				<xsl:with-param name="root-document" select="$root-document" />
				<xsl:with-param name="root-path" select="$root-path" />
				<xsl:with-param name="root-namespaces" select="$root-namespaces" />
				
				<xsl:with-param name="namespace-documents" select="$namespace-documents" />
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<!-- sets default values for xs:* types, but does not override already specified values -->
	<xsl:template name="set-type-defaults">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		
		<xsl:param name="type"/> <!-- contains element's primitive type -->
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">set-type-defaults</xsl:with-param>
		</xsl:call-template>
		
		<xsl:variable name="fractionDigits">
			<xsl:call-template name="attr-value">
				<xsl:with-param name="attr"><xsl:value-of select="$root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix" />fractionDigits</xsl:with-param>
				<xsl:with-param name="root-document" select="$root-document" />
				<xsl:with-param name="root-path" select="$root-path" />
				<xsl:with-param name="root-namespaces" select="$root-namespaces" />
				<xsl:with-param name="namespace-documents" select="$namespace-documents" />
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$type = 'decimal'">
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
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'float'">
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
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'double'">
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
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'byte'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">-128</xsl:with-param>
					<xsl:with-param name="max-value">127</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">[-]?</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'unsignedbyte'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">0</xsl:with-param>
					<xsl:with-param name="max-value">255</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix" />
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'short'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">-32768</xsl:with-param>
					<xsl:with-param name="max-value">32767</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">[-]?</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'unsignedshort'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">0</xsl:with-param>
					<xsl:with-param name="max-value">65535</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix" />
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'int'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">-2147483648</xsl:with-param>
					<xsl:with-param name="max-value">2147483647</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">[-]?</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'integer'">
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">[-]?</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'nonpositiveinteger'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="max-value">0</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">[-]?</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'nonnegativeinteger'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">0</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix" />
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'positiveinteger'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">1</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix" />
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'negativeinteger'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="max-value">-1</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">[-]?</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'unsignedint'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">0</xsl:with-param>
					<xsl:with-param name="max-value">4294967295</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix" />
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'long'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">-9223372036854775808</xsl:with-param>
					<xsl:with-param name="max-value">9223372036854775807</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">[-]?</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'unsignedlong'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">0</xsl:with-param>
					<xsl:with-param name="max-value">18446744073709551615</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix" />
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'datetime'">
				<xsl:attribute name="step">1</xsl:attribute>
			</xsl:when>
			<xsl:when test="$type = 'time'">
				<xsl:attribute name="step">1</xsl:attribute>
			</xsl:when>
			<xsl:when test="$type = 'gday'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">1</xsl:with-param>
					<xsl:with-param name="max-value">31</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
				<xsl:attribute name="step">1</xsl:attribute>
			</xsl:when>
			<xsl:when test="$type = 'gmonth'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">1</xsl:with-param>
					<xsl:with-param name="max-value">12</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
				<xsl:attribute name="step">1</xsl:attribute>
			</xsl:when>
			<xsl:when test="$type = 'gyear'">
				<xsl:call-template name="set-numeric-range">
					<xsl:with-param name="min-value">1000</xsl:with-param>
					<xsl:with-param name="max-value">9999</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
				<xsl:attribute name="step">1</xsl:attribute>
			</xsl:when>
			<xsl:when test="$type = 'duration'">
				<xsl:attribute name="step">1</xsl:attribute>
			</xsl:when>
			<xsl:when test="$type = 'language'">
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">([a-zA-Z]{2}|[iI]-[a-zA-Z]+|[xX]-[a-zA-Z]{1,8})(-[a-zA-Z]{1,8})*</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$type = 'id'">
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="prefix">(?!_)[_A-Za-z][-._A-Za-z0-9]*</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="set-pattern">
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- sets min and max attributes if they have not been specified explicitly -->
	<xsl:template name="set-numeric-range">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		
		<xsl:param name="min-value" />
		<xsl:param name="max-value" />
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">set-numeric-range</xsl:with-param>
		</xsl:call-template>
		
		<xsl:variable name="minInclusive">
			<xsl:call-template name="attr-value">
				<xsl:with-param name="attr"><xsl:value-of select="$root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix" />minInclusive</xsl:with-param>
				<xsl:with-param name="root-document" select="$root-document" />
				<xsl:with-param name="root-path" select="$root-path" />
				<xsl:with-param name="root-namespaces" select="$root-namespaces" />
				<xsl:with-param name="namespace-documents" select="$namespace-documents" />
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="minExclusive">
			<xsl:call-template name="attr-value">
				<xsl:with-param name="attr"><xsl:value-of select="$root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix" />minExclusive</xsl:with-param>
				<xsl:with-param name="root-document" select="$root-document" />
				<xsl:with-param name="root-path" select="$root-path" />
				<xsl:with-param name="root-namespaces" select="$root-namespaces" />
				<xsl:with-param name="namespace-documents" select="$namespace-documents" />
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:if test="$minInclusive = '' and $minExclusive = '' and not($min-value = '')">
			<xsl:attribute name="min">
				<xsl:value-of select="$min-value"/>
			</xsl:attribute>
		</xsl:if>
		
		<xsl:variable name="maxInclusive">
			<xsl:call-template name="attr-value">
				<xsl:with-param name="attr"><xsl:value-of select="$root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix" />maxInclusive</xsl:with-param>
				<xsl:with-param name="root-document" select="$root-document" />
				<xsl:with-param name="root-path" select="$root-path" />
				<xsl:with-param name="root-namespaces" select="$root-namespaces" />
				<xsl:with-param name="namespace-documents" select="$namespace-documents" />
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="maxExclusive">
			<xsl:call-template name="attr-value">
				<xsl:with-param name="attr"><xsl:value-of select="$root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix" />maxExclusive</xsl:with-param>
				<xsl:with-param name="root-document" select="$root-document" />
				<xsl:with-param name="root-path" select="$root-path" />
				<xsl:with-param name="root-namespaces" select="$root-namespaces" />
				<xsl:with-param name="namespace-documents" select="$namespace-documents" />
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:if test="$maxInclusive = '' and $maxExclusive = '' and not($max-value = '')">
			<xsl:attribute name="max">
				<xsl:value-of select="$max-value"/>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>
	
	<!-- sets pattern attribute if it has not been specified explicitly -->
	<!-- numeric types (depending on totalDigits and fractionDigits) get regex patterns allowing digits and not counting the - and . -->
	<!-- other types (depending on minLength, maxLength, and length) get simpler regex patterns allowing any characters -->
	<xsl:template name="set-pattern">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		
		<xsl:param name="prefix">.</xsl:param>
		<xsl:param name="allow-dot">false</xsl:param>
		
		<xsl:call-template name="log">
			<xsl:with-param name="reference">set-pattern</xsl:with-param>
		</xsl:call-template>
		
		<xsl:variable name="pattern">
			<xsl:call-template name="attr-value">
				<xsl:with-param name="attr"><xsl:value-of select="$root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix" />pattern</xsl:with-param>
				<xsl:with-param name="root-document" select="$root-document" />
				<xsl:with-param name="root-path" select="$root-path" />
				<xsl:with-param name="root-namespaces" select="$root-namespaces" />
				<xsl:with-param name="namespace-documents" select="$namespace-documents" />
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:if test="$pattern=''">
			<xsl:variable name="length">
				<xsl:call-template name="attr-value">
					<xsl:with-param name="attr"><xsl:value-of select="$root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix" />length</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="minLength">
				<xsl:call-template name="attr-value">
					<xsl:with-param name="attr"><xsl:value-of select="$root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix" />minLength</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="maxLength">
				<xsl:call-template name="attr-value">
					<xsl:with-param name="attr"><xsl:value-of select="$root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix" />maxLength</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="totalDigits">
				<xsl:call-template name="attr-value">
					<xsl:with-param name="attr"><xsl:value-of select="$root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix" />totalDigits</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="fractionDigits">
				<xsl:call-template name="attr-value">
					<xsl:with-param name="attr"><xsl:value-of select="$root-namespaces//root-namespace[@namespace = 'http://www.w3.org/2001/XMLSchema']/@prefix" />fractionDigits</xsl:with-param>
					<xsl:with-param name="root-document" select="$root-document" />
					<xsl:with-param name="root-path" select="$root-path" />
					<xsl:with-param name="root-namespaces" select="$root-namespaces" />
					<xsl:with-param name="namespace-documents" select="$namespace-documents" />
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
	
	<xsl:template match="xs:minInclusive">
		<xsl:attribute name="min">
			<xsl:value-of select="translate(@value,translate(@value, '0123456789.-', ''), '')"/> <!-- use double-translate function to extract numbers from possible regex input (e.g. for xs:duration) -->
		</xsl:attribute>
	</xsl:template> 
	
	<xsl:template match="xs:maxInclusive">
		<xsl:attribute name="max">
			<xsl:value-of select="translate(@value,translate(@value, '0123456789.-', ''), '')"/> <!-- use double-translate function to extract numbers from possible regex input (e.g. for xs:duration) -->
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="xs:minExclusive">
		<xsl:attribute name="min">
			<xsl:value-of select="number(translate(@value,translate(@value, '0123456789.-', ''), '')) + 1"/> <!-- use double-translate function to extract numbers from possible regex input (e.g. for xs:duration) -->
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="xs:maxExclusive">
		<xsl:attribute name="max">
			<xsl:value-of select="number(translate(@value,translate(@value, '0123456789.-', ''), '')) - 1"/> <!-- use double-translate function to extract numbers from possible regex input (e.g. for xs:duration) -->
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="xs:enumeration">
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
	
	<xsl:template match="xs:pattern">
		<xsl:attribute name="pattern">
			<xsl:value-of select="@value"/>
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="xs:length|xs:maxLength">
		<xsl:attribute name="maxlength">
			<xsl:value-of select="@value"/>
		</xsl:attribute>
	</xsl:template>
	
</xsl:stylesheet>