module namespace formPost = "http://dbx.iro37.ru/zapolnititul/api/form/post";

import module namespace session = "http://basex.org/modules/session";
import module namespace request = "http://exquery.org/ns/request";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../../config.xqm";


declare
  %updating
  %private 
  %rest:path ( "/zapolnititul/api/v2/forms/post/child" )
  %rest:POST
  %rest:form-param ( "_t24_parentID", "{ $parentID }", "" )
  %rest:form-param ( "_t24_label", "{ $label }", "" )
  %rest:form-param ( "redirect", "{ $redirect }", "/" )
  %output:method("xml")
function formPost:post( 
  $parentID,
  $label, 
  $redirect
) {
  let $paramsText :=
    for $param in request:parameter-names()
    let $paramValue := normalize-space ( request:parameter( $param ) )
    where not ( $paramValue instance of map(*) ) and not ( contains( $param, "_t24_" ) )
    return
      if ( $paramValue != "")
      then(
        map{ "name" : $param, "value" : $paramValue }
      )
      else ( )
      
  
  let $paramsMap :=
    for $param in request:parameter-names()
    let $paramValue := request:parameter( $param )
    where ( $paramValue instance of map(*)  )
    return
      map{ "name" : $param, "value" : map:get( $paramValue, map:keys( $paramValue )[1] ) }
        
  let $prefilled :=
    formPost:trci( $paramsText, $paramsMap )
  let $formID := random:uuid()
  let $formData := 
      <form 
        id = "{ $formID }"
        parentid = "{ $parentID }"
        userid = "{ session:get( 'userid' ) }"
        username = "{ session:get( 'username' ) }" 
        label = "{ $label }"
        timestamp = "{ string( current-dateTime() ) }">
        <prefilled>
          { $prefilled }
        </prefilled>
      </form>
  return (
    insert node $formData into $config:forms(), 
    db:output( web:redirect( "http://localhost:8984/zapolnititul/forms/u/form/" || $formID ) )
    )
};

declare
function formPost:trci( $paramsText, $paramsMap ) {
  <table>
      <row id="fields">
      {
        for $param in $paramsText
        return
            <cell id="{ $param?name }" contentType = "field">{ $param?value }</cell>

      }
      </row>
      {
      if( not ( empty( $paramsMap ) ) )
      then(
      <row id="pictures">
      {
        for $param in $paramsMap
        return
            <cell id="{ $param?name }" contentType = "img"> 
              { $param?value }
            </cell>  
      }
      </row>
      )
      else()
      }
    </table> 
};