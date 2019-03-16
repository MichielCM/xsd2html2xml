<h1>XSD2HTML2XML</h1>
<p>Generates plain HTML5 forms from XML schemas (XSDs). Transforms filled-in forms into XML.</p>
<p>XML schemas contain a wealth of information about what data is allowed in an XML structure, and thus how a user interface should be presented. HTML5 supports many new input types and attributes that are compatible with XML schemas. XSD2HTML2XML automates the process of generating forms from XML schemas and extracting valid XML from them after users fill them out. This makes user-generated entering of well-formed, valid XML input easier than ever before.</p>
<p>In a nutshell:</p>
<ul>
	<li>Generates a plain HTML5 form from any XML schema (XSD);</li>
	<li>Generates schema-conformant XML from filled-out forms;</li>
	<li>Supports populating the generated form with data from an XML document;</li>
	<li>Supports namespaces (including combining schemas through xs:include and xs:import tags);</li>
	<li>Written in fast and widely supported XSLT 1.0 (which means it can run client-side in browsers);</li>
	<li>Has no dependencies;</li>
	<li>Generates pure HTML5 forms with vanilla JavaScript for interactivity;</li>
	<li>Is easily stylable with CSS, or extendable with any library or framework;</li>
	<li>Is free for any purpose (MIT).</li>
</ul>
<h2>Versions</h2>
<h3>Source Code</h3>
<p>It is recommended to always use the <a href="https://github.com/MichielCM/xsd2html2xml/releases/latest">latest release</a>, as the latest commits may contain experimental or untested features.</p>
<ul>
	<li><a href="https://github.com/MichielCM/xsd2html2xml/releases/latest">Version 3</a>: a modular rewrite that is much easier to maintain, debug, and implement;</li>
	<li>Version 2 (deprecated): first version with namespaces support;</li>
	<li>Version 1 (deprecated): original release.</li>
</ul>
<h3>Software</h3>
<ul>
	<li>I provide a free online implementation <a href="https://www.linguadata.nl">on my website</a>;</li>
	<li>I offer an <a href="https://www.linguadata.nl">off-line Java implementation</a> with user-friendly GUI and platform-independent CLI.</li>
</ul>
<h2>Features</h2>
<h3>Supported XSD Structures &amp; Datatypes</h3>
<ul>
	<li>Simple and complex elements, attributes, exclusions, restrictions, groups, etc. The full list of supported XSD tags is as follows: all, attribute, attributeGroup, choice, complexContent, complexType, element, extension, import, include, group, restriction, schema, sequence, simpleContent, simpleType, union (partially).</li>
	<li>minOccurs and maxOccurs, including vanilla JavaScript snippets that handle inserting and deleting elements.</li>
	<li>Default and fixed values, required and optional attributes.</li>
	<li>All restrictions that can be supported by HTML5: enumeration, length, maxExclusive, maxInclusive, maxLength, minExclusive, minInclusive, pattern, totalDigits, fractionDigits, and whiteSpace.</li>
	<li>Practically all data types that can be supported by HTML5: string, normalizedString, token, language, byte, decimal, int, integer, long, short (including their positive, negative, and unsigned variants), date, time, dateTime, month, gDay, gMonth, gYearMonth, gYear, gYearDay, hexBinary, base64Binary, anyURI, double, float, boolean. Note that all other data types are rendered as input[type=text] boxes, which still makes them editable in most cases.</li>
	<li>Namespaces: XSD files can reference other XSD's through include and import tags. Working with those is supported from version 2 onwards.</li>
	<li>Custom (multi-language) labels for elements, using the xs:annotation/xs:documentation tags directly following it.</li>
</ul>
<h3>Limitations on XSDs</h3>
<ul>
	<li><em>any</em> and <em>anyAttribute</em> are ignored.</li>
	<li>Mixed content (i.e. elements that can contain plain content and elements intermittently, designated by mixed="true") is not supported.</li>
	<li>Restrictions on <em>union</em> elements, because they can contain content originating from different base types.</li>
	<li>A type reference to another XSD must be accessible, or an element will not be generated. So, if you declare an element with a type in a different file,
	make sure there's an <em>import</em> or <em>include</em> tag that points to the corresponding XSD file. Multiple XSD references in a xsi:namespaceLocation attribute
	are not supported.</li>
	<li>Namespaces loaded from external documents must have a declared prefix in the original XSD.</li>
	<li><em>elementFormDefault</em> and <em>form</em> are ignored. All elements are supposed to be in the namespaces indicated by their hierarchical position in the
	document (i.e. <em>elementFormDefault="qualified"</em> is assumed). <em>attributeFormDefault</em> is supported.</li>
	<li>Recursivity in named types: if complexType A allows for an element of complexType B, which allows for an element of complexType A, an infinite loop is created.</li>
