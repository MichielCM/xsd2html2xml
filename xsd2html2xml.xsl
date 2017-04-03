<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- choose either xsd+xml2html.xsl if you want to populate your form,
	or xsd2html.xsl if you do not. The latter option does not require EXSLT plug-ins. -->
	<xsl:import href="xsd+xml2html.xsl" />
	<!-- <xsl:import href="xsd2html.xsl" /> -->
	
	<!-- set method as either html or xhtml. Note: if you want to process the results
	with html2xml.xsl, you need to use xhtml. Note 2: browsers won't display the form correctly if
	it does not contain a valid XHTML doctype and if it is not served with content type application/xhtml+xml -->
	<!-- <xsl:output method="xhtml" omit-xml-declaration="no" indent="no" /> -->
	<xsl:output method="xhtml" omit-xml-declaration="yes" indent="no" />
	<xsl:variable name="output-method">xhtml</xsl:variable>
	
	<!-- optionally specify the xml document to populate the form with -->
	<xsl:variable name="xml-doc">
		<xsl:copy-of select="document('complex-sample.xml')/*"/>
	</xsl:variable>
	
	<!-- choose the JavaScript (js) or XSLT (xslt) option for processing the form results -->
	<!-- <xsl:variable name="config-to-xml">xslt</xsl:variable> -->
	<xsl:variable name="config-xml-generator">js</xsl:variable>
	
	<!-- choose a JavaScript function to be called when the form is submitted.
	it should accept a string argument containing the xml or html -->
	<xsl:variable name="config-js-callback">console.log</xsl:variable>
	
	<!-- optionally specify a css stylesheet to use for the form.
	it will be inserted as a link tag inside the form element. -->
	<xsl:variable name="config-css">style.css</xsl:variable>
	
	<!-- optionally specify whether you want the span element before or after the input / select element within the label tag -->
	<!-- entering 'true' enables you to use the CSS next-sibling selector '+' to style the span based on the input's attributes -->
	<!-- use 'float: left' or something similar on the span to still make it appear before the input element -->
	<xsl:variable name="config-label-after-input">true</xsl:variable>
	
	<!-- optionally specify text for interactive elements -->
	<xsl:variable name="config-add-button-label">New</xsl:variable>
	<xsl:variable name="config-remove-button-label">Remove</xsl:variable>
	<xsl:variable name="config-submit-button-label">Submit</xsl:variable>
</xsl:stylesheet>