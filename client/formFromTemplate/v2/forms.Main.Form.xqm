module namespace form = "http://dbx.iro37.ru/zapolnititul/forms/form";

import module namespace html =  "http://www.iro37.ru/xquery/lib/html";

import module namespace 
  buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm" at "../../funct/buildForm.xqm";

declare function form:form ( 
  $formMeta as element( form ), 
  $formFields as element( csv ) 
) as element( div ) {
   let $formID := $formMeta/@id/data() 
   return
        buildForm:buildInputForm ( 
          $formFields, 
          map{ 
            "id" : $formID, 
            "method" : "POST", 
            "action" : "/zapolnititul/api/v1/document" }
       )
};

declare function form:meta ( $formID as xs:string ) as element( div ) {
   let $formMeta := 
     try {
       fetch:xml( "http://localhost:8984/zapolnititul/api/v2/forms/" || $formID || "/meta" )/form
     }
     catch* { }
    
   let $formLabel := 
     if ( $formMeta/@label/data() )
     then ( $formMeta/@label/data() )
     else ( "Шаблон без названия" )
   let $templatePath := 
     "http://localhost:8984/zapolnititul/api/v2/forms/" || $formID || "/template"
   return
       <div class="row">
         <form class="ml-3 form-inline">
         <button type="submit" formaction="{ $templatePath }" class="btn btn-info mx-3">
           Шаблон
         </button>
          { if ( $formMeta/@dataFullPath/data() )
           then (
            <button type="submit" formaction="{ $formMeta/@dataFullPath }" class="btn btn-info">
               Данные
            </button>
           )
           else ( )
          }
         { if ( $formMeta/@imageFullPath/data() )
           then (
             <button type="button" class="btn btn-info mx-3" data-toggle="modal" data-target="#myModal">
               Изображение
             </button>
           )
           else ( )
         }
         </form>
        { 
          html:fillHtmlTemplate( 
            serialize( doc( "src/modal.html" ) ),
            map{ "image" : <img width="100%" src="{ $formMeta/@imageFullPath }"/>}
          ) 
        }
       </div>
};