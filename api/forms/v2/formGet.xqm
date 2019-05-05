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
        return 
          let $fields := 
            if( $form/@parentid )
            then ( 
              getForm:fields( $id )
            )
            else ( $form/csv )
          return 
            (   $fields,  "application/xml" )
      case ( "meta" )
        return ( 
          element { "form" } { 
            $form/@id, $form/@label,
            $form/@parentid, 
            $form/@fileFullPath,
            $form/@fileFullName,
            $form/@imageFullPath,
            $form/@dataFullPath 
          },
          "application/xml" 
        )
      case ( "data" )
        return (  $form/data,  "application/xml" )
      case ( "prefilled" )
        return (  $form/prefilled,  "application/xml" )
      case ( "template" )
        return (
          if ( $form/@parentid )
          then ( getForm:parent( $form/@parentid/data(), $form/prefilled/table ) )
          else (
            file:read-binary( $form/@fileFullName/data() )
          ), 
          "application/octet-stream",
          <http:header name="Content-Disposition" value="attachment; filename=titul24.docx" />
          )
      case ( "template-image" )
        return ( 
          file:read-binary( $form/@imageFullName/data() ), 
          "image"
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

declare function getForm:parent( $formID, $data ){
    
    let $template := 
      string(
       fetch:binary( "http://localhost:8984/zapolnititul/api/v2/forms/" || $formID ||"/template")
      )
    let $request :=
    <http:request method='post'>
      <http:multipart media-type = "multipart/form-data" >
          <http:header name="Content-Disposition" value= 'form-data; name="template";'/>
          <http:body media-type = "application/octet-stream" >
            { $template }
          </http:body>
          <http:header name="Content-Disposition" value= 'form-data; name="data";'/>
          <http:body media-type = "application/xml">
            { $data }
          </http:body>
      </http:multipart> 
    </http:request>

  let $response := 
    http:send-request(
      $request,
      'http://localhost:8984/api/v1/ooxml/docx/template/complete'
  )
  return
      $response[2]
};

declare function getForm:fields( $id ) {
  let $parentid := fetch:xml("http://localhost:8984/zapolnititul/api/v2/forms/"|| $id ||"/meta")/form/@parentid/data()
  let $r := fetch:xml("http://localhost:8984/zapolnititul/api/v2/forms/" || $parentid || "/fields")
  let $p := fetch:xml("http://localhost:8984/zapolnititul/api/v2/forms/"|| $id ||"/prefilled")/prefilled/table/row[ @id = "fields" ]
  return
    <csv>
    {
      for $i in $r/csv/record
      return
       if( $p//cell/@id = $i/ID )
       then ( 
         ( 
           if ( $i/defaultValue )
           then (
             $i update replace node ./defaultValue with ( <defaultValue>{ $p//cell[ @id = $i/ID ]/text() }</defaultValue>, <disabled>disabled</disabled> )
           ) 
           else (
             $i update insert node ( <defaultValue>{$p//cell[ @id = $i/ID ]/text()}</defaultValue>, <disabled>disabled</disabled>) into .
           )
           
         )
       )
       else ( $i )
    }
    </csv>
};