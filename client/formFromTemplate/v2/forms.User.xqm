module namespace user = "http://dbx.iro37.ru/zapolnititul/forms/user";

import module namespace session = "http://basex.org/modules/session";

import module namespace 
  config = "http://dbx.iro37.ru/zapolnititul/forms/u/config" at "../../config.xqm";
  
declare 
  %rest:GET
  %rest:path ( "/zapolnititul/forms/u" )
function user:main ( ) {
  let $redirect := 
    if ( session:get( 'username' ) )
    then (
      let $userFormID := 
        try {
          fetch:xml( "http://localhostupdate:output/zapolnititul/api/v2/users/" || session:get( "userid" ) || "/forms")/forms/form[1]/@id/data()
        }
        catch*{}
      return
      "/zapolnititul/forms/u/form/" || ( if ( $userFormID ) then ( $userFormID ) else( "new" ) )
    )
    else (
      "/zapolnititul"
    )
  return 
    web:redirect ( $config:param( "host" ) ||  $redirect )
};

declare 
  %rest:GET
  %rest:path ( "/zapolnititul/forms/u/{ $page }" )
function user:form ( $page ) {
   web:redirect ( "/zapolnititul/forms/u" )
};