import module namespace basics='http://marklogic.com/dumpcek/basics' at 'basics.xqy';
import module namespace header='http://marklogic.com/dumpcek/header' at 'header.xqy';
import module namespace files='http://marklogic.com/dumpcek/files' at 'files.xqy';
import module namespace reports='http://marklogic.com/dumpcek/reports' at 'reports.xqy';

declare namespace c = 'http://marklogic.com/xdmp/clusters';


declare function local:dump-type ($collection) {
    let $string := (files:get-file ($collection, 'Support-Request.txt'), 'No dump report found for collection '||$collection||'.')[1]
    let $report-line := fn:string-join (fn:tokenize (fn:normalize-space ($string), ' Report '), '; Report ')
    let $clusters := files:get-file ($collection, 'clusters.xml', 1)
    let $effective := $clusters/c:clusters/c:effective-version/fn:string()
    let $security := $clusters/c:clusters/c:security-version/fn:string()
    return ($report-line, <br/>, 'Effective version: '||$effective||'; Security version: '||$security)
};


let $content := xdmp:set-response-content-type('text/html')
let $collection := header:get-collection-value ()
let $cookie := header:set-collection-cookie ($collection)
let $database-name := xdmp:database-name (xdmp:database())

let $report := (xdmp:get-request-field ('report'), 'None')[1]


return
(
<html lang='en-US'>
  <head>
    <meta charset='utf-8' />
    <title>My test page</title>
    <link rel="stylesheet" href="dumpcek.css"/>
  </head>
    <body>
        <h1>Using database {$database-name, if ($collection != 'None') then ' with collection '||$collection else ()}</h1>
        <hr/>
        <div>{header:set-collection-form($collection, $basics:home-page)}</div>
                {
                    if ($collection = $header:default-collection) then () else (
                        <hr/>,local:dump-type($collection),
                        <hr/>,<a href='/export-databases.xqy'>Export databases.xml</a>,
                        <hr/>,header:set-report-form($collection, $basics:home-page),
                        <hr/>,
                        if ($report = 'None') then ()
                        else if ($report = 'merge-params') then reports:get-merge-params-table ($collection)
                        else if ($report = 'forest-state') then reports:get-forest-state-table ($collection)
                        else if ($report = 'zombies') then (
                            <h4>Checked for zombie transactions</h4>,
                            reports:check-zombie-transactions ($collection)
                        )
                        else ()
                    )
                }
    </body>
</html>
)
