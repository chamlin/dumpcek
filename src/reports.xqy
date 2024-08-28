module namespace reports='http://marklogic.com/dumpcek/reports';


declare namespace db='http://marklogic.com/xdmp/database';
declare namespace fs = 'http://marklogic.com/xdmp/status/forest';

import module namespace files='http://marklogic.com/dumpcek/files' at 'files.xqy';
import module namespace mom = 'http://marklogic.com/support/map-of-maps' at 'mom.xqy';


(:  merge params :)

(: TODO - merge-blackouts :)
(: TODO - ummmm, defaults for missing stuff?  :)
declare function reports:get-merge-params ($collection) {
    let $dbs := files:get-file ($collection, 'databases.xml', 1)
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
                map:entry ('retain-until-backup', $db//db:retain-until-backup),
                map:entry ('merge-blackouts', fn:count($db//db:merge-blackout))
                ))
    return $maps
};

declare function reports:get-merge-params-table ($collection) {
    let $results := reports:get-merge-params ($collection)
    let $columns := ('database-name','merge-priority','merge-max-size','merge-min-size','merge-min-ratio','merge-timestamp','retain-until-backup', 'merge-blackouts')
    return reports:generic-table ($columns, $results, 'Merge parameters for databases in dump.')
};

(:  forest timestamps/state :)

declare function reports:get-forest-state ($collection) {
    let $forests := files:get-file ($collection, 'Forest-Status.xml')
    let $maps :=
        for $fs in $forests/fs:forest-status
        order by $fs/fs:nonblocking-timestamp/fn:data() ascending
        return 
            map:new ((
                map:entry ('forest-name', $fs/fs:forest-name/fn:data()),
                map:entry ('state', $fs/fs:state/fn:data()),
                map:entry ('last-state-change', $fs/fs:last-state-change/fn:data()),
                map:entry ('nonblocking-timestamp', xdmp:timestamp-to-wallclock ($fs/fs:nonblocking-timestamp/fn:data()))
                ))
    return $maps
};

declare function reports:get-forest-state-table ($collection) {
    let $results := reports:get-forest-state ($collection)
    let $columns := ('forest-name','state','last-state-change','nonblocking-timestamp')
    return reports:generic-table ($columns, $results, 'States and timestamps for forests in dump.')
};


(: zombie transactions :)

(:
This just gets the forest-status xmls from a dump using a hack that may or may not work. you need the forest-status xmls however you get them.
You could also use xdmp:forest-status for a db's forests to get them directly; if you use xdmp:database-forests, make sure to get the replicas too!
:)
declare function reports:check-zombie-transactions ($collection) {
    let $fs := files:get-file ($collection, 'Forest-Status.xml')/fs:forest-status
    (: now, look for forests that are coordinating transactions, but which aren't open :)
    for $coordinating-not-open in $fs[fs:forest-id = fn:distinct-values ($fs//fs:coordinator-id/fn:data()) and fs:state != 'open']
    let $coordinator-id := $coordinating-not-open/fs:forest-id/fn:data()
    return
        let $acting-master := $fs[fs:forest-id/fn:data() = $coordinating-not-open/fs:current-master-forest/fn:data()]
        let $transaction-dts :=
           for $dt in ($fs//fs:transaction-participant[fs:coordinator-id = $coordinator-id]/fs:min-commit-timestamp/fn:data() ! xdmp:timestamp-to-wallclock (.))
           order by $dt ascending
           return $dt
        return (
            'Consider flipping '||$acting-master/fs:forest-name/fn:string()||' to '||$coordinating-not-open/fs:forest-name/fn:string()||' to clear stuck transaction.',
            'Transaction timestamps affected: ', $transaction-dts,
            ''
        )
};


(: generic table :)
declare function reports:generic-table ($columns, $results, $caption) {
    let $config := map:new ((map:entry ('columns', $columns), map:entry ('caption', $caption)))
    let $mom := mom:result-to-mom ($config, $results)
    let $table := mom:table ($mom)
    return $table
};

