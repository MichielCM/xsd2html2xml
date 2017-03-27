<h1>XSD2HTML2XML (pre-release)</h1>
<p>Generates plain HTML5 forms from XML schemas (XSDs). Transforms filled-in forms into XML.</p>
<p>XML schemas contain a wealth of information about what data is allowed in an XML structure, and thus how a user interface should be presented. HTML5 supports many new input types and attributes that are compatible with XML schemas. XSD2HTML2XML automates the process of generating forms from XML schemas and extracting valid XML from them after users fill them out. This makes user-generated entering of well-formed, valid XML input easier than ever before.</p>
<p>In a nutshell:</p>
<ul>
  <li>Generates a plain HTML5 form from any XML schema (XSD);</li>
  <li>Extracts XML from filled-out forms; either through JavaScript or XSLT;</li>
  <li>Supports populating the generated form with data from an XML document;</li>
  <li>Written in fast and widely supported XSLT 1.0;</li>
  <li>Has no dependencies (except for XSLT 1.0 and - for population of the form - EXSLT extensions);</li>
  <li>Generates pure HTML5 forms with (very little) vanilla JavaScript for interactive parts;</li>
  <li>Is easily stylable with CSS, or extendable with any library or framework;</li>
  <li>Is free for any purpose.</li>
</ul>
<p>Supported XSD features:</p>
<ul>
  <li>Simple and complex elements, attributes, exclusions, restrictions, groups, etc. The full list of supported XSD tags is as follows: all, attribute, attributeGroup, choice, complexContent, complexType, element, extension, group, restriction, schema, sequence, simpleContent, simpleType, union (partially).</li>
  <li>minOccurs and maxOccurs, including tiny vanilla JavaScript snippets that handle inserting and deleting elements.</li>
  <li>Default and fixed values, required and optional attributes.</li>
  <li>All restrictions that can be supported by HTML5: enumeration, length, maxExclusive, maxInclusive, maxLength, minExclusive, minInclusive, pattern, totalDigits, fractionDigits.</li>
  <li>All common data types that can be supported by HTML5: string, token, byte, decimal, int, integer, long, short (including their positive, negative, and unsigned variants), date, time, dateTime, anyURI, double, float, boolean.</li>
</ul>
<p>Unsupported XSD features:</p>
<ul>
  <li>any and anyAttribute, for obvious reasons.</li>
  <li>Mixed content (i.e. elements that can contain plain content and elements intermittently) can-not be represented in an HTML5 interface with predetermined controls.</li>
  <li>Restrictions on union elements were omitted, because they can contain content originating from different base types.</li>
  <li>Components that do not specify content guide-lines were ignored, such as any, anyAttribute, documentation, or appinfo.</li>
  <li>Import and include components that compile documents out of multiple sources are not directly supported, because their implementation is application-dependent. The conjoined doc-ument can be transformed with our algorithms.</li>
</ul>
<h2>How to use</h2>
<p>It's really quite simple: pick your XSD file, transform it with either xsd2html.xsl or with xsd+xml2html.xsl, and voila: a generated HTML5 form.</p>
<p>Here's more detail: using xsd2html2xml.xsl is the easiest way to go. It's a shortcut file containing only the variables needed for configuration. If you want, you can also use xsd+xml2html.xsl or xsd2html.xsl directly.</p>
<p>The configuration is as follows:</p>
<ul>
  <li>Import xsd+xml2html.xsl if you want to populate the generated form with data, or xsd2html.xsl if you want it empty.</li>
  <li>xml-doc: this variable should point to the XML data file, if you selected xsd+xml2html.xsl. Otherwise, it is ignored.</li>
  <li>config-xml-generator: this variable should be either 'xslt' or 'js'. The XML generated from the form can be extracted through JavaScript (via a built-in script) or a separate XSL transformation, using html2xml.xsl. Default is 'js' (JavaScript).</li>
  <li>output-method: if you selected 'xslt' as config-xml-generator, the output method should be XHTML. Otherwise closing tags will be omitted, resulting in invalid XML that cannot be processed by an XSLT parser. Note that XHTML is unforgiving, and that the form should be included in documents with a valid doctype, served as application/xhtml+xml. Default is 'html'. Note that you should edit both the output-method variable and the xsl:output tag.</li>
  <li>config-js-callback: this JavaScript fuction is called when the form is submitted (onsubmit). It should point to a function expecting a single string parameter. If config-xml-generator is 'js' this parameter will contain the resulting XML, if it is 'config-xml-generator' the parameter will contain the form's outerHTML, which can be processed by html2xml.xsl. Default is 'console.log', writing the resulting XML to the console.</li>
  <li>config-add-button-label, config-remove-button-label, config-submit-button-label: The values of these variables are used for the labels of add, remove, or submit buttons. Defaults are +, -, and OK.</li>
</ul>
<h2>Examples</h2>
<h2>FAQ</h2>
<ul>
<li><strong>Will this work with any XML schema?</strong><br />Yes, as long as you don't use the more esoteric elements of XSD, such as field or keygen. See the full list of supported tags above.</li>
<li><strong>Do I have to annotate my XML schema?</strong><br />No, but you can to override the default labels. By default, the name attribute of elements is used for labels. If you want a custom label, add an xs:annotation/xs:documentation containing your custom label to the element.</li>
</ul>
