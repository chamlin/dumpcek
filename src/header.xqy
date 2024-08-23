module namespace header='http://marklogic.com/dumpcek/header';

declare variable $header:default-collection := 'None';

declare function header:set-collection-form ($collection, $home-page) {
        <form action='{$home-page}'>
            <div>
                <label for='collection'>Choose a collection: </label>
                <input type='text' id='collection' name='collection' value='{$collection}'/>
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
<select name="reports" id="report-select">
  <option value="">--Please choose an option--</option>
  <option value="merge-params">Merge parameters</option>
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
