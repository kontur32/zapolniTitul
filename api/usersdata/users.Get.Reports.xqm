module namespace reports = "http://dbx.iro37.ru/zapolnititul/api/user/data/DigitalDocument";

import module namespace request = "http://exquery.org/ns/request";
import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../config.xqm";

declare
  %private
  %rest:GET
  %rest:path ( "/zapolnititul/api/v2/users/{ $userID }/reports" )
function 
  reports:userReportsList(
    $userID as xs:string
  ) as element( table )
{
  let $data :=
    $config:userData( $userID )//row[ @type = "http://schema.titul24.ru/Report" ]
  return 
      <table>
        {
          for $r in $data
          return 
            <row id = "{ $r/@id }">
              { $r/cell[ @id = "label" ] }
              <cell id="https://schema.org/url">
                {
                  request:scheme() || "://" || request:hostname() || ":" || request:port() ||
                  "/zapolnititul/api/v2/users/" || $userID || "/reports" ||
                  substring-after( $r/@id/data(), "#" )
                }
               </cell>
            </row>
        }
      </table>
};

declare
  %private
  %rest:GET
  %rest:path ( "/zapolnititul/api/v2/users/{ $userID }/reports/{ $reportID}" )
function 
  reports:getReport(
    $userID as xs:string,
    $reportID as xs:string 
  ) as element( table )
{
  let $data :=
    $config:userData( $userID )//row[ @type = "http://schema.titul24.ru/Report" ]
      [ @id = "http://titul24.ru/items/Reports#" || $reportID ]
  return 
      $data/parent::*
};

declare
  %private
  %rest:GET
  %rest:path ( "/zapolnititul/api/v2/users/{ $userID }/reports/{ $reportID }/{ $reportProperty }" )
function 
  reports:getReportProperty(
    $userID as xs:string,
    $reportID as xs:string,
    $reportProperty as xs:string 
  )
{
  let $data :=
    $config:userData( $userID )//row[ @type = "http://schema.titul24.ru/Report" ]
      [ @id = "http://titul24.ru/items/Reports#" || $reportID ]   
  let $result :=
     switch ( $reportProperty )
     case "label"
       return 
         (
          <rest:response>
            <http:response status="200">
              <http:header name="Content-Type" value="text/plain; charset=utf-8"/>
            </http:response>
          </rest:response>,
          normalize-unicode( $data/cell[ @id = "label" ]/text() )
         )
       
     case "query"
       return 
           (
            <rest:response>
              <http:response status="200">
                <http:header name="Content-Type" value="text/plain; charset=utf-8"/>
              </http:response>
            </rest:response>,
             normalize-unicode( $data/cell[ @id = "https://schema.org/query" ]/text() )
           )
     case "template"
       return
         let $templateFileName := 
           $data/cell[ @id = "https://schema.org/DigitalDocument" ]/table/row/@label/data()
         let $ContentDispositionValue := "attachment; filename=" || iri-to-uri( $templateFileName )
      return
         (
          <rest:response>
            <http:response status="200">
              <http:header name="Content-Disposition" value="{ $ContentDispositionValue }" />
              <http:header name="Content-type" value="application/octet-stream"/>
            </http:response>
          </rest:response>,
          xs:base64Binary( $data/cell[ @id = "https://schema.org/DigitalDocument" ]/table/row/cell[ @id="content" ]/text() )
         ) 
     default return ""
  return
    $result
};
