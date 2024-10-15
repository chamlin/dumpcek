import module namespace header='http://marklogic.com/dumpcek/header' at 'header.xqy';
import module namespace basics = 'http://marklogic.com/dumpcek/basics' at 'basics.xqy';
import module namespace files='http://marklogic.com/dumpcek/files' at 'files.xqy';

declare namespace db='http://marklogic.com/xdmp/database';
declare namespace fs = 'http://marklogic.com/xdmp/status/forest';
declare namespace a = 'http://marklogic.com/xdmp/assignments';

(: this comes from the confdiff repo :)

declare option xdmp:indent 'yes';

declare function local:sort-key ($node as node()) {
  typeswitch($node)
      case element() return 
          if (fn:node-name ($node) eq xs:QName ('db:database')) then
              fn:string ($node/db:database-name)
          else if (fn:node-name ($node) = (xs:QName ('db:field'), xs:QName ('db:range-field-index'))) then
              fn:string ($node/db:field-name)
          else if (fn:node-name ($node) eq xs:QName ('db:field-path')) then
              fn:string ($node/db:path)
          else if (fn:node-name ($node) eq xs:QName ('db:path-namespace')) then
              concat(fn:string($node/db:namespace-uri), '=', fn:string($node/db:prefix))
          else if (fn:node-name ($node) eq xs:QName ('db:forest-id')) then
              fn:count ($node/preceding-sibling::db:forest-id)
          else if (fn:exists ($node/db:localname)) then
              fn:string-join (($node/db:localname,$node/db:parent-localname,$node/db:namespace-uri)/fn:string(), '+')
          else
              fn:local-name ($node)
      case attribute() return 
          fn:local-name ($node)
      default return fn:string ($node)
 
};

declare function local:expand-element-by-localname ($e as element()) {
    let $localnames :=
            for $s in $e/db:localname/fn:string()
            for $t in fn:tokenize (fn:normalize-space ($s), ' ')
            return $t
    return (
        if (fn:count ($localnames) <= 1) then
            $e
        else 
            for $ln in $localnames 
            return
                element { fn:node-name ($e) } {
                    $e/@*,
                    for $e in $e/node()
                    order by local:sort-key ($e)
                    return
                        if (fn:node-name ($e) eq xs:QName ('db:localname')) then 
                            <db:localname>{$ln}</db:localname>
                        else 
                            $e
                }
    )
};


declare function local:change ($node, $axml) {
  typeswitch($node)
      case document-node() return 
          local:change ($node/*, $axml)
      case processing-instruction() return 
          $node
      case comment() return
          $node
      case text() return 
          if (fn:node-name ($node/parent::*) = $local:numeric-masked) then
                '#######'
          else if (fn:node-name ($node/parent::*) = ('db:forest-id' ! xs:QName (.))) then
                ($axml//a:assignment[a:forest-id/fn:data() = xs:unsignedLong($node)]/a:forest-name/fn:string(), '#######')[1]
          else 
                $node
      case element() return 
            element { fn:node-name ($node) } {
                (: TODO?  convert the timestamp attribute? :)
                for $a in $node/@*
                order by local:sort-key ($a)
                return $a
                ,
                let $kids := 
                    for $n in $node/node()
                    return
                        if ($n/element()) then local:expand-element-by-localname ($n)
                        else $n
                for $k in $kids
                let $sort-key := local:sort-key ($k)
                order by $sort-key
                return (
                    if ($local:debug) then <sort-key>{$sort-key}</sort-key> else (),
                    local:change ($k, $axml)
                )
            }
      default return fn:error(xs:QName("ERROR"), 'huh? local:change of '||xdmp:describe ($node, (), ()))
};

declare variable $local:numeric-masked := (
    xs:QName ('db:security-database'), xs:QName ('db:schema-database'), xs:QName ('db:triggers-database'),
    xs:QName ('db:backup-id')
);

declare variable $local:debug := fn:false();

let $content := xdmp:set-response-content-type('text/xml')
let $collection := header:get-collection-value ()

let $dbxml := files:get-file ($collection, 'databases.xml', 1)
let $axml := files:get-file ($collection, 'assignments.xml', 1)

let $new := local:change ($dbxml, $axml)
return $new

