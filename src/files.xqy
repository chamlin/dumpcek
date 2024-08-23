module namespace files='http://marklogic.com/dumpcek/files';

declare namespace db='http://marklogic.com/xdmp/database';

declare function files:get-file ($collection as xs:string, $file as xs:string) {
    let $uris := cts:uri-match ('*/'||$file, 'limit=1', cts:collection-query ($collection))
    return fn:doc ($uris[1])
};
