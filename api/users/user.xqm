module namespace user = "http://dbx.iro37.ru/zapolnititul/api/users/login";

import module namespace Session = "http://basex.org/modules/session";

declare 
  %private
  %rest:GET
  %rest:path ( "/zapolnititul/api/v1/users/login-check" )
  %rest:query-param( "username", "{ $username }", "")
  %rest:query-param( "password", "{ $password }", "")
function user:login ( $username, $password ){
  
    let $response := user:getToken( "http://localhost/subversum",  $username, $password )
    return
      ( Session:set( 'token', $response//token/text() ) ,
        Session:set( 'username', $username ),
        web:redirect( "http://localhost:8984/zapolnititul/v/forms/upload" )
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
      $response[2]
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