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
