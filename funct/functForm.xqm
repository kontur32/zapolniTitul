module namespace form = "http://dbx.iro37.ru/zapolnititul/funct/form";

declare variable $form:pathFieldsAsCSV := 'http://localhost:8984/ooxml/api/v1/docx/fields';
declare variable $form:delimiter := "::";

declare 
  %public
function form:csvFromTemplate ( $template ) as element( csv ) {
  let $fields := form:fieldsAsString( $template, $form:pathFieldsAsCSV )
  return form:buildCSV( $fields )
};

declare function form:map ( $string ) {
    let $map := doc("../src/map.xml")
    return
      if ( $map/csv/record/label/text() = $string ) 
      then (
        $map/csv/record[ label/text() = $string ]/value/text()
      )
      else (
        $string
      )
  };

declare 
  %public
function form:buildCSV( $csv as element(csv) ) as element(csv) {
       element { "csv" } {
       for $record in $csv/record
       return
         element { "record" }{
           element { "ID" } {
             form:map( normalize-space( $record/entry[ 1 ]/text() ) )
           },
           for $entry in $record/entry[ position() > 1 ]/text()
           return
             let $a := tokenize( $entry, $form:delimiter )
             return 
               element { form:map( normalize-space( $a[ 1 ] ) ) } {
                 form:map( normalize-space( $a[ 2 ] ) )
               }
         }
    }
};

declare 
  %public
function form:fieldsAsString( $rowTpl, $pathFieldsAsCSV ) as element( csv ) {
  csv:parse (
   http:send-request(
    <http:request method='post'>
      <http:header name="Content-type" value="multipart/form-data; boundary=----7MA4YWxkTrZu0gW"/>
      <http:multipart media-type = "multipart/form-data" >
          <http:header name='Content-Disposition' value='form-data; name="template"'/>
          <http:body media-type ="application/octet-stream">{ $rowTpl }</http:body>
      </http:multipart>
    </http:request>,
    $pathFieldsAsCSV
    )[2],
    map { 'header': false(), 'separator' : ';' }
  )/csv
};