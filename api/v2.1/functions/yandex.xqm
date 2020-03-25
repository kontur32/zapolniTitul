module namespace yandex = "http://dbx.iro37.ru/zapolnititul/api/v2.1/resource/yandex";

declare function yandex:getResource(
  $category as xs:string,
  $type as xs:string,
  $path as xs:string,
  $token as xs:string
)
{
  switch ( $category )
  case 'коллекция'
    return 
      yandex:getDirList( $path, $token )
  default return
    yandex:getResourceFile( $path, $token )
};


declare function yandex:getResourceFile(
  $path as xs:string,
  $token as xs:string
)
{
  let $href :=
    try{
       http:send-request(
         <http:request method='GET'>
           <http:header name="Authorization" value="{ 'OAuth ' || $token }"/>
           <http:body media-type = "text" >              
            </http:body>
         </http:request>,
        'https://cloud-api.yandex.net:443/v1/disk/resources/download?path=disk:/' || $path || '&amp;fields=href'
          )[2]/*:json/*:href/text()
    }
    catch*{
      <error></error>
    }
    
  let $rawData := 
    if( $href/error )
    then(
      <Data></Data>
    )
    else ( fetch:binary( $href ) )
  return
    $rawData
};

declare function yandex:getDirList(
  $path as xs:string,
  $token as xs:string
)
{
  http:send-request(
     <http:request method='GET'>
       <http:header name="Authorization" value="{ 'OAuth ' || $token }"/>
       <http:body media-type = "text" >              
        </http:body>
     </http:request>,
    'https://cloud-api.yandex.net:443/v1/disk/resources?path=' || iri-to-uri( $path )
  )[2]
};