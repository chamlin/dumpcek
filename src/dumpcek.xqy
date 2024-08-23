import module namespace header='http://marklogic.com/dumpcek/header' at 'header.xqy';

declare variable $local:home-page := '/dumpcek.xqy';

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
        <h1>Greeting</h1>
        Hello leetle monkeyfaces!
        <div>{header:set-collection-form($collection, $local:home-page)}</div>
    </body>
</html>
)
