module namespace dataDelete = "http://dbx.iro37.ru/zapolnititul/api/form/data/delete";

import module namespace session = "http://basex.org/modules/session";

declare
  %updating
  %rest:path ( "/zapolnititul/api/v2.1/data/users/{ $userID }/templates/{ $templateID }/instances/{ $inst }/delete" )
  %rest:query-param( "redirect_url", "{ $redirect_url }", "" )
  %rest:GET
  %rest:POST
function dataDelete:delete( $userID, $templateID, $inst, $redirect_url ){
  let $db := db:open( "titul24", "data" )/data
  let $nodeToDelete := 
    $db/table[
      @templateID = $templateID
      and @userID = $userID
      and @id = $inst
    ]
  return
    (
      if ( $nodeToDelete )
      then (
            for $i in $nodeToDelete
            return
              if( $i/@status )
              then(
                replace value of node $i/@status with "delete"
              )
              else(
                insert node attribute { "status" } { "delete" } into $i
              )
      )
      else (
       update:output(
         <a>{  session:get( 'userid' ) }</a>
       )
      ),
      update:output(
        web:redirect(
          if ( $redirect_url != "" )
          then( $redirect_url )
          else( "/zapolnititul/forms/u/data/" || $templateID ) 
      )
    )
  )
};