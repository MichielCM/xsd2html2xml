<h1>XSD2HTML2XML</h1>
<p>Generates plain HTML5 forms from XML schemas (XSDs). Transforms filled-in forms into XML.</p>
<p>XML schemas contain a wealth of information about what data is allowed in an XML structure, and thus how a user interface should be presented. HTML5 supports many new input types and attributes that are compatible with XML schemas. XSD2HTML2XML automates the process of generating forms from XML schemas and extracting valid XML from them after users fill them out. This makes user-generated entering of well-formed, valid XML input easier than ever before.</p>
<p>In a nutshell:</p>
<ul>
	<li>Generates a plain HTML5 form from any XML schema (XSD);</li>
	<li>Extracts XML from filled-out forms, either through JavaScript or XSLT;</li>
	<li>Supports populating the generated form with data from an XML document;</li>
	<li>Supports namespaces (including combining schemas through xs:include and xs:import tags);</li>
	<li>Written in fast and widely supported XSLT 1.0;</li>
	<li>Has no dependencies (except for some EXSLT extensions for population of the form and namespace support);</li>
	<li>Generates pure HTML5 forms with (little) vanilla JavaScript for interactive parts;</li>
	<li>Is easily stylable with CSS, or extendable with any library or framework;</li>
	<li>Is free for any purpose.</li>
</ul>
<h2>Versions</h2>
<h3>Source Code</h3>
<p>I strongly recommend using only <strong>released</strong> versions. Newer commits may contain new, experimental, features, but have not been thoroughly tested to perform well in a production environment.</p>
<ul>
	<li>February 19, 2018: <a href="https://github.com/MichielCM/xsd2html2xml/releases/tag/v2.6">Release 2.6: Namespace support, optimized (polyfilled) JavaScript, improved support for extensions</a></li>
	<li>April 20, 2017: <a href="https://github.com/MichielCM/xsd2html2xml/releases/tag/v1.0">Release 1.0 (deprecated): Original release</a>
	</li>
</ul>
<h3>Software</h3>
<p>If you are looking for out-of-the-box software that pre-configures the XSL/XSD/XML files, check out these options:</p>
<ul>
	<li><a href="http://www.michielmeulendijk.nl/xml-schema-form-generator/">XML Schema Form Generator</a>: full-fledged Java implementation of xsd+xml2html.xsl:
		<ul>
			<li>Complete with GUI, command line interface, and Chrome extension;</li>
			<li>Preconfigured for any XSD (including schemas not bound to xs:...);</li>
			<li>Supports includes / imports from multi-file schemas (both local and online files);</li>
			<li>GUI supports autocompletion, spellcheck, placeholder text, and custom styling and scripting;</li>
			<li>Works for Windows (32-/64-bit). Stand-alone JAR available on request.</li>
		</ul></li>
	<li><a href="https://chrome.google.com/webstore/detail/xml-schema-form-generator/bampmcipgicplmddohedjmenepjmdpoj">Google Chrome extension</a>: a JavaScript implementation of xsd2html.xsl. Limited to generating empty forms without namespaces, but highly suitable for a sneak peek.</li>
</ul>
<h2>Features</h2>
<h3>Supported XSD Structures &amp; Datatypes</h3>
<ul>
	<li>Simple and complex elements, attributes, exclusions, restrictions, groups, etc. The full list of supported XSD tags is as follows: all, attribute, attributeGroup, choice, complexContent, complexType, element, extension, import, include, group, restriction, schema, sequence, simpleContent, simpleType, union (partially).</li>
	<li>minOccurs and maxOccurs, including tiny vanilla JavaScript snippets that handle inserting and deleting elements.</li>
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
	<li>References to other documents can be absolute or relative, but in the latter case must always be relative to the original XSD.</li>
	<li>Namespaces loaded from external documents must have a declared prefix in the original XSD.</li>
	<li>Unprefixed XSD files (with a namespace xmlns="http://www.w3.org/2001/XMLSchema" or without a namespace at all) may yield unstable results.</li>
	<li><em>elementFormDefault</em> and <em>form</em> are ignored. All elements are supposed to be in the namespaces indicated by their hierarchical position in the
	document (i.e. <em>elementFormDefault="qualified"</em> is assumed). <em>attributeFormDefault</em> is supported.</li>
			</ul>
