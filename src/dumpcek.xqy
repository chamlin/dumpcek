import module namespace header='http://marklogic.com/dumpcek/header' at 'header.xqy';

declare variable $local:home-page := '/dumpcek.xqy';

declare function local:dump-type ($collection) {
    let $string := (fn:doc (cts:uri-match ('*/Support-Request.txt', 'limit=1', cts:collection-query ($collection))), 'No dump report found for collection '||$collection||'.')[1]
    return fn:string-join (fn:tokenize (fn:normalize-space ($string), ' Report '), '; Report ')
};

let $content := xdmp:set-response-content-type('text/html')
let $collection := header:get-collection-value ()
let $cookie := header:set-collection-cookie ($collection)


return
(
<html lang='en-US'>
  <head>
    <meta charset='utf-8' />
    <title>My test page</title>
  </head>
    <body>
        <h1>Greetings</h1>
        Hello leetle monkeyfaces!
        <div>{header:set-collection-form($collection, $local:home-page)}</div>
        <hr/>
{
    if ($collection = $header:default-collection) then () else (
        local:dump-type($collection),
        <hr/>,
        'ohai'
    )
}
    </body>
</html>
)
