module namespace header='http://marklogic.com/dumpcek/header';

declare variable $header:default-collection := 'None';

declare function header:set-collection-form ($collection, $home-page) {
        <form action='{$home-page}'>
            <div>
                <label for='colection-select'>Choose a collection: </label>
                <select name="collection" id="collection-select">
                  <option value="None">--Please choose a collection</option>
                { for $collection in cts:collections()
                  return <option value="{$collection}">{$collection}</option>
                }
                </select>
            </div>
            <div>
                <button>Submit</button>
            </div>
        </form>
};

declare function header:set-report-form ($collection, $home-page) {
        <form action='{$home-page}'>
            <div>
                <label for='report-select'>Choose a report: </label>
                <select name="report" id="report-select">
                  <option value="None">--Please choose an option--</option>
                  <option value="merge-params">Merge parameters</option>
                  <option value="forest-state">Forest state/timestamp</option>
                </select>
            </div>
            <div>
                <button>Submit</button>
            </div>
        </form>
};

declare function header:get-cookie-map ($cookie-string) {
    let $cookie-map := map:new (
        let $cookies := fn:tokenize ($cookie-string, '; ')
        for $cookie in $cookies
        let $parts := fn:tokenize ($cookie, '=')
        return map:entry($parts[1], xdmp:url-decode ($parts[2]))
    )
    return $cookie-map
};

declare function header:get-collection-value () {
    let $cookies :=  header:get-cookie-map (xdmp:get-request-header ('Cookie'))
    return (xdmp:get-request-field ('collection'), map:get ($cookies, 'collection'), $header:default-collection)[1]
};

declare function header:set-collection-cookie ($collection) {
    xdmp:add-response-header ('Set-Cookie', 'collection='||$collection)
};