<h2>Implementing XSD2HTML2XML</h2>
<p>At heart it's really simple: pick your XSD file, transform it with either xsd2html.xsl or with xsd+xml2html.xsl, and voila: a generated HTML5 form.</p>
<p>Here's more detail: using xsd2html2xml.xsl is the easiest way to go. It's a shortcut file containing only the variables needed for configuration (see below for more info). If you want, you can also use xsd+xml2html.xsl or xsd2html.xsl directly.</p>
<p>A list of XSLT processors that have been tested to work include <a href="https://xalan.apache.org/">Xalan</a>, <a href="https://github.com/GNOME/libxslt">libxslt</a>, and <a href="https://www.saxonica.com/products/feature-matrix-9-8.xml">Saxon</a>.
<h3>Configuring XSLs<h3>
<p>The XSL files allow for the following configuration options:</p>
<ul>
	<li>Import xsd+xml2html.xsl if you want to populate the generated form with data, or xsd2html.xsl if you want it empty. Note: if you want to use namespaces, you must use xsd+xml2html.xsl, even if you want the form empty!</li>
	<li>xml-doc: this variable should point to the XML data file, if you selected xsd+xml2html.xsl. Otherwise, it is ignored.</li>
	<li>config-xml-generator: this variable should be either 'xslt' or 'js'. The XML generated from the form can be extracted through JavaScript (via a built-in script) or a separate XSL transformation, using html2xml.xsl. Default is 'js' (JavaScript).</li>
	<li>output-method: if you selected 'xslt' as config-xml-generator, the output method should be XHTML. Otherwise closing tags will be omitted, resulting in invalid XML that cannot be processed by an XSLT parser. Note that XHTML is unforgiving, and that the form should be included in documents with a valid doctype, served as application/xhtml+xml. Default is 'html'. (Version 1 only: note that you should edit both the output-method variable and the xsl:output tag.)</li>
	<li>config-js-callback: this JavaScript function is called when the form is submitted (onsubmit). It should point to a function expecting a single string parameter. If config-xml-generator is 'js' this parameter will contain the resulting XML, if it is 'config-xml-generator' the parameter will contain the form's outerHTML, which can be processed by html2xml.xsl. Default is 'console.log', writing the resulting XML to the console.</li>
	<li>config-language: if you use annotation/documentation tags for labeling elements, you can optionally specify their language with the xml:lang attribute. To specify which language should be used by XSD2HTML, make sure this variable matches the xml:lang attribute's. For example, to use &lt;xs:documentation xml:lang='en'&gt;hello&lt;xs:documentation&gt;, also pass 'en' to this variable. Note that if no matching documentation tag is found, XSD2HTML will use any documentation element not specifying a language, or else resort to @name. Default is empty.</li>
	<li>config-add-button-label, config-remove-button-label, config-submit-button-label, config-seconds|minutes|hours|days|months|years.: The values of these variables are used for the labels of add, remove, submit buttons, and time intervals for xs:duration. Defaults are '+', '-', 'OK', and the English time intervals.</li>
</ul>
<h3>Configuring XSDs</h3>
<p>Input elements are assigned based on an element's primitive type. Most types work just like you would expect (e.g. int becomes number, boolean becomes checkbox, date becomes date). Some have additional options or peculiarities:</p>
<ul>
	<li>xs:string: by default, this is rendered as an input[type=text] element. If you would like to support multiline and render a textarea instead, you have to specify allowance of line breaks specifically in the pattern by including '\n'. Note that the pattern can be anything, as long as it contains a '\n'. The simplest way to do this is by adding '(\n)?' after a pattern. A multiline pattern with no further restrictions could look like this: '.*(\n)?'.</li>
	<li>xs:duration: durations are rendered as input[type=range] elements, which look like sliders in most browser implementations. Durations have to follow a specific format according to W3C's specification. This format can be (partially) included in a pattern restriction. This pattern is used by xsd2html to determine the smallest unit that needs to be supported. For example, to use a duration that supports hours and minutes, add this pattern: 'PT\d{2}H\d{2}M'. The rendered range will be scaled in minutes (following the last M). To further restrict this duration to a maximum of 1 day, specify maxInclusive following W3C's notation in the smallest scale (i.e. minutes): 'PT1440M' (=60 minutes * 24). Note that in order to generate a valid value, the pattern of an xs:duration type must be specified explicitly.</li>
	<li>xs:hexBinary & xs:base64Binary: these types are rendered as input[type=file] elements. For security reasons, browsers do not allow these elements to have default values. That means that, if an input[type=file] element has a default, fixed, or populated value, this is not shown to the user. If such an element is required, it could never be submitted with the default value. To solve this, the required attribute of input[type=file] elements is added only after the user has changed the populated value.</li>
	<li>xs:enumeration: any type with this restriction will become a select element. It's possible to define additional restrictions on input, but usually this doesn't make much sense because the input is restricted to predetermined items.</li>
</ul>
<h3>Using Namespaces</h3>
<p>If you want to use namespaces, please keep in mind the following requirements:</p>
<ul>
	<li>Use xsd+xml2html.xsl, even if you want to generate an empty form!</li>
	<li>A type reference to another XSD must be accessible, or an element will not be generated. So, if you declare an element with a type in a different file, make sure there's an import or include tag that points to the corresponding XSD file.</li>
	<li>Recursivity in XSD files is supported; imported XSD files can include other XSD files.</li>
	<li>I highly recommend using a caching system for loading external documents. Since XSLT 1.0 does not support array-like data structures, documents cannot be stored in variables for future reference. So each external XSD is loaded every time it is referenced by an element!</li>
