module namespace sc = "http://declarative.amsterdam/syntax-coloring";
declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

import module namespace ixml = "http://rakensi.com/exist-db/xquery/functions/ixml";

declare variable $sc:grammar as xs:string := unparsed-text('xmldb:exist://db/apps/da2024/r.ixml');

declare variable $sc:parser := ixml:transparent-invisible-xml($sc:grammar, map{});


declare function sc:regexp($code as element(code))
as element(code)
{
  let $stylesheet := doc('xmldb:exist://db/apps/da2024/xsl/jats-code-regexp.xsl')
  return
    transform:transform($code, $stylesheet, ())
};


declare function sc:ixml($code as element(code))
as element(code)
{
  $code
  => transform:transform(doc('xmldb:exist://db/apps/da2024/xsl/preprocess.xsl'), ())
  => $sc:parser()
  => transform:transform(doc('xmldb:exist://db/apps/da2024/xsl/move-code-up.xsl'), ())
};


declare function sc:ixml-postprocessed($code as element(code))
as element(code)
{
  $code
  => sc:ixml()
  => transform:transform(doc('xmldb:exist://db/apps/da2024/xsl/postprocess.xsl'), ())
};


declare function sc:ixml-simplified($code as element(code))
as element(code)
{
  $code
  => sc:ixml-postprocessed()
  => transform:transform(doc('xmldb:exist://db/apps/da2024/xsl/jats-code-tixml.xsl'), ())
};


declare function sc:xml($xml as element())
{
  $xml
  => transform:transform(doc('xmldb:exist://db/apps/da2024/xsl/xml-highlighting.xsl'), ())
};