</ul>
<h2>Implementation</h2>
<p>Be sure to download the <a href="https://github.com/MichielCM/xsd2html2xml/releases/latest">latest release</a>; you need all files included in the ZIP, except for those inside /deprecated and /examples.</p>
<p>From there it's very straight-forward: transform your XSD or XML file with xsd2html2xml.xsl, and an HTML5 form is generated. You can pass either an XSD file to xsd2html2xml.xsl, or an XML file which references an XSD file through <em>xsi:schemaLocation</em> or <em>xsi:noNamespaceSchemaLocation</em>. In the latter case the content from the XML document is used to populate the generated form.</p>
<h3>XSLT Processor Support</h3>
<p>All XSLT processors listed below are (partially) supported. To load documents on the fly, an XSLT extension with a nodeset function is required. For the processors
listed below, nodeset-xxx.xsl files are provided. Be sure to include the correct nodeset-xxx.xsl file in xsd2html2xml.xsl depending on your implementation.</p>
<table>
	<tr>
		<th>XSLT Processor</th>
		<th>Nodeset File</th>
		<th>Support</th>
		<th>Comments</th>
	</tr>
	<tr>
		<td>libxslt (Webkit browsers)</td>
		<td>nodeset-exslt.xsl</td>
		<td>Partial: transformations must always be started from root XSD file, even when using an XML document referencing its schema.</td>
		<td>To populate forms in this scenario, add the XML file to the data-xsd2html2xml-source attribute of the meta[name='generator'] HTML element after the form has been generated.</td>
	</tr>
	<tr>
		<td>MSXML / MSXSL  (IE, Edge)</td>
		<td>nodeset-msxsl.xsl</td>
		<td>Full</td>
		<td></td>
	</tr>
	<tr>
		<td>XslCompiledTransform (.NET)</td>
		<td>nodeset-exslt.xsl</td>
		<td>Full</td>
		<td></td>
	</tr>
	<tr>
		<td>Saxon</td>
		<td>nodeset-xslt2plus.xsl</td>
		<td>Full</td>
		<td></td>
	</tr>
	<tr>
		<td>Transformiix (FireFox)</td>
		<td>nodeset-exslt.xsl</td>
		<td>Partial: namespaces are not supported.</td>
		<td>See <a href="https://bugzilla.mozilla.org/show_bug.cgi?id=94270">this FireFox bug</a>.</td>
	</tr>
	<tr>
		<td>Xalan</td>
		<td>nodeset-exslt.xsl</td>
		<td>Full</td>
		<td></td>
	</tr>
</table>
<h3>Configuration</h3>
<h4>config.xsl</h4>
<p>The config.xsl file contains some parameters that can be configured for your situation.</p>
<ul>
	<li>config-debug: determines the debug messages written during execution. Multiples values allowed:
		<ul>
			<li>INFO: information messages (through template 'inform');</li>
			<li>STACK: stack trace (through template 'log');</li>
			<li>ERROR: error messages (through template 'throw').</li>
		</ul>
	</li>
	<li>config-root: for XSD schemas that contain multiple root nodes, determines the number of the root node to be used. Defaults to 1;</li>
	<li>config-callback: contains the JavaScript function that is called when a user submits the form. It should accept a string argument containing the
	generated XML.</li>
	<li>config-title: contains the title given to the generated document.</li>
	<li>config-script: optionally contains the URL to a JavaScript reference, which will be referenced in the generated document.</li>
	<li>config-style: optionally contains the URL to a CSS reference, which will be referenced in the generated document.</li>
	<li>config-documentation: specifies whether element's annotation/documentation tags should be used for descriptions (works together with config-language).
	Defaults to false, i.e. uses element's @name or @ref (unprefixed) attributes as descriptions.</li>
	<li>config-language: optionally specifies which annotation/documentation language (determined by xml:lang) should be used for descriptions. Defaults to none.</li>
