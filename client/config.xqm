module namespace config = "http://dbx.iro37.ru/zapolnititul/forms/u/config";

declare variable $config:param := function( $param ) {
   doc( "config.xml" )/config/param[ @id = $param ]/text()
};

declare variable $config:apiurl := function( $object, $method ) {
   $config:param( "host" ) || $config:param( "currentAPIEndpoint" ) || $object || "/" || $method
};

declare variable $config:getFormByAPI := function( $object, $method ) {
  let $path := $config:apiurl ( $object, $method )
  return
     try {
       fetch:xml( $path )
     }
     catch* { <error>Не удалось получить данные "{ $method }" для формы { $object } </error> }
};

declare variable $config:fetchUserData := function ( $userID, $cookie ){
  http:send-request(
    <http:request method='get'
       href='{ "http://localhost:9984/zapolnititul/api/v2/user/" || $userID ||"/data" }'>
      <http:header name="Cookie" value="{ 'JSESSIONID=' || $cookie }" />
    </http:request>
   )[2]
};

declare variable $config:fetchUserTemplateData := function ( $templateID, $userID, $cookie ){
  http:send-request(
    <http:request method='get'
       href='{ "http://localhost:9984/zapolnititul/api/v2/user/" || $userID ||"/data/templates/" || $templateID }'>
      <http:header name="Cookie" value="{ 'JSESSIONID=' || $cookie }" />
    </http:request>
   )[2]
};