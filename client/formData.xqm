module namespace formData = "http://dbx.iro37.ru/zapolnititul/formData";

declare function formData:getFormData ( $rootPath, $path, $formID ) {
  let $formsPath := formData:formPath ( $rootPath, $path )
  let $formDataCSV := 
    try {
      fetch:text( $formsPath )
    }
    catch* { 
      "Ошибка: не удалось получить данные о форме по адресу: " || $formsPath
    }
  let $formData :=  
    try {
     csv:parse( $formDataCSV, map { 'header': true() } ) 
    }
    catch * {
      "Ошибка: не удалось отпарсить данные о форме из файла: " || $formDataCSV
    }
    return 
      $formData/csv/record[ formID = $formID ]
}; 

declare function formData:formPath ( $dataURL, $path ) {
  let $data := 
      csv:parse ( fetch:text ( $dataURL ), map { 'header': true() } )
  return
    if ( substring-before ( $path, "/") )
    then (
      let $domain := substring-before ( $path, "/")
      return 
         formData:formPath ( 
           $data/csv/record[ fn:normalize-space ( ID ) = $domain ]/URL/text(),
           substring-after ( $path, "/" )
         )
    )
    else (
         $data/csv/record[ fn:normalize-space ( ID ) = $path ]/URL/text()
    )
};