<?xml version="1.0" ?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
>

  <xsl:mode on-no-match="shallow-copy"/>

  <!--
    The named-content element contains mixed content.
    This is hidden from the parser by storing it (serialized) in the @content attribute.
  -->
  <xsl:template match="named-content">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:attribute name="content" select="serialize(node())"/>
    </xsl:copy>
  </xsl:template>

  <!--
    The expression `x<-y` is ambiguous. It can be `x <- y` or `x < -y`.
    The assignment operator has priority, and here we turn it into a left-pointing arrow.
  -->
  <xsl:template match="code//text()">
    <xsl:sequence select="replace(., '&lt;-', '&#x2190;')"/>
  </xsl:template>

</xsl:stylesheet>
