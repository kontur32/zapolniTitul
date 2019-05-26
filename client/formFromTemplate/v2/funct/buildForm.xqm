module namespace buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm";

declare 
  %public
function buildForm:buildInputForm ( 
  $inputFormData as element( csv ), 
  $param as item()
){  
  buildForm:buildInputForm-main ( 
    $inputFormData, 
    $param?id, 
    $param?method,
    $param?action
  )
};


declare 
  %private
function buildForm:buildInputForm-main ( 
  $inputFormData as element( csv ), 
  $id as item()*, 
  $method as xs:string,
  $action as xs:string 
){  
  let $inputFormFields :=
     for $field in $inputFormData/record
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
             <input class="form-control" type="hidden"  name="{ $field/ID/text() }" value="{ $field/defaultValue/text() }" />
           </div>

       case ( "text" )
         return
           element { "div" } {
              attribute {"class"} { "form-group"},
              element { "label" } { $label },
              element { "input" } {
                attribute { "class" } { "form-control" },
                attribute { "type" } { "text" },
                attribute { "name" } { $field/ID/text() },
                attribute { "value" } { $field/defaultValue/text() },
                attribute { "placeholder" } { $field/placeholder/text() },
                if ( $field/disabled ) 
                then (
                   attribute { "disabled" } { "disabled" }
                ) else ()
              }
            } 
           
       case  ( "textarea" ) 
         return
           let $rows := 
             if ( $field/rows/text() )
             then ( $field/rows/text() )
             else ( 2 )
           return
           <div class="form-group">
             <label>{ $label }</label>
             <textarea class="form-control" name="{ $field/ID/text() }" rows="{ $rows }">{ $field/defaultValue/text() }</textarea>
           </div>
       case ( "select" )
         return
             <div class="form-group">
               <label>{ $label }</label> 
               <select class="form-control" name="{ $field/ID/text() }">
                 {
                  let $itemsQueryURL :=
                    if ( $inputFormData/csv/record[ ID = "__ОПИСАНИЕ__" ]/itemsSourceURL/text() = "true" and not ( $field/itemsSourceURL ) ) 
                    then (
                      "http://localhost:8984/zapolnititul/api/v1/forms/data/" 
                      || $id 
                      || "?f=" 
                      || $field/ID/text()
                    )
                    else ( $field/itemsSourceURL/text() )
                  
                  let $csvHeader := 
                    if ( $inputFormData/csv/record[ ID = "__ОПИСАНИЕ__" ]/itemsSourceURL/text() = "true" and not ( $field/itemsSourceURL ) ) 
                    then ( false() )
                    else ( true() )
                    
                  let $items := 
                    let $dataSource := 
                      try {
                         fetch:text( iri-to-uri( $itemsQueryURL ) )
                      }
                      catch * {
                        "<csv><record><label>(!) Ошибка: Источник данных для списка не доступен</label></record></csv>"
                      }
                      return
                      try{
                       csv:parse( 
                           $dataSource,
                           map { 'header': $csvHeader }
                       )/csv/record/child::*[ 1 or name()="label" ][ 1 ]
                     }
                     catch* { 
                       try {
                          fetch:xml("http://localhost:8984/zapolnititul/api/v2/forms/"|| $id|| "/data")/data/table/row/cell[ @label = $field/ID/text() ]
                       }
                       catch*{
                         <label>(!) Ошибка: Данные для списка пустые или недлежащего формата</label>
                       }
                      }
                  
                   for $item in $items
                   return 
                     <option value="{ $item/text() }">
                       {
                         $item/text()
                       }
                     </option>
                 }
               </select>
            </div>
       case ( "img" )
         return
           <div class="form-group">
             <label>{ $label }</label>
             <input class="form-control" type="file"  name="{ $field/ID/text() }" value="{ $field/defaultValue/text() }" accept="image/*"/>
           </div>
       default return ""
 
  return
    <div class="form-group">
     <form method="{ $method }" action="{ $action }" enctype="multipart/form-data" id="template">
       { 
         $inputFormFields
       }
     </form>
    </div>
 };