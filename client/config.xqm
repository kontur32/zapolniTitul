module namespace config = "http://dbx.iro37.ru/zapolnititul/forms/u/config";

declare variable $config:param := function( $param ) {
   doc( "config.xml" )/config/param[ @id = $param ]/text()
};

declare variable $config:apiurl := function( $object, $method ) {
   $config:param( "host" ) || "/zapolnititul/api/v2/forms/" || $object || "/" || $method
};