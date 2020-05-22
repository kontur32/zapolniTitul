module namespace config = "http://dbx.iro37.ru/zapolnititul/api/v2.1/config";

declare variable $config:param := function( $param ) as xs:string{
   let $conf := doc( "config.xml" )/config/param[ @id = $param ]
   return
     if( $conf/text() )
     then( $conf/text() )
     else( "" )
};