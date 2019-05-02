module namespace formDelete = "http://dbx.iro37.ru/zapolnititul/api/form/post";

import module namespace session = "http://basex.org/modules/session";
import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../../config.xqm";

declare
  %updating 
  %rest:path ( "/zapolnititul/api/v2/forms/delete" )
  %rest:GET
  %rest:query-param ( "id", "{ $id }", "" )
  %rest:query-param ( "redirect", "{ $redirect }", "/" )
function formDelete:get( 
  $id,
  $redirect
) {
    let $form := $config:form( $id )[ @userid/data() = session:get( 'userid' ) ]
    return
      (
        if ( $form ) 
        then ( 
          delete node $form,
          db:output( 
            web:redirect( 
              web:create-url( $redirect, map{ "message" : "форма удалена"} ) 
            ) 
          )
        ) 
        else (
          db:output( 
            web:redirect( 
              web:create-url( $redirect, map{ "message" : "форма не удалена"} ) 
            ) 
          )
        )  
      )
};

(:------------------ старая версия ---------------------:)
declare
  %updating 
  %rest:path ( "/zapolnititul/api/v2/forms/delete1" )
  %rest:POST
  %rest:GET
  %rest:form-param ( "id", "{ $id }", "" )
  %rest:form-param ( "redirect", "{ $redirect }", "/" )
function formDelete:post( 
  $id,
  $redirect
) {
    let $form := $config:form( $id )[ @userid/data() = session:get( 'userid' ) ]
    return
      (
        if ( $form ) 
        then ( 
          delete node $form,
          db:output( 
            web:redirect( 
              web:create-url( $redirect, map{ "message" : "форма удалена"} ) 
            ) 
          )
        ) 
        else (
          db:output( 
            web:redirect( 
              web:create-url( $redirect, map{ "message" : "форма не удалена"} ) 
            ) 
          )
        )  
      )
};