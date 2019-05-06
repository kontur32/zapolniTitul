module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config";

declare variable $config:param := function( $param ) {
   doc("config.xml")//param[ @id = $param ]/text()
};

declare variable $config:forms := function( ) {
   db:open( "titul24", "forms" )/forms
};

declare variable $config:form := function( $id ) {
    $config:forms()/form[ @id = $id ]
};

declare variable $config:formsList := function( $offset as xs:double, $limit as xs:double ) {
   db:open( "titul24", "forms" )/forms/form[ ( position() >= $offset + 1 ) and ( position() <=  $offset + $limit ) ]
};

declare variable $config:userForms := 
  function( $userid as xs:string, $offset as xs:double, $limit as xs:double ) {
   db:open( "titul24", "forms" )/forms/form[ @userid = $userid ] [ ( position() >= $offset + 1 ) and ( position() <=  $offset + $limit ) ]
};

declare variable $config:apiEndpoint := function ( $object, $method ){
  $config:param( "host" ) || "/zapolnititul/api/v2/forms/" || $object || "/" || $method
};

declare variable $config:apiResult := function( $object as xs:string, $method as xs:string ) {
  try {
    fetch:xml( 
      $config:apiEndpoint( $object, $method )
    )
  }
  catch* {
    <error>Не удалось получить данные</error>
  }
};