<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:template match="styled-content">
    <span class="{string(@style)}"><xsl:sequence select="node()"/></span>
  </xsl:template>
  
  <xsl:template match="named-content">
    <span class="{string(@content-type)}"><xsl:sequence select="node()"/></span>
  </xsl:template>
  
  <xsl:template match="code/text()[not(following-sibling::node()) and matches(., '[\r\n]+\s*$')]">
    <!-- remove empty last line -->
  </xsl:template>

  <xsl:template match="code//*" priority="-10">
    <!-- Throw away most of the markup. -->
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="code//function_call/*[1]">
    <span class="function-call">
      <xsl:sequence select="string(.)"/>
    </span>
  </xsl:template>

  <xsl:template match="code//(lpar|rpar|lsbr|rsbr|dlsbr|drsbr|lcbr|rcbr)">
    <span class="punctuation">
      <xsl:sequence select="string(.)"/>
    </span>
  </xsl:template>
 
  <xsl:template match="code//sublist/sub/symbol[following-sibling::*[1]/name() = ('eq_assign')]">
    <span class="parameter">
      <xsl:sequence select="string(.)"/>
    </span>
  </xsl:template>
 
  <xsl:template match="code//(bool|null_const|num_const)">
    <span class="literal">
      <xsl:sequence select="string(.)"/>
    </span>
  </xsl:template>
  
  <xsl:template match="code//(integerLiteral|decimalLiteral|doubleLiteral)">
    <span class="number">
      <xsl:sequence select="string(.)"/>
    </span>
  </xsl:template>

  <xsl:template match="code//str_const">
    <span class="string">
      <xsl:sequence select="string(.)"/>
    </span>
  </xsl:template>
 
  <xsl:template match="code//symbol" priority="-1">
    <span class="identifier">
      <xsl:sequence select="string(.)"/>
    </span>
  </xsl:template>

  <xsl:template match="code//(module_identifier|ns_get|ns_get_int)">
    <span class="module-identifier">
      <xsl:sequence select="string(.)"/>
    </span>
  </xsl:template>

  <xsl:template match="code//(function|if|else|for|in|while|repeat|next|break)">
    <span class="keyword">
      <xsl:sequence select="string(.)"/>
    </span>
  </xsl:template>
 
  <xsl:template match="code//(eq_assign|question|left_assign|right_assign|tilda|or1|or2|and1|and2|not|compare|plus_minus|times_divide|special|seq|power|dollar|at)">
    <span class="operator">
      <xsl:sequence select="string(.)"/>
    </span>
  </xsl:template>
 
  <xsl:template match="code//comment">
    <span class="comment">
      <xsl:sequence select="string(.)"/>
    </span>
  </xsl:template>

</xsl:stylesheet>