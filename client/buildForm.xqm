module namespace buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm";

declare function buildForm:buildInputForm ( $inputFormData, $templatePath ){  
  let $inputFormFields :=
     for $field in $inputFormData/csv/record
     return
       switch ( $field/inputType/text() ) 
       case ( "text" )
         return
           <div class="form-group">
             <label>{ $field/label/text() }</label>
             <input class="form-control" type="text"  name="{ $field/ID/text() }" value="{ $field/defaultValue/text() }"/>
           </div>
       case  ( "textarea" ) 
         return
           <div class="form-group">
             <label>{ $field/label/text() }</label>
             <textarea class="form-control" name="{ $field/ID/text() }">{ $field/defaultValue/text() }</textarea>
           </div>
       case ( "select" )
         return
             <div class="form-group">
               <label>{ $field/label/text() }</label> 
               <select class="form-control" name="{ $field/ID/text() }">
                 {
                    let $items := 
                         csv:parse ( 
                           fetch:text ( 
                             $field/itemsSourceURL/text() ),
                             map { 'header': true() }
                         )/csv/record/label
                   for $item in $items
                   return 
                     <option value="{ $item }">
                       {
                         $item/text()
                       }
                     </option>
                 }
               </select>
            </div>
       default return ""
 
  return
    <div class="form-group">
     <form method="GET" action="/zapolnititul/api/v1/document">
       { 
         $inputFormFields
       }
        <p>и нажмите </p>
        <input type="hidden" name="fileName" value="ZapolniTitul.docx"/>
        <input type="hidden" name="templatePath" value="{ $templatePath }"/>
        <input class="btn btn-info" type="submit" value="Скачать..."/>
     </form>
    </div>
 };