<h1>XSD2HTML2XML</h1>
<p>Generates plain HTML5 forms from XML schemas (XSDs). Transforms filled-in forms into XML.</p>
<p>XML schemas contain a wealth of information about what data is allowed in an XML structure, and thus how a user interface should be presented. HTML5 supports many new input types and attributes that are compatible with XML schemas. XSD2HTML2XML automates the process of generating forms from XML schemas and extracting valid XML from them after users fill them out. This makes user-generated entering of well-formed, valid XML input easier than ever before.</p>
<p>In a nutshell:</p>
<ul>
  <li>Generates a plain HTML5 form from any XML schema (XSD);</li>
  <li>Extracts XML from filled-out forms; either through JavaScript or XSLT;</li>
  <li>Supports populating the generated form with data from an XML document;</li>
  <li>Supports namespaces;</li>
  <li>Written in fast and widely supported XSLT 1.0;</li>
  <li>Has no dependencies (except for XSLT 1.0 and - for population of the form - EXSLT extensions);</li>
  <li>Generates pure HTML5 forms with (very little) vanilla JavaScript for interactive parts;</li>
  <li>Is easily stylable with CSS, or extendable with any library or framework;</li>
  <li>Is free for any purpose.</li>
</ul>
<h2>Versions</h2>
<p>I strongly recommend using only <strong>released</strong> versions. Newer commits may contain new, experimental, features, but have not been thoroughly tested to perform well in a production environment.
<ul>
  <li>April 20, 2017: <a href="https://github.com/MichielCM/xsd2html2xml/releases/tag/v1.0">1.0: First release of XSD2HTML2XML.</a></li>
</ul>
<h2>Features</h2>
<p>Supported XSD features:</p>
<ul>
  <li>Simple and complex elements, attributes, exclusions, restrictions, groups, etc. The full list of supported XSD tags is as follows: all, attribute, attributeGroup, choice, complexContent, complexType, element, extension, import, include, group, restriction, schema, sequence, simpleContent, simpleType, union (partially).</li>
  <li>minOccurs and maxOccurs, including tiny vanilla JavaScript snippets that handle inserting and deleting elements.</li>
  <li>Default and fixed values, required and optional attributes.</li>
  <li>All restrictions that can be supported by HTML5: enumeration, length, maxExclusive, maxInclusive, maxLength, minExclusive, minInclusive, pattern, totalDigits, fractionDigits, and whiteSpace.</li>
  <li>Practically all data types that can be supported by HTML5: string, normalizedString, token, language, byte, decimal, int, integer, long, short (including their positive, negative, and unsigned variants), date, time, dateTime, month, gDay, gMonth, gYearMonth, gYear, gYearDay, base64Binary, anyURI, double, float, boolean. Note that all other data types are rendered as input[type=text] boxes, which still makes them editable in most cases.</li>
  <li>Namespaces: XSD files can reference other XSD's through include and import tags. Working with those is supported from version 2 onwards.
  <li>Custom labels for elements, using the xs:annotation/xs:documentation tags directly following it.</li>
</ul>
<p>Unsupported XSD features:</p>
<ul>
  <li>any and anyAttribute, for obvious reasons.</li>
  <li>Mixed content (i.e. elements that can contain plain content and elements intermittently) can-not be represented in an HTML5 interface with predetermined controls.</li>
  <li>Restrictions on union elements were omitted, because they can contain content originating from different base types.</li>
  <li>Components that do not specify content guidelines were ignored, such as any, anyAttribute, documentation, or appinfo.</li>
</ul>
<h2>How to use</h2>
<p>It's really quite simple: pick your XSD file, transform it with either xsd2html.xsl or with xsd+xml2html.xsl, and voila: a generated HTML5 form.</p>
<p>Here's more detail: using xsd2html2xml.xsl is the easiest way to go. It's a shortcut file containing only the variables needed for configuration. If you want, you can also use xsd+xml2html.xsl or xsd2html.xsl directly.</p>
<p>The configuration is as follows:</p>
<ul>
  <li>Import xsd+xml2html.xsl if you want to populate the generated form with data, or xsd2html.xsl if you want it empty. Note: if you want to use namespaces, you must use xsd+xml2html.xsl, even if you want the form empty!</li>
  <li>xml-doc: this variable should point to the XML data file, if you selected xsd+xml2html.xsl. Otherwise, it is ignored.</li>
  <li>config-xml-generator: this variable should be either 'xslt' or 'js'. The XML generated from the form can be extracted through JavaScript (via a built-in script) or a separate XSL transformation, using html2xml.xsl. Default is 'js' (JavaScript).</li>
  <li>output-method: if you selected 'xslt' as config-xml-generator, the output method should be XHTML. Otherwise closing tags will be omitted, resulting in invalid XML that cannot be processed by an XSLT parser. Note that XHTML is unforgiving, and that the form should be included in documents with a valid doctype, served as application/xhtml+xml. Default is 'html'. Note that you should edit both the output-method variable and the xsl:output tag.</li>
  <li>config-js-callback: this JavaScript fuction is called when the form is submitted (onsubmit). It should point to a function expecting a single string parameter. If config-xml-generator is 'js' this parameter will contain the resulting XML, if it is 'config-xml-generator' the parameter will contain the form's outerHTML, which can be processed by html2xml.xsl. Default is 'console.log', writing the resulting XML to the console.</li>
  <li>config-language: if you use annotation/documentation tags for labeling elements, you can optionally specify their language with the xml:lang attribute. To specify which language should be used by XSD2HTML, make sure this variable matches the xml:lang attribute's. For example, to use &lt;xs:documentation xml:lang='en'&gt;hello&lt;xs:documentation&gt;, also pass 'en' to this variable. Note that if no matching documentation tag is found, XSD2HTML will use any documentation element not specifying a language, or else resort to @name. Default is empty.</li>
  <li>config-add-button-label, config-remove-button-label, config-submit-button-label, config-seconds|minutes|hours|days|months|years.: The values of these variables are used for the labels of add, remove, submit buttons, and time intervals for xs:duration. Defaults are '+', '-', 'OK', and the English time intervals.</li>