</ul>
<h2>Examples</h2>
<p>These examples demonstrate a form generated from an XML schema, both as HTML and XHTML. The resulting XML is then used to populate the form again as a last step.</p>
<p>The first example (complex-sample) demonstrates all supported data types. The second example (namespaces-sample) illustrates an XML schema importing two documents with another namespace, and including one with the same namespace.</p>
<table>
	<tr>
		<th>XML Schema (XSD)</th>
		<th>Generated HTML form</th>
		<th>Generated XML</th>
		<th>Filled-in HTML Form</th>
	</tr>
	<tr>
		<td rowspan="2">
			<a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/complex-sample/complex-sample.xsd">complex-sample.xsd</a>
		</td>
		<td>
			<a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/complex-sample/form.html">form.html</a>
		</td>
		<td rowspan="2">
			<a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/complex-sample/complex-sample.xml">complex-sample.xml</a>
		</td>
		<td>
			<a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/complex-sample/form-filled.html">form-filled.html</a>
		</td>
	</tr>
	<tr>
		<td>
			<a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/complex-sample/form.xhtml">form.xhtml</a>
		</td>
		<td>
			<a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/complex-sample/form-filled.xhtml">form-filled.xhtml</a>
		</td>
	</tr>
	<tr>
		<td rowspan="2">
			<a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/namespaces-sample.xsd">namespaces-sample.xsd</a> (<a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/import-doc1.xsd">import-doc1.xsd</a>, <a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/import-doc2.xsd">import-doc2.xsd</a>, <a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/double-import-doc.xsd">double-import-doc.xsd</a>, <a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/include-doc.xsd">include-doc.xsd</a>)</td>
		<td>
			<a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/form.html">form.html</a>
		</td>
		<td rowspan="2">
			<a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/namespaces-sample.xml">namespaces-sample.xml</a>
		</td>
		<td>
			<a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/form-filled.html">form-filled.html</a>
		</td>
	</tr>
	<tr>
		<td>
			<a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/form.xhtml">form.xhtml</a>
		</td>
		<td>
			<a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/form-filled.xhtml">form-filled.xhtml</a>
		</td>
	</tr>
</table>
<h2>FAQ</h2>
<ul>
	<li>
		<strong>Will this work with any XML schema?</strong>
		<br />Yes, as long as you don't use the more esoteric elements of XSD, such as field or keygen. See the full list of supported tags above.</li>
	<li>
		<strong>Do I have to annotate my XML schema?</strong>
		<br />No, but you can to override the default labels. By default, the name attribute of elements is used for labels. If you want a custom label, add an xs:annotation/xs:documentation containing your custom label to the element.</li>
	<li>
		<strong>Which namespaces can I use?</strong>
		<br />Any, except for any namespace having 'xs' as prefix. In fact, the XSD schema MUST be bound to the prefix 'xs', like so: xmlns:xs="http://www.w3.org/2001/XMLSchema". Note that the products listed under <em>Software</em> auto-configure this.</li>
	<li>
		<strong>My namespaces do not seem to work!</strong>
		<br />- Please note that namespaces are only supported in xsd+xml2html.xsl, even for empty forms! The reason for this is that namespace support requires the same EXSLT-functions as populating a form does, and I want to keep xsd2html.xsl the compact, no-dependency version.<br />
- Note that if you use namespaces to reference types, you MUST use an xs:import tag with the location of the XSD file. If the application cannot find a type declaration, an element won't be rendered in a form.</li>
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
		<br />If you want to get a quick glimpse of what the code is capable of, try installing the <a href="https://chrome.google.com/webstore/detail/xml-schema-form-generator/bampmcipgicplmddohedjmenepjmdpoj">Google Chrome extension</a>. If you want to get your hands dirty, build your own implementation with an XSLT processor; processors that support EXSLT include <a href="https://xalan.apache.org/">Xalan</a>, <a href="https://github.com/GNOME/libxslt">libxslt</a>, and <a href="https://www.saxonica.com/products/feature-matrix-9-8.xml">Saxon</a>. If you want supported software that just works out of the box, install the <a href="http://www.michielmeulendijk.nl/xml-schema-form-generator/">XML Schema Form Generator</a> trial.</li>
	<li>
		<strong>I don't want to write my own implementation! Is there out-of-the-box software available?</strong>
		<br />Yes, there is! Check out the free <a href="https://chrome.google.com/webstore/detail/xml-schema-form-generator/bampmcipgicplmddohedjmenepjmdpoj">Google Chrome extension</a> or the full <a href="http://www.michielmeulendijk.nl/xml-schema-form-generator/">Windows application</a>. The latter comes with a developer-friendly command line interface for integration in other software.</li>
</ul>
