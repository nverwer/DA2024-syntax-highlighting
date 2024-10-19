<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:r="https://www.r-project.org/" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:da="http://www.declarative.amsterdam/namespace" exclude-result-prefixes="#all" version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>

  <!-- R syntax highlighting for code[lower-case(@language)='r'] -->
  <!-- Based on https://github.com/highlightjs/highlight.js/blob/main/src/languages/r.js -->
  
  <xsl:variable name="r:IDENT_RE">([a-zA-Z]|\.[._a-zA-Z])[._a-zA-Z0-9]*|\.(\s)|\.$</xsl:variable>
  <!--
    Identifiers in R cannot start with `_`, but they can start with `.` if it is not immediately followed by a digit.
    TODO: R also supports quoted identifiers, which are near-arbitrary sequences delimited by backticks (`…`), which may contain escape sequences.
    TODO: Support Unicode identifiers.
  -->
  
  <xsl:variable name="r:MODULE_IDENT_RE">(([a-zA-Z]|\.[._a-zA-Z])[._a-zA-Z0-9]*)(::)</xsl:variable>
  
  <xsl:variable name="r:FUNCTION_CALL_RE">(([a-zA-Z]|\.[._a-zA-Z])[._a-zA-Z0-9]*)(\s*\()</xsl:variable>
  
  <xsl:variable name="r:PARAMETER_RE">(([a-zA-Z]|\.[._a-zA-Z])[._a-zA-Z0-9]*)(\s*=\s*)</xsl:variable>
  
  <xsl:variable name="r:NUMBER_TYPES_RE_1">0[xX][0-9a-fA-F]+\.[0-9a-fA-F]*[pP][+-]?\d+i?</xsl:variable>
  <!-- Special case: only hexadecimal binary powers can contain fractions. -->
  
  <xsl:variable name="r:NUMBER_TYPES_RE_2">0[xX][0-9a-fA-F]+([pP][+-]?\d+)?[Li]?</xsl:variable>
  <!-- Hexadecimal numbers without fraction and optional binary power -->
  
  <xsl:variable name="r:NUMBER_TYPES_RE_3">(\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?[Li]?</xsl:variable>
  <!-- Decimal numbers -->
  
  <xsl:variable name="r:NUMBER_TYPES_RE" select="string-join(($r:NUMBER_TYPES_RE_1, $r:NUMBER_TYPES_RE_2, $r:NUMBER_TYPES_RE_3), '|')"/>
  
  <!--<xsl:variable name="r:CONSTANTS_RE">LETTERS|letters|month.abb|month.name|pi|T|F</xsl:variable>-->
  
  <!--<xsl:variable name="r:FUNCTIONS_RE">abs|acos|acosh|all|any|anyNA|Arg|as\.call|as\.character|as\.complex|as\.double|as\.environment|as\.integer|as\.logical|as\.null\.default|as\.numeric|as\.raw|asin|asinh|atan|atanh|attr|attributes|baseenv|browser|c|call|ceiling|class|Conj|cos|cosh|cospi|cummax|cummin|cumprod|cumsum|digamma|dim|dimnames|emptyenv|exp|expression|floor|forceAndCall|gamma|gc\.time|globalenv|Im|interactive|invisible|is\.array|is\.atomic|is\.call|is\.character|is\.complex|is\.double|is\.environment|is\.expression|is\.finite|is\.function|is\.infinite|is\.integer|is\.language|is\.list|is\.logical|is\.matrix|is\.na|is\.name|is\.nan|is\.null|is\.numeric|is\.object|is\.pairlist|is\.raw|is\.recursive|is\.single|is\.symbol|lazyLoadDBfetch|length|lgamma|list|log|max|min|missing|Mod|names|nargs|nzchar|oldClass|on\.exit|pos\.to\.env|proc\.time|prod|quote|range|Re|rep|retracemem|return|round|seq_along|seq_len|seq\.int|sign|signif|sin|sinh|sinpi|sqrt|standardGeneric|substitute|sum|switch|tan|tanh|tanpi|tracemem|trigamma|trunc|unclass|untracemem|UseMethod|xtfrm</xsl:variable>-->
  
  <xsl:variable name="r:OPERATORS_RE">[=!&lt;&gt;:]=|\|\||&amp;&amp;|:::?|&lt;-|&lt;&lt;-|-&gt;&gt;|-&gt;|\|&gt;|[-+*/?!$&amp;|:&lt;=&gt;@^~]|\*\*|%[-+*/?!$&amp;|:&lt;=&gt;@^~a-zA-Z]*%</xsl:variable>
  
  <xsl:variable name="r:PUNCTUATION_RE">[()]|[{}]|\[\[|[\[\]]|\\|,</xsl:variable>
  
  <xsl:variable name="r:KEYWORD_RE">(function|if|in|break|next|repeat|else|for|while)(\s)</xsl:variable>
  
  <xsl:variable name="r:LITERAL_RE">NULL|NA|TRUE|FALSE|Inf|NaN|NA_integer_|NA_real_|NA_character_|NA_complex_</xsl:variable>
  
  <xsl:variable name="r:STRING_RE">"([^\\"]|\\.)*"|'([^\\']|\\.)*'</xsl:variable>
  
  <xsl:variable name="r:COMMENT_RE">#.*$</xsl:variable>
  
  <xsl:variable name="r:MATCH_REs" select="($r:COMMENT_RE, $r:STRING_RE, $r:LITERAL_RE, $r:KEYWORD_RE, $r:PUNCTUATION_RE, $r:OPERATORS_RE, $r:NUMBER_TYPES_RE, $r:FUNCTION_CALL_RE, $r:MODULE_IDENT_RE, $r:PARAMETER_RE, $r:IDENT_RE)"/>
  <xsl:variable name="r:MATCH_RE" select="string-join($r:MATCH_REs, '|')"/>
  
  <xsl:template match="code[lower-case(@language)='r']/text()">
    <xsl:param name="unindent" as="xs:string?"/>
    <xsl:variable name="unindented-code" as="xs:string" select="if (empty($unindent) or $unindent eq '') then string(.) else replace(string(.), '^'||$unindent, '', 'm')"/>
    <xsl:analyze-string select="$unindented-code" regex="{$r:MATCH_RE}" flags="m">
      <xsl:matching-substring>
        <xsl:choose>
          <xsl:when test="matches(., '^('||$r:COMMENT_RE||')$')">
            <xsl:sequence select="r:styled-content('comment', .)"/>
          </xsl:when>
          <xsl:when test="matches(., '^('||$r:LITERAL_RE||')$')">
            <xsl:sequence select="r:styled-content('literal', .)"/>
          </xsl:when>
          <xsl:when test="matches(., '^('||$r:STRING_RE||')$')">
            <xsl:sequence select="r:styled-content('string', .)"/>
          </xsl:when>
          <xsl:when test="matches(., '^('||$r:KEYWORD_RE||')$')">
            <xsl:sequence select="r:styled-content('keyword', normalize-space(.))"/>
            <xsl:sequence select="replace(., '.*\S(\s*)$', '$1')"/>
          </xsl:when>
          <xsl:when test="matches(., '^('||$r:PUNCTUATION_RE||')$')">
            <xsl:sequence select="r:styled-content('punctuation', .)"/>
          </xsl:when>
          <xsl:when test="matches(., '^('||$r:OPERATORS_RE||')$')">
            <xsl:sequence select="r:styled-content('operator', .)"/>
          </xsl:when>
          <xsl:when test="matches(., '^('||$r:NUMBER_TYPES_RE||')$')">
            <xsl:sequence select="r:styled-content('number', .)"/>
          </xsl:when>
          <xsl:when test="matches(., '^('||$r:FUNCTION_CALL_RE||')$')">
            <xsl:sequence select="r:styled-content('function-call', replace(., '\s*\($', ''))"/>
            <xsl:sequence select="r:styled-content('punctuation', replace(., '.+(\s*\()$', '$1'))"/>
          </xsl:when>
          <xsl:when test="matches(., '^('||$r:MODULE_IDENT_RE||')$')">
            <xsl:sequence select="r:styled-content('module-identifier', .)"/>
          </xsl:when>
          <xsl:when test="matches(., '^('||$r:PARAMETER_RE||')$')">
            <xsl:sequence select="r:styled-content('parameter', replace(., '(\S)\s*=\s*$', '$1'))"/>
            <xsl:sequence select="replace(., '.*\S(\s*=\s*)$', '$1')"/>
          </xsl:when>
          <xsl:when test="matches(., '^('||$r:IDENT_RE||')$')">
            <xsl:sequence select="r:styled-content('identifier', replace(., '\s+$', ''))"/>
            <xsl:if test="matches(., '\s$')">
              <xsl:sequence select="replace(., '^.*\S', '')"/>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:sequence select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
  <xsl:function name="r:styled-content">
    <xsl:param name="style" as="xs:string"/>
    <xsl:param name="styled-content" as="xs:string"/>
    <!-- JATS output -->
    <!--<styled-content style="{$style}"><xsl:sequence select="$styled-content"/></styled-content>-->
    <!-- HTML output -->
    <span class="{$style}">
        <xsl:sequence select="$styled-content"/>
    </span>
  </xsl:function>
  
  
  <xsl:template match="code">
    <!-- unindent is the extra, superfluous spacing that all lines have -->
    <xsl:variable name="unindent" as="xs:string?" select="(analyze-string(string(.), '^( *)\S', 'm')/fn:match/fn:group/string-length(.) =&gt; min()) ! (1 to .) ! ' ' =&gt; string-join('')"/>
    <code>
      <xsl:choose>
        <xsl:when test="lower-case(@language)='r' and not(@code-type='output')">
          <xsl:apply-templates select="node()">
            <xsl:with-param name="unindent" select="$unindent"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </code>
  </xsl:template>
  
  
  <!-- Elements that may be nested inside <code>, which need conversion to HTML. -->
  
  <xsl:template match="code/styled-content">
    <span class="{string(@style)}">
        <xsl:apply-templates select="node()"/>
    </span>
  </xsl:template>
  
  <xsl:template match="code/named-content">
    <span class="{string(@content-type)}">
        <xsl:apply-templates select="node()"/>
    </span>
  </xsl:template>
  
</xsl:stylesheet>