<?xml version="1.0" ?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
>

  <xsl:mode on-no-match="shallow-copy"/>

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
      <xsl:sequence select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="code">
    <xsl:apply-templates select="node()"/>
  </xsl:template>
  
</xsl:stylesheet>
