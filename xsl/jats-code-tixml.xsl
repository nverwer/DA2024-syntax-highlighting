<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:template match="code/text()[not(following-sibling::node()) and matches(., '[\r\n]+\s*$')]">
    <!-- remove empty last line -->
  </xsl:template>

  <xsl:template match="code//*" priority="-10">
    <!-- Throw away most of the markup. -->
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="code//function_call/*[1]">
    <xsl:call-template name="make-span">
      <xsl:with-param name="class" select="'function-call'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="code//(lpar|rpar|lsbr|rsbr|dlsbr|drsbr|lcbr|rcbr)">
    <xsl:call-template name="make-span">
      <xsl:with-param name="class" select="'punctuation'"/>
    </xsl:call-template>
  </xsl:template>
 
  <xsl:template match="code//sublist/sub/symbol[following-sibling::*[1]/name() = ('eq_assign')]">
    <xsl:call-template name="make-span">
      <xsl:with-param name="class" select="'parameter'"/>
    </xsl:call-template>
  </xsl:template>
 
  <xsl:template match="code//(bool|null_const|num_const)">
    <xsl:call-template name="make-span">
      <xsl:with-param name="class" select="'literal'"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="code//(integerLiteral|decimalLiteral|doubleLiteral)">
    <xsl:call-template name="make-span">
      <xsl:with-param name="class" select="'number'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="code//str_const">
    <xsl:call-template name="make-span">
      <xsl:with-param name="class" select="'string'"/>
    </xsl:call-template>
  </xsl:template>
 
  <xsl:template match="code//symbol" priority="-1">
    <xsl:call-template name="make-span">
      <xsl:with-param name="class" select="'identifier'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="code//(module_identifier|ns_get|ns_get_int)">
    <xsl:call-template name="make-span">
      <xsl:with-param name="class" select="'module-identifier'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="code//(function|if|else|for|in|while|repeat|next|break)">
    <xsl:call-template name="make-span">
      <xsl:with-param name="class" select="'keyword'"/>
    </xsl:call-template>
  </xsl:template>
 
  <xsl:template match="code//(eq_assign|question|left_assign|right_assign|tilda|or1|or2|and1|and2|not|compare|plus_minus|times_divide|special|seq|power|dollar|at)">
    <xsl:call-template name="make-span">
      <xsl:with-param name="class" select="'operator'"/>
    </xsl:call-template>
  </xsl:template>
 
  <xsl:template match="code//comment">
    <xsl:call-template name="make-span-move-content">
      <xsl:with-param name="class" select="'comment'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="make-span">
    <xsl:param name="class" as="xs:string"/>
    <span class="{$class}" title="{$class}">
      <xsl:apply-templates select="node()" mode="spanned"/>
    </span>
  </xsl:template>

  <xsl:template name="make-span-move-content">
    <xsl:param name="class" as="xs:string"/>
    <!-- named content is moved outside the comment -->
    <xsl:variable name="named-content" select="named-content, named-content/following-sibling::text()"/>
    <span class="{$class}" title="{$class}">
      <xsl:sequence select="(node() except $named-content)/string()"/>
    </span>
    <xsl:apply-templates select="$named-content"/>
  </xsl:template>

  <xsl:template match="*" mode="spanned">
    <xsl:choose>
      <xsl:when test="self::named-content or self::styled-content">
        <xsl:apply-templates select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="node()" mode="spanned"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="styled-content">
    <span class="{string(@style)}"><xsl:sequence select="node()"/></span>
  </xsl:template>
  
  <xsl:template match="named-content">
    <span class="{string(@content-type)}"><xsl:sequence select="node()"/></span>
  </xsl:template>

</xsl:stylesheet>