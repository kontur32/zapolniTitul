module namespace restDocx = "http://iro37.ru/xq/modules/docx/rest";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "config.xqm";

declare 
  %rest:path ( "/zapolnititul/api/v1/document" )
  %rest:method ( "POST" )
    (:
        %rest:form-param ( "_t24_templateID", "{ $templateID }" )
        %rest:form-param ( "_t24_fileName", "{ $fileName }", "ZapolniTitul.docx" )
        %rest:form-param ( "_t24_templatePath", "{ $templatePath }" )
    :)
function restDocx:document-POST( ) {

  let $templateID := request:parameter( "_t24_templateID" )
  let $templatePath := request:parameter( "_t24_templatePath" )
  let $outputFormat := request:parameter( "_t24_outputFormat" )
  
  let $fileName := 
    if( $outputFormat != 'pdf' )
    then( "ZapolniTitul.docx" )
    else( "ZapolniTitul.pdf" )
 
  let $template := 
    try {
      string( fetch:binary( iri-to-uri( $templatePath ) ) )
    } catch * { }
    
  let $templateData := 
    try {
      fetch:xml( "http://localhost:9984/zapolnititul/api/v2/forms/" || $templateID || "/data" )//row
    } catch * { <error>Данные формы не получены...</error> }
   
  let $templateFields := 
    try {
      fetch:xml( "http://localhost:9984/zapolnititul/api/v2/forms/" || $templateID || "/fields" )
    } catch * { <error>Поля формы не получены...</error> }
  
  let $data :=
    <table>
      <row id="fields">
      {
        for $param in request:parameter-names()
        let $paramValue := request:parameter( $param )
        where not ( $paramValue instance of map(*)  )
        let $fieldIndex := string( $templateFields//record[ID=$param][1]/index/text() )
        let $value :=
          if( $fieldIndex )
          then( $templateData[ cell [ @label = $fieldIndex ]/text() = request:parameter( $fieldIndex ) ]/cell[ @label = $param ]/text() )
          else( $paramValue )
          
        return
            <cell id="{ $param }" contentType = "field">{ replace( $value[ 1 ], '(<(/?[^>]+)>)', "" ) }</cell>
      }
      </row>
      <row id="pictures">
      {
        for $param in request:parameter-names()
        let $paramValue := request:parameter( $param )
        where (
          $paramValue instance of map(*) and 
          string( map:get( $paramValue, map:keys( $paramValue ) ) ) 
        )
        
        return
            <cell id="{ $param }" contentType = "img"> 
              { map:get( $paramValue, map:keys( $paramValue ) )  }
            </cell>  
      }
      </row>
    </table>     
    
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
   http:send-request (
      $request,
      'http://localhost:9984/api/v1/ooxml/docx/template/complete'
    )
    
  let $ContentDispositionValue := "attachment; filename=" || $fileName
  
  let $log := 
      let $p := 
            for $param in request:parameter-names()
            let $paramValue := request:parameter( $param )
            let $paramValue := 
              if( $paramValue instance of map(*)  )
              then( "map : " || map:keys( $paramValue ) )
              else( $paramValue[ 1 ] )
            order by $param
          return $param || " : " || $paramValue ||  '&#xd;&#xa;'
      return 
        file:write-text( $config:param( "logDir" ) || "document.log", ( string-join( $p ) || '&#xd;&#xa;' || serialize( $data ) ) )
  
  let $result := 
    if( $outputFormat != 'pdf' )
    then( $response[2] )
    else( restDocx:convertToPDF( $response[2] ) )
  
  return
    (
      <rest:response>
        <http:response status="200">
          <http:header name="Content-Disposition" value="{ $ContentDispositionValue }" />
          <http:header name="Content-type" value="application/octet-stream"/>
        </http:response>
      </rest:response>,
      $result
    )  
};

declare function restDocx:convertToPDF( $data ) as xs:base64Binary{ 
  let $fileName := 'titul24.docx'
  let $fileNamePDF := 'titul24.pdf'
  
  let $file := 
    file:write-binary(
      file:temp-dir() || $fileName,
      $data
    ) 
  
  let $command :=
    if( starts-with( file:temp-dir(), '/tmp/') )
    then(
        '/opt/libreoffice6.3/program/soffice'
    )
    else(
        'C:/Program Files/LibreOffice/program/soffice'
    )
  let $params := 
    (
      '--headless',
      '--convert-to',
      'pdf:writer_pdf_Export', 
      '--outdir',
      file:temp-dir(),
      file:temp-dir() || $fileName
    )
  let $result := proc:execute( $command, $params )
  let $file := file:read-binary( file:temp-dir() || $fileNamePDF )
  return
    $file
};