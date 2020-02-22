module namespace excel = "http://dbx.iro37.ru/zapolnititul/api/v2.1/parse/excel/XML";

declare default element namespace  "urn:schemas-microsoft-com:office:spreadsheet";
declare namespace ss="urn:schemas-microsoft-com:office:spreadsheet";

declare function excel:XMLWorksheetToTRCI( $Worksheet ){
  let $заголовки := $Worksheet/Table/Row[ 1 ]/Cell/Data/text()
  let $rows := 
    for $row in $Worksheet/Table/Row[ position() > 1 ]
    return
      element { QName( '', 'row' ) } {
        for $cell in $row/Cell
        count $count
        return
          element { QName( '', 'cell' ) }{
            attribute { 'label' } { $заголовки[ $count ] },
            $cell/Data/text()
          }
      }
  
  return
    element { QName( '', 'table' ) }{
      attribute { 'type' } { 'trci:parsed:model:validate' },
      attribute { 'label' } { $Worksheet/@ss:Name/data() },
      $rows
    }  
};

declare function excel:XMLToTRCI( $Book ){
  element{ QName( '', 'data' ) }{
    for $Worksheet in $Book//Worksheet
    return
      excel:XMLWorksheetToTRCI( $Worksheet )
  }  
};

declare function excel:xlsxToTRCI( $data ){
  let $request := 
    <http:request method='post'>
        <http:header name="Content-type" value="multipart/form-data; boundary=----7MA4YWxkTrZu0gW"/>
        <http:multipart media-type = "multipart/form-data" >
            <http:header name='Content-Disposition' value='form-data; name="data"'/>
            <http:body media-type = "application/octet-stream">
               { $data }
            </http:body>
        </http:multipart> 
      </http:request>
  
  let $response := 
      http:send-request(
        $request,
        "http://localhost:9984/xlsx/api/parse/raw-trci"
    )
    return
     $response[2]
};