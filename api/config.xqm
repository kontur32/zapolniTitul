module namespace config = "http://dbx.iro37.ru/zapolnititul/api/form/config";

declare variable $config:param := function( $param ) {
   doc("config.xml")//param[ @id = $param ]/text()
};