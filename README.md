<h1>XSD2Form (pre-release)</h1>
<p>Generates plain HTML5 forms from XSD schema's. Extracts XML from filled-in forms.</p>
<p>XSD schema's contain a wealth of information about how a user interface should be presented and what data should be allowed. HTML5 supports many new input types and attributes that are compatible with XSD schema's. XSD2Form automates the process of generating forms from XSD schema's and extracting valid XML from them as users fill them in. This makes user-generated entering of well-formed, valid XML input easier than ever before.</p>
<p>In a nutshell:</p>
<ul>
  <li>Generates a plain HTML5 form from any XSD schema.</li>
  <li>Extracts XML from filled-in forms that are valid to the XSD</li>
  <li>Written in fast and widely supported XSLT 1.0</li>
  <li>No dependencies</li>
  <li>Pure HTML5 forms with (very little) vanilla JavaScript for its interactive parts</li>
  <li>Easily stylable with CSS, or extendable with any library or framework</li>
</ul>
<p>Supported XSD features:</p>
<ul>
  <li>Simple and complex elements, attributes, exclusions, restrictions, groups, etc. The full list of supported XSD tags is as follows: all, attribute, attributeGroup, choice, complexContent, complexType, element, extension, group, restriction, schema, sequence, simpleContent, simpleType, union (partially).</li>
  <li>minOccurs and maxOccurs, including tiny vanilla JavaScript chunks that handle inserting and deleting elements.</li>
  <li>Default and fixed values, required and optional attributes.</li>
  <li>All restrictions that can be supported by HTML5: enumeration, fractionDigits, length, maxExclusive, maxInclusive, maxLength, minExclusive, minInclusive, pattern, totalDigits (?), whiteSpace (?).</li>
  <li>All common data types that can be supported by HTML5: string, token, byte, decimal, int, integer, long, short (including their positive, negative, and unsigned variants), date, time, dateTime, anyURI, double, float, boolean.</li>
</ul>
<p>Unsupported XSD features:</p>
<ul>
  <li>any and anyAttribute, for obvious reasons.</li>
  <li>Mixed data, because an HTML5 form does not allow input elements within input elements. The XSD mixed attribute is ignored and only the specified elements can be entered.</li>
  <li>Restrictions on union, because union elements can encompass multiple base types, which would require multiple input elements. Union elements are rendered as textboxes without restrictions.</li>
</ul>
