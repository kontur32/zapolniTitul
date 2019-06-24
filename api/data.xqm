module namespace data = "http://dbx.iro37.ru/zapolnititul/api/data";


declare variable $data:forms := function( ) {
   db:open( "titul24", "forms" )/forms
};

declare variable $data:form := function( $id ) {
    $data:forms()/form[ @id = $id ]
};

declare variable $data:userTemplate :=
  function(
    $userID as xs:string,
    $templateID as xs:string
  ) as element( table )*
{
  let $templateOwner := $data:form( $templateID )/@userid/data()
  let $data :=
    if( $userID = $templateOwner )
    then(
      db:open( "titul24", "data")/data/table[ @templateID = $templateID ]
    )
    else(
      db:open( "titul24", "data")/data/table[ @userID = $userID ][ @templateID = $templateID ]
    )
  let $instIDs := distinct-values( $data/@id/data() )
  return
    for $r in $instIDs
    return
      ( $data[ @id = $r ] )[ last() ]
};

declare variable $data:userTemplateInstance := 
  function(
    $userID as xs:string,
    $templateID as xs:string, 
    $instance as xs:string
  ) as element( table )*
{
  let $templateOwner := $data:form( $templateID )/@userid/data()
  let $data :=
    $data:userTemplate( $userID, $templateID )[ @id = $instance ]
  return
    $data
};