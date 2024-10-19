<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <xsl:output method="html" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <!-- Define classes for different element types -->
  <xsl:variable name="elementClass" select="'xml-element'"/>
  <xsl:variable name="attributeClass" select="'xml-attribute'"/>
  <xsl:variable name="textClass" select="'xml-text'"/>
  <xsl:variable name="commentClass" select="'xml-comment'"/>

  <xsl:template match="*">
    <xsl:param name="indent" select="''"/>
    <div>
      <div class="{$elementClass}">
        <xsl:value-of select="$indent"/>
        <xsl:value-of select="concat('&lt;', name())"/>
        <xsl:apply-templates select="@*"/>
        <xsl:value-of select="'&gt;'"/>
      </div>
      <xsl:apply-templates select="node()">
        <xsl:with-param name="indent" select="concat($indent, '.&#xA0;.&#xA0;')"/>
      </xsl:apply-templates>
      <xsl:value-of select="$indent"/>
      <div class="{$elementClass}">
        <xsl:value-of select="$indent"/>
        <xsl:value-of select="concat('&lt;/', name(), '&gt;')"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="@*">
    <span class="{$attributeClass}">
      <xsl:text> </xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:text>=&quot;</xsl:text>
      <xsl:value-of select="replace(., '&quot;', '&amp;quot;')"/>
      <xsl:text>&quot;</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:param name="indent" select="''"/>
    <xsl:variable name="nrm-text" select="normalize-space(replace(., '&#x0A;', ' '))"/>
    <xsl:if test="$nrm-text ne ''">
      <div>
        <xsl:value-of select="$indent"/>
        <span class="{$textClass}">
          <xsl:value-of select="$nrm-text"/>
        </span>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="comment()">
    <xsl:param name="indent" select="''"/>
    <div>
      <xsl:value-of select="$indent"/>
      <span class="{$commentClass}">
        <xsl:text>&lt;-- </xsl:text>
        <xsl:value-of select="."/>
        <xsl:text> --&gt;</xsl:text>
      </span>
    </div>
  </xsl:template>

</xsl:stylesheet>