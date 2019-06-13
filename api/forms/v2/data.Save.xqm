module namespace dataSave = "http://dbx.iro37.ru/zapolnititul/api/form/data/save";

import module namespace request = "http://exquery.org/ns/request";
import module namespace session = "http://basex.org/modules/session";

import module namespace 
    config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../../config.xqm";

(:~  
  !!! Это костыль: в фукнции dataSave:main( $redirect ) 
  не удается открыть базу db:open()
:)
declare
  %updating
  %rest:path ( "/zapolnititul/api/v2/data/update" )
  %rest:POST
  %rest:form-param ( "data", "{ $data }" )
function dataSave:update( $data ){
  let $d := parse-xml( $data )/table
  let $db := db:open("titul24", "data" )/data
  return
    (
      insert node  $d into $db,
      db:output( <insert>{ $d }</insert> )
    )
};

declare
  %rest:path ( "/zapolnititul/api/v2/data/save" )
  %rest:POST
  %rest:form-param ( "_t24_templateID", "{ $templateID }", "" )
  %rest:form-param ( "_t24_id", "{ $id }", "" )
  %rest:form-param ( "_t24_type", "{ $aboutType }", "none" )
  %rest:form-param ( "_t24_action", "{ $action }", "add" )
  %rest:form-param ( "_t24_saveRedirect", "{ $redirect }", "/" )
function dataSave:main( $templateID, $id, $aboutType, $action, $redirect ){
    let $paramNames := 
      for $name in  distinct-values( request:parameter-names() )
      where not ( starts-with( $name, "_t24_" ) )
      return $name
    let $modelURL := 
      if( substring( $aboutType, 1, 7 ) = "http://" )
      then(
        $aboutType
      )
      else(
        web:create-url( "http://localhost:8984/trac/api/Model/ood", map{ "id" : $aboutType } )
      )
       
    let $currentID := 
      if ( $action = "add" )
      then ( random:uuid() )
      else ( $id )
    
    let $record :=
      <table
        id="{ $currentID }"
        aboutType="{ $aboutType }" 
        templateID="{ $templateID }" 
        userID="{ session:get( 'userid' ) }" 
        modelURL="{  $modelURL }">
        <row>
          (: добавляет поля текстовые :)
          {
            for $param in $paramNames
            let $paramValue := request:parameter( $param )[1] (: если одинаковые параметры, то берет значение только первого :)
            where not ( $paramValue instance of map(*)  ) and $paramValue
            return
                <cell label="{ $param }">{ $paramValue }</cell>
          }
          
          (: добавляет поля-файлы :)
          {
            for $param in $paramNames
            let $paramValue := request:parameter( $param )
            where
              ( $paramValue instance of map(*)  ) and 
              not (
                string( map:get( $paramValue, map:keys( $paramValue )[1] ) ) = ""
              ) 
            return
                <cell label="{ $param }"> 
                  { map:get( $paramValue, map:keys( $paramValue )[1] )  }
                </cell>  
          }
        </row>
      </table>
    
   let $record := 
     if( not( $paramNames = "id" ) )
     then(
       $record update 
       insert node dataSave:buildIDRecord( $templateID, $currentID, . ) 
       into ./row
     )
     else(
       $record
     )
       
    let $model :=
        try{
          fetch:xml ( $modelURL )/table
        }
        catch*{ <table/> }
        
    let $request :=
        <http:request method='POST'>
          <http:multipart media-type = "multipart/form-data" >
              <http:header name="Content-Disposition" value= 'form-data; name="data";'/>
              <http:body media-type = "application/xml" >
                { $record }
              </http:body>
              <http:header name="Content-Disposition" value= 'form-data; name="model";'/>
              <http:body media-type = "application/xml" >
                { $model }
              </http:body>
          </http:multipart> 
        </http:request>
  
  let $response := 
    http:send-request(
      $request,
      'http://localhost:8984/xlsx/api/v1/trci/bind/meta'
    )[2]
  
  let $dbUpdate := 
     http:send-request(
           <http:request method='POST'>
              <http:multipart media-type = "multipart/form-data" >
                  <http:header name="Content-Disposition" value= 'form-data; name="data";'/>
                  <http:body media-type = "application/xml" >
                    { $response }
                  </http:body>
              </http:multipart> 
            </http:request>,
            "http://localhost:8984/zapolnititul/api/v2/data/update" 
        )
  return
     web:redirect( $redirect )
};

declare 
  %private
function dataSave:buildIDRecord( 
  $templateID, 
  $currentID, 
  $record as element( table )
) as element( cell )
{
  let $queryPath := 
      $config:apiResult( $templateID, "fields" )/child::*/record[ ID="__ОПИСАНИЕ__" ]/idQueryPath/text()
  return
    if( $queryPath )
    then(
       let $queryString := 
          try{
            fetch:text( $queryPath )
          }
          catch*{}
       return
        <cell label="id">{
            dataSave:query( $queryString, $record )
        }</cell>
    )
    else(
      <cell id="id">{ $currentID }</cell>
    )
};

declare function dataSave:query( $queryString, $record ) as xs:string {
    let $query := 
      <query>
        <text>{
          '<result>{' || $queryString || '}</result>'
        }</text>
        <context>
          <xml>
            <userid>{ session:get( 'userid' ) }</userid>
            <username>{ session:get( 'username' ) }</username>
            { $record }
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
          'http://localhost:8984/rest'
      )[2]/result/text()
   return $response
};