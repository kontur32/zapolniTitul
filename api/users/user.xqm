module namespace user = "http://dbx.iro37.ru/zapolnititul/api/users/login";

import module namespace session = "http://basex.org/modules/session";
import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../config.xqm";

declare 
  %private
  %rest:GET
  %rest:path ( "/zapolnititul/api/v1/users/login" )
  %rest:query-param( "username", "{ $username }", "")
  %rest:query-param( "password", "{ $password }", "")
  %rest:query-param( "callbackURL", "{ $callbackURL }", "/zapolnititul")
function user:login ( $username, $password, $callbackURL ){
    let $response := user:getToken( $config:param( "JWTEndpoint" ),  $username, $password )
    return
      if ( $response//token/text() )
      then (
        let $token := $response//token/text()
        let $userid := user:userIdJWT( $token )
        return
          (
           session:set( 'token', $token ),
           session:set( 'userid', $userid ),
           session:set( 'username', normalize-space( $username ) ),
           web:redirect( $callbackURL )
          )
      )
      else (
        web:redirect( $callbackURL )
      ) 
};

declare 
  %private
  %rest:GET
  %rest:path ( "/zapolnititul/api/v1/users/logout" )
  %rest:query-param( "callbackURL", "{ $callbackURL }", "")
function user:logout ( $callbackURL ){
  ( 
    session:close( ),
    web:redirect( $callbackURL )
  )
};


declare function user:getToken( $host, $username, $password )
{
  let $request := 
    <http:request method='post'>
        <http:multipart media-type = "multipart/form-data" >
            <http:header name="Content-Disposition" value= 'form-data; name="username";'/>
            <http:body media-type = "text/plain" >{ $username }</http:body>
            <http:header name="Content-Disposition" value= 'form-data; name="password";' />
            <http:body media-type = "text/plain">{ $password }</http:body>
        </http:multipart> 
      </http:request>
  
  let $response := 
      http:send-request(
        $request,
        $host || "/wp-json/jwt-auth/v1/token"
    )
    return
      if ( $response[1]/@status/data() = "200" )
      then(
        $response[2]
      )
      else()
};

declare function user:getData( $host, $token )
{
 let $request := 
  <http:request method='get'>
    <http:header name="Authorization" value= '{ "Bearer " || $token }' />
  </http:request>

  let $response := 
      http:send-request(
        $request,
        $host
    )
    return
      $response[2]
};

declare function user:userIdJWT( $token ) {
  let $t := function( $a ) { json:parse( convert:binary-to-string ( xs:base64Binary( $a ) ) ) }
  return
     $t( tokenize( $token, "\." )[2] )/json/data/user/id/text()
};