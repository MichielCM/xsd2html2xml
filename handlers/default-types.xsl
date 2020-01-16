<?xml version="1.0"?>
<xsl:stylesheet
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<xsl:template name="generate-input">
		<xsl:param name="root-document" /> <!-- contains root document -->
		<xsl:param name="root-path" /> <!-- contains path from root to included and imported documents -->
		<xsl:param name="root-namespaces" /> <!-- contains root document's namespaces and prefixes -->
		
		<xsl:param name="namespace-documents" /> <!-- contains all documents in element namespace -->
		
		<xsl:param name="description" /> <!-- contains preferred description for element -->
		<xsl:param name="type" /> <!-- contains primitive type -->
		<xsl:param name="attribute" /> <!-- boolean indicating whether or not node is an attribute -->
		<xsl:param name="disabled" /> <!-- boolean indicating whether or not generated element should be disabled -->
		<xsl:param name="pattern" /> <!-- regex pattern to be applied to element input -->
		<xsl:param name="min-length" /> <!-- minLength attribute used to determine if generated element should be optional -->
		<xsl:param name="whitespace" /> <!-- whitespace rule to be applied to element input -->
		
		<xsl:element name="input">
			<xsl:attribute name="type">
				<!-- primive type determines the input element type -->
				<xsl:choose>
					<xsl:when test="$type = 'string' or $type = 'normalizedstring' or $type = 'token' or $type = 'language'">
						<xsl:text>text</xsl:text>
					</xsl:when>
					<xsl:when test="$type = 'decimal' or $type = 'float' or $type = 'double' or $type = 'integer' or $type = 'byte' or $type = 'int' or $type = 'long' or $type = 'positiveinteger' or $type = 'negativeinteger' or $type = 'nonpositiveinteger' or $type = 'nonnegativeinteger' or $type = 'short' or $type = 'unsignedlong' or $type = 'unsignedint' or $type = 'unsignedshort' or $type = 'unsignedbyte' or $type = 'gday' or $type = 'gmonth' or $type = 'gyear'">
						<xsl:text>number</xsl:text>
					</xsl:when>
					<xsl:when test="$type = 'boolean'">
						<xsl:text>checkbox</xsl:text>
					</xsl:when>
					<xsl:when test="$type = 'datetime'">
						<xsl:text>datetime-local</xsl:text>
					</xsl:when>
					<xsl:when test="$type = 'date' or $type = 'gmonthday'">
						<xsl:text>date</xsl:text>
					</xsl:when>
					<xsl:when test="$type = 'time'">
						<xsl:text>time</xsl:text>
					</xsl:when>
					<xsl:when test="$type = 'gyearmonth'">
						<xsl:text>month</xsl:text>
					</xsl:when>
					<xsl:when test="$type = 'anyuri'">
						<xsl:text>url</xsl:text>
					</xsl:when>
					<xsl:when test="$type = 'base64binary' or $type = 'hexbinary'">
						<xsl:text>file</xsl:text>
					</xsl:when>
					<xsl:when test="$type = 'duration'">
						<xsl:text>range</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>text</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			
			<!-- specifically set the value attribute in the HTML to enable XSLT processing of the form contents -->
			<xsl:attribute name="onchange">
				<xsl:choose>
					<xsl:when test="$type = 'boolean'"> <!-- Use the checked value of checkboxes -->
						<xsl:text>if (this.checked) { this.setAttribute("checked","checked") } else { this.removeAttribute("checked") }</xsl:text>
					</xsl:when>
					<xsl:when test="$type = 'base64binary' or $type = 'hexbinary'"> <!-- Use the FileReader API to set the value of file inputs -->
						<xsl:text>pickFile(this, arguments[0].target.files[0], "</xsl:text>
						<xsl:value-of select="$type" />
						<xsl:text>");</xsl:text>
					</xsl:when>
					<xsl:when test="$type = 'datetime' or $type = 'time'"> 
						<xsl:text>if (this.value) { this.setAttribute("value", (this.value.match(/.*\d\d:\d\d:\d\d/) ? this.value : this.value.concat(":00"))); } else { this.removeAttribute("value"); };</xsl:text>
					</xsl:when>
					<xsl:when test="$type = 'gday'"> 
						<xsl:text>if (this.value) { this.setAttribute("value", (this.value.length == 2 ? "---" : "---0").concat(this.value)); } else { this.removeAttribute("value"); };</xsl:text>
					</xsl:when>
					<xsl:when test="$type = 'gmonth'"> 
						<xsl:text>if (this.value) { this.setAttribute("value", (this.value.length == 2 ? "--" : "--0").concat(this.value)); } else { this.removeAttribute("value"); };</xsl:text>
					</xsl:when>
					<xsl:when test="$type = 'gmonthday'"> 
						<xsl:text>if (this.value) { this.setAttribute("value", this.value.replace(/^\d+/, "-")); } else { this.removeAttribute("value"); };</xsl:text>
					</xsl:when>
					<xsl:when test="$type = 'duration'"> <!-- Use the output element for ranges -->
						<xsl:text>this.setAttribute("value", "</xsl:text><xsl:call-template name="get-duration-info"><xsl:with-param name="type">prefix</xsl:with-param><xsl:with-param name="pattern" select="$pattern" /></xsl:call-template>".concat(this.value).concat("<xsl:call-template name="get-duration-info"><xsl:with-param name="type">abbreviation</xsl:with-param><xsl:with-param name="pattern" select="$pattern" /></xsl:call-template><xsl:text>")); this.previousElementSibling.textContent = this.value;</xsl:text>
					</xsl:when>
					<xsl:otherwise> <!-- Use value if otherwise -->
						<xsl:text>if (this.value) { this.setAttribute("value", this.value</xsl:text><xsl:if test="$whitespace = 'replace'">.replace(/\s/g, " ")</xsl:if><xsl:if test="$whitespace = 'collapse'">.replace(/\s+/g, " ").trim()</xsl:if><xsl:text>); } else { this.removeAttribute("value"); };</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			
			<!-- attribute can have optional use=required values; normal elements are always required -->
			<xsl:if test="($attribute = 'true' and @use = 'required') or not($attribute = 'true')">
				<xsl:choose><!-- in case of base64binary or hexbinary, default values cannot be set to an input[type=file] element; because of this, a required attribute on these elements is omitted when fixed, default, or data is found -->
					<xsl:when test="($type = 'base64binary' or $type = 'hexbinary') and (@fixed or @default)"> <!-- or (not($invisible = 'true')) -->
						<xsl:attribute name="data-xsd2html2xml-required">true</xsl:attribute>
					</xsl:when>
					<xsl:when test="$type = 'string' or $type = 'normalizedstring' or $type = 'token'">
						<xsl:if test="$min-length = '' or $min-length > 0">
							<xsl:attribute name="required">required</xsl:attribute>
						</xsl:if>
					</xsl:when>
					<xsl:when test="not($type = 'boolean')">
						<xsl:attribute name="required">required</xsl:attribute>
					</xsl:when>
				</xsl:choose>
			</xsl:if>
			
			<!-- attributes can be prohibited, rendered as readonly -->
			<xsl:if test="@use = 'prohibited'">
				<xsl:attribute name="readonly">readonly</xsl:attribute>
			</xsl:if>
			
			<xsl:call-template name="set-type-specifics">
				<xsl:with-param name="root-document" select="$root-document" />
				<xsl:with-param name="root-path" select="$root-path" />
				<xsl:with-param name="root-namespaces" select="$root-namespaces" />
				
				<xsl:with-param name="namespace-documents" select="$namespace-documents" />
			</xsl:call-template>
			
			<xsl:call-template name="set-type-defaults">
				<xsl:with-param name="root-document" select="$root-document" />
				<xsl:with-param name="root-path" select="$root-path" />
				<xsl:with-param name="root-namespaces" select="$root-namespaces" />
				
				<xsl:with-param name="namespace-documents" select="$namespace-documents" />
				
				<xsl:with-param name="type">
					<xsl:value-of select="$type"/>
				</xsl:with-param>
			</xsl:call-template>
			
			<!-- disabled elements are used to omit invisible placeholders from inclusion in the validation and generated xml data -->
			<xsl:if test="$disabled = 'true'">
				<xsl:attribute name="disabled">disabled</xsl:attribute>
			</xsl:if>
			
			<xsl:attribute name="data-xsd2html2xml-primitive">
				<xsl:value-of select="$type" />
			</xsl:attribute>
			
			<xsl:attribute name="data-xsd2html2xml-description">
				<xsl:value-of select="$description" />
			</xsl:attribute>
			
			<xsl:if test="$type = 'duration'">
				<xsl:attribute name="data-xsd2html2xml-duration">
					<xsl:call-template name="get-duration-info">
						<xsl:with-param name="type">description</xsl:with-param>
						<xsl:with-param name="pattern" select="$pattern" />
					</xsl:call-template>
				</xsl:attribute>
			</xsl:if>
			
			<xsl:if test="@fixed">
				<xsl:attribute name="readonly">readonly</xsl:attribute>
			</xsl:if>
			
			<xsl:choose>
				<!-- use fixed attribute as data if specified -->
				<xsl:when test="@fixed">
					<xsl:choose>
						<xsl:when test="$type = 'boolean'">
							<xsl:if test="@fixed = 'true'">
								<xsl:attribute name="checked">checked</xsl:attribute>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="value">
								<xsl:value-of select="@fixed"/>
							</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<!-- use default attribute as data if specified; overridden later if populated -->
				<xsl:when test="@default">
					<xsl:choose>
						<xsl:when test="$type = 'boolean'">
							<xsl:if test="@default = 'true'">
								<xsl:attribute name="checked">checked</xsl:attribute>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="value">
								<xsl:value-of select="@default"/>
							</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
</xsl:stylesheet>