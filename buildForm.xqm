module namespace buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm";

declare function buildForm:buildInputForm ( $inputFormData, $templatePath ){  
  let $inputFormFields :=
     for $field in $inputFormData/csv/record
     return
       switch ( $field/inputType/text() ) 
       case ( "text" )
         return
           <div> 
             <label>
               <p>{ $field/label/text() }</p>
               <input type="text" size = "45" name="{ $field/ID/text() }" value="{ $field/defaultValue/text() }">{}</input>
             </label>
           </div>
       case  ( "textarea" ) 
         return
           <div>
             <label>
               <p>{ $field/label/text() }</p> 
               <textarea cols="45" name="{ $field/ID/text() }">{ $field/defaultValue/text() }</textarea>
             </label>
           </div>
       case ( "select" )
         return 
           <div>
              <label>
               <p>{ $field/label/text() }</p> 
               <select name="{ $field/ID/text() }">
                 {
                    let $items := 
                         csv:parse ( 
                           fetch:text ( 
                             $field/itemsSourceURL/text() ),
                             map { 'header': true() }
                         )/csv/record/label
                   for $item in $items
                   return 
                     <option value="{$item}">
                       {
                         $item/text()
                       }
                     </option>
                 }
               </select>
             </label>
           </div>
       default return ""
 
  return
     <form method="GET" action="/docx/api/заполниТитул.docx">
       { $inputFormFields }
        <p>и нажмите </p>
        <input type="hidden" size = "45" name="template" value="{ $templatePath }"/>
        <input class="btn btn-info" type="submit" value="Скачать..."/>
     </form>
 };