(: http://localhost:8080/exist/apps/da2024/demo.xq
Install this in eXist, in `/apps/da2024`.
Transform the testdoc.xml in different ways, using regexp and tixml.
Make a HTML file to show the results.
:)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html5";
declare option output:media-type "text/html";

import module namespace sc = "http://declarative.amsterdam/syntax-coloring" at "xqm/syntax-coloring.xqm";


declare function local:serialize($code as element(code))
{
  (: We do not want to preserve spaces in the indented code. :)
  element code
  { $code/@* except $code/@xml:space
  , $code/node()
  }
  => serialize(map{'indent': true()})
  (: => sc:xml() :)
};


declare function local:original-code($code as element(code))
{
  <pre>{ local:serialize($code) }</pre>
};


declare function local:regexp-code($code as element(code))
{
  let $regexp-sc as element(code) := sc:regexp($code)
  return
  ( <p>{ $regexp-sc }</p>
  , <pre>{ local:serialize($regexp-sc) }</pre>
  )
};


declare function local:ixml-code($code as element(code))
{
  let $ixml-sc as element(code) := sc:ixml($code)
  return
    <pre>{ local:serialize($ixml-sc) }</pre>
};


declare function local:ixml-postprocessed-code($code as element(code))
{
  let $ixml-sc as element(code) := sc:ixml-postprocessed($code)
  return
    <pre>{ local:serialize($ixml-sc) }</pre>
};


declare function local:ixml-simplified-code($code as element(code))
{
  let $ixml-sc as element(code) := sc:ixml-simplified($code)
  return
  ( <p>{ $ixml-sc }</p>
  , <pre>{ local:serialize($ixml-sc) }</pre>
  )
};


declare function local:code-section($code as element(code))
{
  let $id-prefix := generate-id($code) || '-'
  return
    <div class="tabs">
      <input type="radio" name="{$id-prefix}tabs" id="{$id-prefix}original" checked=""></input>
      <input type="radio" name="{$id-prefix}tabs" id="{$id-prefix}regexp"></input>
      <input type="radio" name="{$id-prefix}tabs" id="{$id-prefix}ixml"></input>
      <input type="radio" name="{$id-prefix}tabs" id="{$id-prefix}ixml-postprocessed"></input>
      <input type="radio" name="{$id-prefix}tabs" id="{$id-prefix}ixml-formatted"></input>
      <label for="{$id-prefix}original">original</label>
      <label for="{$id-prefix}regexp">regexp</label>
      <label for="{$id-prefix}ixml">ixml</label>
      <label for="{$id-prefix}ixml-postprocessed">ixml-postprocessed</label>
      <label for="{$id-prefix}ixml-simplified">ixml-simplified</label>
      <div class="tabs-content">
        <div class="tab">{ local:original-code($code) }</div>
        <div class="tab">{ local:regexp-code($code) }</div>
        <div class="tab">{ local:ixml-code($code) }</div>
        <div class="tab">{ local:ixml-postprocessed-code($code) }</div>
        <div class="tab">{ local:ixml-simplified-code($code) }</div>
      </div>
    </div>
};


let $testdoc as element() := doc('xmldb:exist://db/apps/da2024/testdoc.xml')/*
let $testdocparts := $testdoc/*
let $content :=
  for $part in $testdocparts
  return
    if ($part/self::code) then
      local:code-section($part)
    else
      $part

return
  <html>
    <head>
      <style><![CDATA[
        h1 {
          font-size: 14pt;
        }

        .tabs-content {
          font-size: 12pt !important; /* Increase for demo! */
        }
        .tabs input[type="radio"] { display: none; }
        .tabs label {
          display: inline-block;
          margin: 0.5em 0 0 0.5em;
          padding: 0.2em 0.5em;
          border: 1px solid #aaa;
          border-bottom: 0;
          color: #333;
          background: #ccc;
        }
        .tabs label:hover { background-color: #ccc; }
        .tabs input[type="radio"]:nth-of-type(1):checked ~ label:nth-of-type(1),
        .tabs input[type="radio"]:nth-of-type(2):checked ~ label:nth-of-type(2),
        .tabs input[type="radio"]:nth-of-type(3):checked ~ label:nth-of-type(3),
        .tabs input[type="radio"]:nth-of-type(4):checked ~ label:nth-of-type(4),
        .tabs input[type="radio"]:nth-of-type(5):checked ~ label:nth-of-type(5) {
          border: 1px solid #777;
          border-bottom: 2px solid #fff;
          margin-bottom: -1px;
          color: #000;
          background: #fff;
        }
        .tabs-content {
          display: grid;
          border: 1px solid #777;
        }
        .tabs-content>* {
          grid-column: 1;
          grid-row: 1;
          visibility: hidden;
          padding: 0.2em;
          max-height: 80vh;
          overflow: auto;
        }
        .tabs input[type="radio"]:nth-of-type(1):checked ~ .tabs-content>*:nth-of-type(1),
        .tabs input[type="radio"]:nth-of-type(2):checked ~ .tabs-content>*:nth-of-type(2),
        .tabs input[type="radio"]:nth-of-type(3):checked ~ .tabs-content>*:nth-of-type(3),
        .tabs input[type="radio"]:nth-of-type(4):checked ~ .tabs-content>*:nth-of-type(4),
        .tabs input[type="radio"]:nth-of-type(5):checked ~ .tabs-content>*:nth-of-type(5) {
          visibility: visible;
        }

        .xml-element { color: #20749d; }
        .xml-attribute { color: #444466; }
        .xml-text { color: #747500; }
        .xml-comment { color:#790000 }
      ]]></style>
      <link rel="stylesheet" href="regexp-sc.css"/>
      <link rel="stylesheet" href="ixml-sc.css"/>
    </head>
    <body>
      {$content}
    </body>
  </html>
