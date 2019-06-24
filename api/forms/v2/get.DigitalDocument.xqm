module namespace dd = "http://dbx.iro37.ru/zapolnititul/api/user/data/DigitalDocument";

import module namespace session = "http://basex.org/modules/session";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../../config.xqm";

declare
  %private
  %rest:GET
  %rest:path ( "/zapolnititul/api/v2/users/{ $userID }/data/DigitalDocument/{ $digitalDocumentID}" )
function dd:get( $userID as xs:string, $digitalDocumentID as xs:string  ) {
  let $data :=
    $config:userData( $userID )//row[ @type = "https://schema.org/DigitalDocument" ]
      [ @id = $digitalDocumentID ]
  
  return 
    if ( session:get( "userid" ) = $userID )
    then(
      let $ContentDispositionValue := "attachment; filename=" || iri-to-uri( $data/@label/data() )
      return
         (
          <rest:response>
            <http:response status="200">
              <http:header name="Content-Disposition" value="{ $ContentDispositionValue }" />
              <http:header name="Content-type" value="application/octet-stream"/>
            </http:response>
          </rest:response>,
          xs:base64Binary( $data/cell[ @id = "content" ]/text() )
         )
        )
        else ( <error>Пользователь не опознан</error> ) 
};