</ul>
<h2>How it works</h2>
<p>Input elements are assigned based on an element's primitive type. Most types work just like you would expect (e.g. int becomes number, boolean becomes checkbox, date becomes date). Some have additional options or peculiarities:</p>
<ul>
  <li>xs:string: by default, this is rendered as an input[type=text] element. If you would like to support multiline and render a textarea instead, you have to specify allowance of line breaks specifically in the pattern by including '\n'. Note that the pattern can be anything, as long as it contains a '\n'. The simplest way to do this is by adding '(\n)?' after a pattern. A multiline pattern with no further restrictions could look like this: '.*(\n)?'.</li>
  <li>xs:duration: durations are rendered as input[type=range] elements, which look like sliders in most browser implementations. Durations have to follow a specific format according to W3C's specification. This format can be (partially) included in a pattern restriction. This pattern is used by xsd2html to determine the smallest unit that needs to be supported. For example, to use a duration that supports hours and minutes, add this pattern: 'PT\d{2}H\d{2}M'. The rendered range will be scaled in minutes (following the last M). To further restrict this duration to a maximum of 1 day, specify maxInclusive following W3C's notation in the smallest scale (i.e. minutes): 'PT1440M' (=60 minutes * 24). Note that in order to generate a valid value, the pattern of an xs:duration type must be specified explicitly.</li>
  <li>xs:base64Binary: these types are rendered as input[type=file] elements. For security reasons, browsers do not allow these elements to have default values. That means that, if an input[type=file] element has a default, fixed, or populated value, this is not shown to the user. If such an element is required, it could never be submitted with the default value. To solve this, the required attribute of input[type=file] elements is added only after the user has changed the populated value.</li>
  <li>xs:enumeration: any type with this restriction will become a select element. It's possible to define additional restrictions on input, but usually this doesn't make much sense because the input is restricted to predetermined items.</li>
</ul>
<h2>Examples</h2>
<p>This example demonstrates a form generated from an XML schema, both as HTML and XHTML. The resulting XML is then used to populate the form again as a last step.</p>
<table>
  <tr>
    <th>XML Schema (XSD)</th>
    <th>Generated HTML form</th>
    <th>Generated XML</th>
    <th>Filled-in HTML Form</th>
  </tr>
  <tr>
    <td rowspan="2"><a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/complex-sample/complex-sample.xsd">complex-sample.xsd</a></td>
    <td><a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/complex-sample/form.html">form.html</a></td>
    <td rowspan="2"><a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/complex-sample/complex-sample.xml">complex-sample.xml</a></td>
    <td><a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/complex-sample/form-filled.html">form-filled.html</a></td>
  </tr>
  <tr>
    <td><a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/complex-sample/form.xhtml">form.xhtml</a></td>
    <td><a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/complex-sample/form-filled.xhtml">form-filled.xhtml*</a></td>
  </tr>
  <tr>
    <td rowspan="2"><a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/namespaces-sample.xsd">namespaces-sample.xsd</a> (<a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/import-doc1.xsd">import-doc1.xsd</a>, <a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/import-doc2.xsd">import-doc2.xsd</a>, <a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/include-doc.xsd">include-doc.xsd</a>)</td>
    <td><a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/form.html">form.html</a></td>
    <td rowspan="2"><a href="https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/namespaces-sample.xml">namespaces-sample.xml</a></td>
    <td><a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/form-filled.html">form-filled.html</a></td>
  </tr>
  <tr>
    <td><a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/form.xhtml">form.xhtml</a></td>
    <td><a href="https://htmlpreview.github.io/?https://github.com/MichielCM/xsd2html2xml/blob/master/examples/namespaces-sample/form-filled.xhtml">form-filled.xhtml</a></td>
  </tr>
</table>
<p>*Please note that this example is not populated exactly right, because Github does not serve the XHTML with the correct mimetype.</p> 
<h2>FAQ</h2>
<ul>
<li><strong>Will this work with any XML schema?</strong><br />Yes, as long as you don't use the more esoteric elements of XSD, such as field or keygen. See the full list of supported tags above.</li>
<li><strong>Do I have to annotate my XML schema?</strong><br />No, but you can to override the default labels. By default, the name attribute of elements is used for labels. If you want a custom label, add an xs:annotation/xs:documentation containing your custom label to the element.</li>
<li><strong>My namespaces do not seem to work!</strong><br />Please note that namespaces are only supported in xsd+xml2html.xsl, even for empty forms! The reason for this is that namespace support requires the same EXSLT-functions as populating a form does, and I want to keep xsd2html.xsl the compact, no-dependency version.</li>
</ul>
