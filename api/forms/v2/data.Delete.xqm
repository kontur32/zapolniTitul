module namespace dataDelete = "http://dbx.iro37.ru/zapolnititul/api/form/data/delete";

import module namespace session = "http://basex.org/modules/session";

declare
  %updating
  %rest:path ( "/zapolnititul/api/v2/data/delete/{ $id }/{ $inst }" )
  %rest:GET
  %rest:POST
function dataDelete:delete( $id, $inst ){
  let $db := db:open("titul24", "data" )/data
  let $nodeToDelete := 
    $db/table[
      @templateID = $id
      and @userID = session:get( 'userid' )
      and @updated = $inst
    ]
  return
    if ( $nodeToDelete )
    then (
      delete node $nodeToDelete
    )
    else ( )
};