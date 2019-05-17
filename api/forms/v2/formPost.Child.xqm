module namespace formPostChild = "http://dbx.iro37.ru/zapolnititul/api/form/post/child";

import module namespace session = "http://basex.org/modules/session";
import module namespace request = "http://exquery.org/ns/request";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config" at "../../config.xqm";

import module namespace formPost = "http://dbx.iro37.ru/zapolnititul/api/form/post" at "formPost.xqm";


declare
  %updating
  %private 
  %rest:path ( "/zapolnititul/api/v2/forms/post/child" )
  %rest:POST
  %rest:form-param ( "_t24_parentID", "{ $parentID }", "" )
  %rest:form-param ( "_t24_label", "{ $label }", "" )
  %rest:form-param ( "data", "{ $data }" )
  %rest:form-param ( "template-image", "{ $template-image }" )
  %rest:form-param ( "_t24_redirect", "{ $redirect }", "/" )
  %output:method("xml")
function formPostChild:post( 
  $parentID,
  $label,
  $data,
  $template-image, 
  $redirect
) {
  let $paramsText :=
    for $param in request:parameter-names()
    let $paramValue := request:parameter( $param )
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
    formPostChild:trci( $paramsText, $paramsMap )
  
  let $d := 
      if( $data instance of map(*) ) 
      then(
        if ( map:keys( $data )[ 1 ] )
        then (
          formPost:request( 
            $data( map:keys( $data )[ 1 ] ), 
            "data", 
            "http://localhost:8984/xlsx/api/parse/raw-trci"
          )
        )
        else( )
      ) 
      else ( )

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
        {
          if ( $d )
          then (
            <data>{ $d }</data>
          )
          else ()
        }
      </form>
  return (
    insert node $formData into $config:forms(), 
    db:output( web:redirect( $redirect || $formID ) )
    )
};

declare
function formPostChild:trci( $paramsText, $paramsMap ) {
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