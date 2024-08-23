module namespace reports='http://marklogic.com/dumpcek/reports';

declare namespace db='http://marklogic.com/xdmp/database';

import module namespace files='http://marklogic.com/dumpcek/files' at 'files.xqy';
import module namespace mom = 'http://marklogic.com/support/map-of-maps' at 'mom.xqy';


declare function reports:get-merge-params ($collection) {
    let $dbs := (/db:databases)[1]/..
    let $maps :=
        for $db in $dbs/db:databases/db:database
        return 
            map:new ((
                map:entry ('database-name', $db/db:database-name),
                map:entry ('merge-priority', $db//db:merge-priority),
                map:entry ('merge-max-size', $db//db:merge-max-size),
                map:entry ('merge-min-size', $db//db:merge-min-size),
                map:entry ('merge-min-ratio', $db//db:merge-min-ratio),
                map:entry ('merge-timestamp', $db//db:merge-timestamp),
                map:entry ('retain-until-backup', $db//db:retain-until-backup)
                ))
    return $maps
};

declare function reports:get-merge-params-table ($collection) {
    let $results := reports:get-merge-params ($collection)
    let $columns := ('database-name','merge-priority','merge-max-size','merge-min-size','merge-min-ratio','merge-timestamp','retain-until-backup')
    let $config := map:new ((map:entry ('columns', $columns), map:entry ('caption', 'Merge parameters for databases in dump.')))
    let $mom := mom:result-to-mom ($config, $results)
    let $table := mom:table ($mom)
    return $table
};
