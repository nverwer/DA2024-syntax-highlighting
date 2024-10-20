<?xml version="1.0" ?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
>

  <xsl:mode on-no-match="shallow-copy"/>


  <!--
    The named-content element contains mixed content.
    This was hidden from the parser by storing it (serialized) in the @content attribute.
    Here it is put back.
  -->
  <xsl:template match="named-content">
    <xsl:copy>
      <xsl:sequence select="@* except @content"/>
      <xsl:sequence select="parse-xml-fragment(string(@content))"/>
    </xsl:copy>
  </xsl:template>


<!--
    The top-level element of the parser code is wrapper around the <code> element.
    We move it the <code> element back up.
-->
  <xsl:template match="*[descendant::code[@language = 'r']]">
  <xsl:variable name="code-element" select="descendant::code[@language = 'r']"/>
    <code>
      <xsl:sequence select="$code-element/@*"/>
      <xsl:copy>
        <xsl:sequence select="@*"/>
        <xsl:apply-templates select="node()"/>
      </xsl:copy>
    </code>
  </xsl:template>

  <xsl:template match="/code">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*/code">
    <xsl:apply-templates select="node()"/>
  </xsl:template>
  

  <!--
    The expression `x<-y` is ambiguous. It can be `x <- y` or `x < -y`.
    The assignment operator has priority, and was replaced by a left-pointing arrow.
    Here we put it back.
  -->
  <xsl:template match="code//text()">
    <xsl:sequence select="replace(., '&#x2190;', '&lt;-')"/>
  </xsl:template>
  
</xsl:stylesheet>