</ul>
<h4>XSD Schemas</h4>
<p>Most elements defined in XSDs will render fine without any configuration: [type=xs:int] will become input[type=number] elements, [type=xs:boolean] will become input[type=checkbox] elements etc. Note that some elements support configuration or have peculiar behavior, however:</p>
<ul>
	<li>xs:string: by default, this is rendered as an input[type=text] element. If you would like to support multiline and render a textarea instead, you have to specify allowance of line breaks specifically in the pattern by including '\n'. Note that the pattern can be anything, as long as it contains a '\n'. The simplest way to do this is by adding '(\n)?' after a pattern. A multiline pattern with no further restrictions could look like this: '.*(\n)?'.</li>
	<li>xs:duration: durations are rendered as input[type=range] elements, which look like sliders in most browser implementations. Durations have to follow a specific format according to W3C's specification. This format can be (partially) included in a pattern restriction. This pattern is used by xsd2html to determine the smallest unit that needs to be supported. For example, to use a duration that supports hours and minutes, add this pattern: 'PT\d{2}H\d{2}M'. The rendered range will be scaled in minutes (following the last M). To further restrict this duration to a maximum of 1 day, specify maxInclusive following W3C's notation in the smallest scale (i.e. minutes): 'PT1440M' (=60 minutes * 24). Note that in order to generate a valid value, the pattern of an xs:duration type must be specified explicitly.</li>
	<li>xs:hexBinary & xs:base64Binary: these types are rendered as input[type=file] elements. For security reasons, browsers do not allow these elements to have default values. That means that, if an input[type=file] element has a default, fixed, or populated value, this is not shown to the user. If such an element is required, it could never be submitted with the default value. To solve this, the required attribute of input[type=file] elements is added only after the user has changed the populated value.</li>
	<li>xs:enumeration: any type with this restriction will become a select element. It's possible to define additional restrictions on input, but usually this doesn't make much sense because the input is restricted to predetermined items.</li>
</ul>
<h2>Examples</h2>
<p>These examples demonstrate an HTML5 form generated from an XML schema. The resulting XML is then used to populate the form again as a last step.</p>
<p>The first example (complex-sample) demonstrates all supported data types. The second example (namespaces-sample) illustrates an XML schema importing two documents with another namespace, and including one with the same namespace.</p>
<table>
	<tr>
		<th>XML Schema (XSD)</th>
		<th>Generated HTML form</th>
		<th>Generated XML</th>
		<th>Filled-in HTML Form</th>
	</tr>
	<tr>
		<td>
			<a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/complex-sample/complex-sample.xsd">complex-sample.xsd</a>
		</td>
		<td>
			<a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/complex-sample/form.html">form.html</a>
		</td>
		<td>
			<a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/complex-sample/complex-sample.xml">complex-sample.xml</a>
		</td>
		<td>
			<a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/complex-sample/form-filled.html">form-filled.html</a>
		</td>
	</tr>
	<tr>
		<td>
			<a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/namespaces-sample.xsd">namespaces-sample.xsd</a> (<a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/import-doc1.xsd">import-doc1.xsd</a>, <a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/import-doc2.xsd">import-doc2.xsd</a>, <a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/double-import-doc.xsd">double-import-doc.xsd</a>, <a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/include-doc.xsd">include-doc.xsd</a>)</td>
		<td>
			<a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/form.html">form.html</a>
		</td>
		<td>
			<a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/namespaces-sample.xml">namespaces-sample.xml</a>
		</td>
		<td>
			<a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/form-filled.html">form-filled.html</a>
		</td>
	</tr>
</table>
<h2>Customization</h2>
<p>In case you want to add custom functionality to the generated form, I highly recommended you to do so using JavaScript and CSS, and not to directly alter the XSLT. This project frequently has new releases and updating is a hassle if you have custom functions built-in. Use the <em>config-script</em> and/or <em>config-style</em> parameters to generate HTML elements referring to external JavaScript or CSS files. See the information on config.xsl for more information.</p>
<p>To access data that is not automatically placed in the form, use <em>appinfo</em> elements in your XSD. Any data stored in such an <em>appinfo</em> element is converted into <em>data-appinfo-...</em> HTML attributes. For example:</p>
<pre><code>&lt;xs:element type=&quot;xs:string&quot; name=&quot;string&quot; default=&quot;singleline string&quot;&gt;
	&lt;xs:annotation&gt;
		&lt;xs:appinfo source=&quot;https://github.com/MichielCM/xsd2html2xml&quot;&gt;
			&lt;class&gt;element-with-extra-data&lt;/class&gt;
		&lt;/xs:appinfo&gt;
		&lt;xs:appinfo&gt;
			&lt;identifier&gt;abc123&lt;/identifier&gt;
		&lt;/xs:appinfo&gt;
	&lt;/xs:annotation&gt;
&lt;/xs:element&gt;</code></pre>
<p>Please note that <em>appinfo</em> elements with their <em>source</em> referring to <em>https://github.com/MichielCM/xsd2html2xml</em> are added to the HTML element directly, without a <em>data-appinfo-</em> prefix. The above code leads to the following generated HTML:</p>
<pre><code>&lt;label ... class=&quot;element-with-extra-data&quot; data-appinfo-identifier=&quot;abc123&quot;&gt;
	&lt;input ... &gt;
