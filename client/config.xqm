module namespace config = "http://dbx.iro37.ru/zapolnititul/forms/u/config";

declare variable $config:param := function( $param ) {
   doc( "config.xml" )/config/param[ @id = $param ]/text()
};