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
    The expression `x<-y` is ambiguous. It can be `x <- y` or `x < -y`.
    The assignment operator has priority, and was replaced by a left-pointing arrow.
    Here we put it back.
  -->
  <xsl:template match="code//text()">
    <xsl:sequence select="replace(., '&#x2190;', '&lt;-')"/>
  </xsl:template>
  
</xsl:stylesheet>