&lt;/label&gt;</code></pre>
<p>These attributes can be accessed through JavaScript or CSS and displayed or transformed at will:</p>
<pre><code>label.element-with-extra-data:after {
	content: attr(data-appinfo-identifier);
}
</code></pre>
<h2>Under the Hood</h2>
<p>The third version of XSD2HTML2XML works in a modular infrastructure, to make development, maintainenance and implementation easier. The main file, xsd2html2xml.xsl,
includes all other files in these directories:</p>
<ul>
	<li>matchers: these files form the starting point of parsing an XSD schema. Each element gets matched by one of the templates in these files, configured, and forwarded
	to one of the handlers for further rendering;</li>
	<li>handlers: these files take care of the actual rendering of HTML. All elements are treated either as complex elements or as simple elements. The remaining files deal with
	the specific input, textarea, or select elements configuration.</li>
	<li>utils: these files contain generic templates to handle namespace documents, string manipulation, type determination, etc.;</li>
	<li>css: these templates contain CSS stylesheets for styling the generated form;</li>
	<li>js: these templates contain JavaScript that handles the interactivity of the generated form:
		<ul>
			<li>event-handlers: these functions respond to button clicks relating to adding or removing form elements etc.;</li>
			<li>html-populators: these functions populate the form with XML content. An XML document should be specified by storing it in the data-xsd2html2xml-source attribute
			of the meta[name='generator'] element;</li>
			<li>initial calls: when the HTML finishes loading, these calls are executed;</li>
			<li>polyfills: contains polyfills for early browser support;</li>
			<li>value-fixers: contains functions to set values to HTML elements that differ from their XML counterparts. The XML-specific date format differs from the
			input[type=date] HTML elements, for example;</li>
			<li>xml-generators: these functions generate XML from a submitted form.</li>
		</ul>
	</li>
</ul>
<h3>forward &amp; forwardee</h3>
<p>In XSLT 1.0 processors, dyamically created XML structures (e.g. for documents loaded on the fly) need to be converted to nodesets before they can be used. Different processors
support different functions for this purpose. Rather than prescribe one implementation, I use specific nodeset-xxx.xsl files to handle to nodeset conversion. This means that any
template calling get-namespace-documents, for example, has to run its result through the forward template to be able to work with it as a nodeset. That is why some templates have
xxx-forwardee counterparts, which are called through the forward template. See <a href="https://stackoverflow.com/questions/5656129/xslt-call-template-with-dynamic-qname">this
thread</a> for details.</p>
<h2>FAQ</h2>
<ul>
	<li><strong>Why a version 3.x?</strong>
		<br />Version 3 does not bring a lot of new features over version 2, but it's a lot more efficient and future-proof. XSLT is not well-suited to creating projects of this scale, and having different files at least provides some sort of separation of concerns. The rudimentary stack trace really helps debugging and maintaining. Apart from that, there is now just one version to use in any scenario.</li>
	<li>
		<strong>How is version 3.x different?</strong>
		<br />For details, check the release notes for each release. In general (as opposed to version 2.x): included and imported documents are kept in memory whenever possible, and not loaded every time they are referenced; form population is done through JavaScript, removing the need for a [dyn:]evaluate XSLT function; support for all common XSLT 1-3 implementations (including browsers); support for XHTML and generating XML through XSLT has been removed.</li>
	<li>
		<strong>Are there any known bugs?</strong>
		<br />Please see the <a href="https://github.com/MichielCM/xsd2html2xml/issues">issue list</a>.
	<li>
		<strong>Will this work with any XML schema?</strong>
		<br />Yes, as long as you don't use the more esoteric elements of XSD, such as field or keygen. See the full list of supported tags above.</li>
	<li>
		<strong>Do I have to annotate my XML schema?</strong>
		<br />No, but you can to override the default labels. By default, the name attribute of elements is used for labels. If you want a custom label, add an xs:annotation/xs:documentation containing your custom label to the element.</li>
	<li>
		<strong>Which browsers are supported?</strong>
		<br />HTML5 support is steadily increasing with every browser release, so the more modern the browser, the better. However, generated forms have been confirmed to work in IE9, IE10, IE11, Edge, Chrome, Firefox, and Safari.</li>
	<li>
		<strong>But gDay and gMonth don't work in Edge!</strong>
		<br />They don't out of the box, because the format these types require (e.g. --03 for March) are not valid numbers and Edge refuses to set them as values. A workaround is to use an enumeration for these types, as shown in complex-sample (gMonthEnum).</li>
	<li>
		<strong>I can't edit xs:long values in Chrome!</strong>
		<br />The upper and lower bounds of long values are too high for Chrome to work with. Either use another browser or comment out the bounds in the set-type-specifics function for the xs:long type.</li>
	<li>
		<strong>What's the easiest way to test this?</strong>
		<br />Please see <a href="https://xsd2html2xml.linguadata.nl">my website</a> for a free online implementation or an offline Java application.</li>
</ul>
