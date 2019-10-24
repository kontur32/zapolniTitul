module namespace dataPost = "http://dbx.iro37.ru/zapolnititul/api/form/data/save";

import module namespace request = "http://exquery.org/ns/request";
import module namespace session = "http://basex.org/modules/session";

import module namespace 
    config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../../../config.xqm";

(:~  
  !!! Это костыль: в фукнции dataSave:main( $redirect ) 
  не удается открыть базу db:open()
:)
declare
  %updating
  %rest:path ( "/zapolnititul/api/v2/data/update" )
  %rest:POST
  %rest:form-param ( "data", "{ $data }" )
function dataPost:update( $data ){
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
function dataPost:main( $templateID, $id, $aboutType, $action, $redirect ){
    let $paramNames := 
      for $name in  distinct-values( request:parameter-names() )
      where not ( starts-with( $name, "_t24_" ) )
      return $name
    
    let $templateABOUT := $config:templateABOUT( $templateID )
    
    let $modelURL := 
      if( $templateABOUT/modelURL/text() )
      then(
        $templateABOUT/modelURL/text()
      )
      else(
        "http://localhost:8984/zapolnititul/api/v2/forms/" || $templateID || "/model"
      )
       
    let $currentID := 
      if ( $action = "add" )
      then ( random:uuid() )
      else ( $id )
    
    let $record :=
      <table
        id = "{ $currentID }"
        aboutType="{ $aboutType }" 
        templateID="{ $templateID }" 
        userID="{ session:get( 'userid' ) }" 
        modelURL="{  $modelURL }"
        status="active">
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
                  <table>
                    <row id="{ random:uuid() }" label="{ map:keys( $paramValue )[1] }" type="https://schema.org/DigitalDocument">
                      <cell id="content">
                        { xs:string( map:get( $paramValue, map:keys( $paramValue )[1] ) )  }
                      </cell>
                    </row>
                  </table> 
                </cell>  
          }
        </row>
      </table>
    
   let $record := 
     if ( not ( $paramNames = "id" ) )
     then(
       let $recordID :=
         if( $templateABOUT/idQueryURL/text() )
         then(
           let $queryString :=
             try{  
               fetch:text(
                 iri-to-uri( $templateABOUT/idQueryURL/text() )
               )
             } catch*{ false() }
           return
             if( $queryString )
             then( dataPost:query( $queryString,  $record ) )
             else( false() )
         )
         else( false() )
                               
       return 
         $record update 
         insert node <cell label="id">{
           if( $recordID )then( $recordID )else( $templateID )
         }</cell> into ./row
     )
     else(
       $record
     )
    
    let $record := 
      let $recordLabel := 
        let $queryString :=
          if( $templateABOUT/labelQueryURL/text() )
          then(
            try{  
               fetch:text(
                 iri-to-uri( $templateABOUT/labelQueryURL/text() )
               )
             } catch*{ false() } 
          )
          else( false() )
                 
         return
           if( $queryString )
           then( dataPost:query( $queryString,  $record ) )
           else( $record/row/cell[ @label = "id" ]/text() )
       return
         $record update insert node attribute { "label" } { if( $recordLabel )then( $recordLabel )else( ./row/cell[ @label = "id" ]/text() ) } into .
    
       
    let $model := try{ fetch:xml ( $modelURL )/table } catch*{ <table/> }
        
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
              <http:multipart media-type = "multipart/form-data">
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

declare function dataPost:query( $queryString, $record )  {
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
          'http://test:test@localhost:8984/rest'
      )[2]/result/text()
   return $response
};