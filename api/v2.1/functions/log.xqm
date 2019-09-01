module namespace log = "http://dbx.iro37.ru/zapolnititul/api/v2.1/log/";

import module namespace config = "http://dbx.iro37.ru/zapolnititul/api/v2.1/config" at "../config.xqm";

declare 
  %public
function 
log:log( $path, $params ) as xs:boolean {
  log:writeLogRecord(
    $path,
    log:buildLogRecord( $params )
  )
};

declare 
  %private
function 
log:buildLogRecord( $param as item()* ) as xs:string {
  string-join( ( current-dateTime(), $param ), " : " )
};

declare 
  %private
function 
log:writeLogRecord( $path as xs:string, $record as xs:string* ) {
  let $fullPath :=
    file:base-dir() || "../" || $config:param( "logDir" ) || "/" || $path
  let $result := 
    try{
      ( file:append-text-lines( $fullPath, $record ), true() )
    }
    catch*{
      false()
    }
  return
    $result
};