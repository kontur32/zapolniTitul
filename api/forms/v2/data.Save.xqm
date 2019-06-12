module namespace dataSave = "http://dbx.iro37.ru/zapolnititul/api/form/data/save";

import module namespace request = "http://exquery.org/ns/request";
import module namespace session = "http://basex.org/modules/session";

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
  %rest:form-param ( "_t24_id", "{ $id }", "" )
  %rest:form-param ( "_t24_inst", "{ $inst }", "" )
  %rest:form-param ( "_t24_action", "{ $action }", "add" )
  %rest:form-param ( "_t24_redirect", "{ $redirect }", "/" )
function dataSave:main( $id, $inst, $action, $redirect ){
    let $paramNames := 
      for $name in  distinct-values( request:parameter-names() )
      where not ( starts-with( $name, "_t24_" ) )
      return $name
    let $aboutType := 
      if( request:parameter( '_t24_type' ) ) then (  request:parameter( '_t24_type' ) ) else ( "none" )
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
    let $data :=
      <table
        id="{ $currentID }"
        aboutType="{ $aboutType }" 
        templateID="{ request:parameter( '_t24_templateID' ) }" 
        userID="{ session:get( 'userid' ) }" 
        modelURL="{  $modelURL }">
        <row>
        {
          for $param in $paramNames
          let $paramValue := request:parameter( $param )[1] (: если одинаковые параметры, то берет значение только первого :)
          where not ( $paramValue instance of map(*)  ) and $paramValue
          return
              <cell label="{ $param }">{ $paramValue }</cell>
        }
        {
          dataSave:id( request:parameter( '_t24_templateID' ) )
        }
        {
          <cell label="id1">{ 
                let $queryString := fetch:xml ( 'http://localhost:8984/zapolnititul/api/v2/forms/' || request:parameter( '_t24_templateID' ) || '/fields' )/child::*/record[ ID="__ОПИСАНИЕ__" ]/id/text()
                let $query := 
                  <query>
                    <text>{ '<result>{' || $queryString || '}</result>' }</text>
                    <context>
                      <xml>
                        <userid>{ session:get( 'userid' ) }</userid>
                        <username>{ session:get( 'username' ) }</username>
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
          }</cell>
        }
        {
          for $param in $paramNames
          let $paramValue := request:parameter( $param )
          where ( $paramValue instance of map(*)  ) and not (  string( map:get( $paramValue, map:keys( $paramValue )[1] ) ) = "" ) 
          return
              <cell label="{ $param }"> 
                { map:get( $paramValue, map:keys( $paramValue )[1] )  }
              </cell>  
        }
        </row>
      </table>
    
    let $model := fetch:xml ( $modelURL )/table
    let $request :=
        <http:request method='POST'>
          <http:multipart media-type = "multipart/form-data" >
              <http:header name="Content-Disposition" value= 'form-data; name="data";'/>
              <http:body media-type = "application/xml" >
                { $data }
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
     web:redirect( request:parameter( '_t24_saveRedirect' ) )
};

declare function dataSave:id( $templateID ){
    <cell label="id">{ 
        let $queryString := fetch:xml ( 'http://localhost:8984/zapolnititul/api/v2/forms/' || $templateID || '/fields' )/child::*/record[ ID="__ОПИСАНИЕ__" ]/id/text()
        let $query := 
          <query>
            <text>{ '<result>{' || $queryString || '}</result>' }</text>
            <context>
              <xml>
                <userid>{ session:get( 'userid' ) }</userid>
                <username>{ session:get( 'username' ) }</username>
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
  }</cell>
};