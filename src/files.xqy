module namespace files='http://marklogic.com/dumpcek/files';

declare namespace db='http://marklogic.com/xdmp/database';

declare function files:get-file ($collection as xs:string, $file as xs:string) {
    files:get-file ($collection, $file, 99999)
};

declare function files:get-file ($collection as xs:string, $file as xs:string, $limit) {
    let $uris := cts:uri-match ('*/'||$file, 'limit='||$limit, cts:collection-query ($collection))
    return fn:doc ($uris)
};
