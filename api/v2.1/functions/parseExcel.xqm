module namespace parseExcel = "http://dbx.iro37.ru/zapolnititul/api/v2.1/parse/excel/XML";

declare default element namespace  "urn:schemas-microsoft-com:office:spreadsheet";
declare namespace ss="urn:schemas-microsoft-com:office:spreadsheet";

declare function parseExcel:parseWorksheetToTRCI( $Worksheet ){
  let $заголовки := $Worksheet/Table/Row[ 1 ]/Cell/Data/text()
  let $rows := 
    for $row in $Worksheet/Table/Row[ position() > 1 ]
    return
      element { QName( '', 'row' ) } {
        for $cell in $row/Cell
        count $count
        return
          element { QName( '', 'cell' ) }{
            attribute {'label'} { $заголовки[ $count ] },
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

declare function parseExcel:parseBookToTRCI( $Book ){
  element{ QName( '', 'data' ) }{
    for $Worksheet in $Book//Worksheet
    return
      parseExcel:parseWorksheetToTRCI( $Worksheet )
  }  
};