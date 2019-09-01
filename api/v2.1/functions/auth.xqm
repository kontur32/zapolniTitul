module namespace auth = "http://dbx.iro37.ru/zapolnititul/api/v2.1/funct/auth/";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/v2.1/config" at "../config.xqm";

declare function auth:userID( $token )
{
  let $request := 
  <http:request method='get'>
    <http:header name="Authorization" value= '{ $token }' />
  </http:request>
  
  let $response := 
      http:send-request(
        $request,
        $config:param( "JWTendpoit" ) || "/wp-json/wp/v2/users/me?context=edit"
    )
    return
      $response[ 2 ]/json/id/text()
};