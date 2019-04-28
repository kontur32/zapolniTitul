module namespace getForm = "http://dbx.iro37.ru/zapolnititul/api/form/get";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../../config.xqm";

declare
  %private
  %rest:GET
  %rest:path ( "/zapolnititul/api/v2/forms/{ $id }/{ $component }" )
function getForm:get( $id as xs:string, $component as xs:string ) {
  let $form := $config:form( $id )
  return 
  if ( $form )
  then (
    let $result := 
      switch ( $component )
      case ( "fields" )
        return (  $form/csv,  "application/xml" )
      case ( "data" )
        return (  $form/data,  "application/xml" )
      case ( "template" )
        return ( 
          file:read-binary( $form/@fileFullName/data() ), 
          "application/octet-stream",
          <http:header name="Content-Disposition" value="attachment; filename=titul24.docx" />
        )
      default 
        return ( $form/csv,  "application/xml" )
  return 
    (
      <rest:response>
        <http:response status="200">
          { $result[3] }
          <http:header name="Content-type" value="{ $result[2] }"/>
        </http:response>
      </rest:response>,
      $result[1]
     )
   )
   else (
     <rest:response>
        <http:response status="404">
          <http:header name="Content-type" value="text/plain"/>
        </http:response>
      </rest:response>,
     "Форма не найдена"
   )
};