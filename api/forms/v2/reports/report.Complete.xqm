module namespace reports = "http://dbx.iro37.ru/zapolnititul/api/user/data/DigitalDocument";

import module namespace request = "http://exquery.org/ns/request";
import module namespace data = "http://dbx.iro37.ru/zapolnititul/api/data" at "../../../data.xqm";

declare
  %private
  %rest:GET
  %rest:path ( "/zapolnititul/api/v2/users/{ $userID }/reports/{ $reportID }/complete" )
  %rest:query-param( "template", "{ $templateID }" )
  %rest:query-param( "inst", "{ $instID }", "" )
  (:
    Шаблон для одной записи
    http://localhost:8984/zapolnititul/api/v2/users/6/reports/9b4cbc2c-a0a4-4794-a5cf-96291a7ebb0e/complete?template=5cca0292-925c-46cc-befa-94904f273cbc&inst=43470160-e788-43f1-9a4d-0c34e8d3a405
    
    Шаблон с таблицей
    http://localhost:8984/zapolnititul/api/v2/users/6/reports/1afcc0d7-bf56-4bad-80ec-d3a2bda697ec/complete?template=5cca0292-925c-46cc-befa-94904f273cbc 
   :)
function 
  reports:getReportProperty(
    $userID as xs:string,
    $reportID as xs:string,
    $templateID as xs:string,
    $instID as xs:string
  )
{
  let $context as element( table )* :=
    if( $instID !="" )
    then( $data:userTemplateInstance( $userID, $templateID, $instID ) )
    else( $data:userTemplate( $userID, $templateID ) )
  
  let $queryString as xs:string := fetch:text( "http://localhost:8984/zapolnititul/api/v2/users/" || $userID || "/reports/" || $reportID || "/query" )
  
  let $template := fetch:binary(  "http://localhost:8984/zapolnititul/api/v2/users/" || $userID || "/reports/" || $reportID || "/template" )
  
  let $data :=  reports:query( $queryString, $context )
  
  let $templateFileName := 
    $context//cell[ @id = "https://schema.org/DigitalDocument" ]/table/row/@label/data()
  
  let $ContentDispositionValue := "attachment; filename=" || iri-to-uri( $templateFileName[1] )
  
  return
    (
      <rest:response>
        <http:response status="200">
          <http:header name="Content-Disposition" value="{ $ContentDispositionValue }" />
          <http:header name="Content-type" value="application/octet-stream"/>
        </http:response>
      </rest:response>,
      reports:fillTemplate ( $template, $data )
    )
};

declare function reports:query( $queryString as xs:string, $context as element()* ) as element( table ) {
    let $query := 
      <query>
        <text>{'<result>{'|| $queryString || '}</result>'}</text>
        <context>
          <xml>
            { $context }
          </xml>
        </context>
      </query>
    
     let $response := 
        http:send-request(
           <http:request method='POST'>
             <http:header/>
             <http:body media-type = "xml" >
                { $query }
              </http:body>
           </http:request>,
          'http://test:test@localhost:8984/rest'
      )
   return $response[ 2 ]/result/table
};

declare function reports:fillTemplate ( $template as xs:base64Binary, $data as element( table ) ) {
    let $request :=
      <http:request method='POST'>
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

 return
    http:send-request(
      $request,
      'http://localhost:8984/api/v1/ooxml/docx/template/complete'
    )[2]
};