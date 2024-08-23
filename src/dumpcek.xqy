import module namespace header='http://marklogic.com/dumpcek/header' at 'header.xqy';
import module namespace files='http://marklogic.com/dumpcek/files' at 'files.xqy';
import module namespace reports='http://marklogic.com/dumpcek/reports' at 'reports.xqy';

declare variable $local:home-page := '/dumpcek.xqy';

declare function local:dump-type ($collection) {
    let $string := (files:get-file ($collection, 'Support-Request.txt'), 'No dump report found for collection '||$collection||'.')[1]
    return fn:string-join (fn:tokenize (fn:normalize-space ($string), ' Report '), '; Report ')
};

let $content := xdmp:set-response-content-type('text/html')
let $collection := header:get-collection-value ()
let $cookie := header:set-collection-cookie ($collection)
let $database-name := xdmp:database-name (xdmp:database())


return
(
<html lang='en-US'>
  <head>
    <meta charset='utf-8' />
    <title>My test page</title>
  </head>
    <body>
        <h1>Using database {$database-name}</h1>
        <hr/>
        <div>{header:set-collection-form($collection, $local:home-page)}</div>
{
    if ($collection = $header:default-collection) then () else (
        <hr/>,local:dump-type($collection),
        <hr/>,header:set-report-form($collection, $local:home-page),
        <hr/>,
        reports:get-merge-params-table ($collection)
    )
}
    </body>
</html>
)
