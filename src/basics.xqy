module namespace basics='http://marklogic.com/dumpcek/basics';

declare variable $basics:home-page := '/dumpcek.xqy';

declare function basics:uri () {
    $basics:home-page
};

declare function basics:uri ($params as map:map) {
    fn:string-join ((
        $basics:home-page, '?',
        fn:string-join ((
                for $key in map:keys ($params)
                return fn:string-join (($key, '=', map:get ($params, $key)), '')
        ), '&amp;')
    ), '')
};



