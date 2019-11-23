module namespace form = "http://dbx.iro37.ru/zapolnititul/forms/form";

import module namespace html =  "http://www.iro37.ru/xquery/lib/html";

import module namespace 
  config = "http://dbx.iro37.ru/zapolnititul/forms/u/config" at "../../config.xqm";
  
import module namespace 
  buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm" at "funct/buildForm.xqm";
  
import module namespace
  upload = "http://dbx.iro37.ru/zapolnititul/forms/upload" at "forms.Main.Upload.xqm";

declare 
  %public
function form:main ( 
  $id as xs:string,
  $formMeta as element( form ), 
  $formFields as element( csv ) 
) as element( div )* {
  let $currentFormID := $formMeta/@id/data()
  return
    (
     <div class="col-md-5 border-right">
       <h3>{ $formMeta/@label/data() }</h3>
       { form:header ( $currentFormID, $config:getFormByAPI ) }
       { form:body ( $currentFormID, $formFields ) }
       {
         let $meta := (
           [ "fileName", "ZapolniTitul.docx" ],
           [ "templatePath", $config:apiurl( $currentFormID, "template" ) ],
           [ "templateID", $formMeta/@id/data() ],
           [ "type", $formFields/record[ ID/text() = "__ОПИСАНИЕ__" ]/type/text() ],
           [ "redirect", "/zapolnititul/forms/u/form/" || $currentFormID ],
           [ "saveRedirect", "/zapolnititul/forms/u/data/" || $currentFormID ]
         )
         let $buttons := (
           map{
             "method" : "POST",
             "action" : "/zapolnititul/api/v1/document",
             "class" : "btn btn-success btn-block",
             "label" : "Скачать заполненный шаблон"},
            map{
             "method" : "POST",
             "action" : "/zapolnititul/api/v2/data/save",
             "class" : "btn btn-info btn-block",
             "label" : "Сохранить введенные данные"}
           
         )
         return
          form:footer( "template", $meta, "_t24_", $buttons )
       }
     </div>,
     <div class="col-md-4">
       <h3>Загрузить шаблон</h3>
       {
         upload:main( "yes", $id, $config:param( "host" ) || "/zapolnititul/forms/u/complete/" )
       }
       {
         let $meta := (
           [ "redirect", "/zapolnititul/forms/u/form/" ]
         )
         let $buttons := (
           map{
             "method" : "POST",
             "action" : "/zapolnititul/api/v2/forms/post/" || $currentFormID,
             "class" : "btn btn-success btn-block",
             "label" : "Обновить форму"},
            map{
             "method" : "POST",
             "action" : "/zapolnititul/api/v2/forms/post/create",
             "class" : "btn btn-info btn-block",
             "label" : "Создать новую форму"}
         )
         return
          (
            form:footer( "upload", $meta, "", $buttons ),
            <div>
              <a class="btn btn-info btn-block" href="{ '/zapolnititul/forms/u/child/' || $currentFormID }">Создать дочернюю форму</a>
            </div>
          )
       }
     </div>
   )
};

declare function form:body ( 
  $formID as xs:string, 
  $formFields as element( csv ) 
) as element( div ) {
        buildForm:buildInputForm ( 
          $formFields, 
          map{ 
            "id" : $formID, 
            "method" : "POST", 
            "action" : "/zapolnititul/api/v1/document" }
       )
};

declare 
  %public
function 
  form:header(
    $formID as xs:string, 
    $getFormByAPI
  ) as element( div )
{
   let $formMeta := $getFormByAPI( $formID, "meta" )/form
   let $formLabel := 
     if ( $formMeta/@label/data() )
     then ( $formMeta/@label/data() )
     else ( "Шаблон без названия" )
   let $templatePath := 
     "http://localhostupdate:output/zapolnititul/api/v2/forms/" || $formID || "/template"
   return
       <div class="row">
         <ul class="nav">
           <li class="nav-item">
              <a class="nav-link" href="{ $config:apiurl( $formID, 'template' ) }">Шаблон</a>
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
           <li class="nav-item">
             {
             <a class="nav-link" href="/zapolnititul/forms/a/form/{ $formID } " target="_blank">
               Cсылка на форму
             </a>
             }
             </li>
             <li class="nav-item">
             <div class="d-inline">
               <button class="js-textareacopybtn btn btn-info" style="vertical-align:top;">
               Копировать ссылку
               </button>
               <textarea style="width:0px; height:0px;" class="js-copytextarea" disable="yes">{ $config:param('host')}/zapolnititul/forms/a/form/{ $formID }</textarea>
             </div>
           </li>
           <script src="/static/titul24/copy-paste.js"></script>
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
        <input form="{ $formID }" type="hidden" name="{ $metaPrefix || $i?1 }" value="{ $i?2 }"/> 
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