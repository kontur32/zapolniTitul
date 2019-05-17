module namespace form = "http://dbx.iro37.ru/zapolnititul/forms/form";

import module namespace html =  "http://www.iro37.ru/xquery/lib/html";

import module namespace 
  config = "http://dbx.iro37.ru/zapolnititul/forms/u/config" at "../../config.xqm";
  
import module namespace 
  buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm" at "funct/buildForm.xqm";

declare function form:body ( 
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

declare function form:header ( $formID as xs:string, $getFormByAPI ) as element( div ) {
   let $formMeta := $getFormByAPI( $formID, "meta")/form
   let $formLabel := 
     if ( $formMeta/@label/data() )
     then ( $formMeta/@label/data() )
     else ( "Шаблон без названия" )
   let $templatePath := 
     "http://localhost:8984/zapolnititul/api/v2/forms/" || $formID || "/template"
   return
       <div class="row">
         <ul class="nav">
           <li class="nav-item">
              <a class="nav-link" href="{ $config:apiurl( $formID, 'template') }">Шаблон</a>
           </li>
           <li class="nav-item">
              { if ( $formMeta/@dataFullPath/data() )
               then (
                <a class="nav-link" href="{ $formMeta/@dataFullPath }">Данные</a>
               )
               else ( )
              }
           </li>
           <li class="nav-item">
              {
               if ( $formMeta/@imageFullPath/data() )
               then (
                 <a class="nav-link" href="#" data-toggle="modal" data-target="#myModal">
                   Изображение
                 </a>
               )
               else ( )
             }
           </li>
         </ul>
        { 
          html:fillHtmlTemplate( 
            serialize( doc( "src/modal.html" ) ),
            map{ "image" : <img width="100%" src="{ $formMeta/@imageFullPath }"/>}
          ) 
        }
       </div>
};

declare 
  %public
function form:footer(
    $formID as xs:string, 
    $meta as item()*,
    $metaPrefix as xs:string,
    $buttons as item()*
  ) as element(div) {
  <div class="form-group">
    {
      for $i in $meta
      return
        <input form="{ $formID }" type="hidden" name="{ '_t24_' || $i?1 }" value="{ $i?2 }"/> 
    }
    {
      for $b in $buttons
      return
        <button 
          form="{ $formID }" 
          type="submit" 
          formmethod="{ $b?method }"
          formaction="{ $b?action }"
          class="{ $b?class }">
             { $b?label }
         </button>
    }
  </div>
};