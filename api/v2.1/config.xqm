module namespace config = "http://dbx.iro37.ru/zapolnititul/api/v2.1/config";

declare variable $config:param := function( $param ) as xs:string{
   let $conf := doc( "config.xml" )/config/param[ @id = $param ]
   return
     if( $conf/text() )
     then( $conf/text() )
     else( "" )
};

declare
  %public
function config:usersData() as element( table )*{
  db:open( $config:param( 'dbName' ), 'data' )
  /data/table
};