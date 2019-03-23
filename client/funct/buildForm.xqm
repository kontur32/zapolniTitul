module namespace buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm";

declare function buildForm:buildInputForm ( $inputFormData, $id, $templatePath ){  
  let $inputFormFields :=
     for $field in $inputFormData/csv/record
     where not ( $field/enable/text() = "false" )
       let $inputType := 
         if ( not( empty( $field/inputType/text() ) ) )
         then ( $field/inputType/text() )
         else ( "text" )
       let $label := 
         if ( not( empty( $field/label/text() ) ) )
         then ( $field/label/text() )
         else ( $field/ID/text() )
     return
       switch ( $inputType )
       case ( "hidden" )
         return 
           <div class="form-group">
             <input class="form-control" type="hidden"  name="{ $field/ID/text() }" value="{ $field/defaultValue/text() }"/>
           </div>
       case ( "text" )
         return
           <div class="form-group">
             <label>{ $label }</label>
             <input class="form-control" type="text"  name="{ $field/ID/text() }" value="{ $field/defaultValue/text() }"/>
           </div>
       case  ( "textarea" ) 
         return
           <div class="form-group">
             <label>{ $label }</label>
             <textarea class="form-control" name="{ $field/ID/text() }">{ $field/defaultValue/text() }</textarea>
           </div>
       case ( "select" )
         return
             <div class="form-group">
               <label>{ $label }</label> 
               <select class="form-control" name="{ $field/ID/text() }">
                 {
                  let $itemsQueryURL :=
                    if ( $inputFormData/csv/record[ID="__ОПИСАНИЕ__"]/itemsSourceURL/text()="true" and not ($field/itemsSourceURL) ) 
                    then (
                      "http://localhost:8984/zapolnititul/api/v1/forms/data/" 
                      || $id 
                      || "?f=" 
                      || $field/ID/text()
                    )
                    else ( $field/itemsSourceURL/text() )
                  
                  let $csvHeader := 
                    if ( $inputFormData/csv/record[ID="__ОПИСАНИЕ__"]/itemsSourceURL/text()="true" and not ($field/itemsSourceURL) ) 
                    then ( false() )
                    else ( true() )
                    
                  let $items := 
                       csv:parse ( 
                         fetch:text ( 
                           iri-to-uri( $itemsQueryURL ) ),
                           map { 'header': $csvHeader }
                       )/csv/record/child::*[ 1 or name()="label" ][ 1 ]
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