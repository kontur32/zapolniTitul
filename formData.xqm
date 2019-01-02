module namespace formData = "http://dbx.iro37.ru/zapolnititul/formData";

declare function formData:getFormData ( $rootPath, $path, $formID ) {
  let $formsPath := formData:formPath ( $rootPath, $path )
  let $formData := csv:parse ( fetch:text ( $formsPath ), map { 'header': true() } )/csv/record[ formID = $formID ]
    return 
      $formData  
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