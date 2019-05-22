module namespace data = "http://dbx.iro37.ru/zapolnititul/forms/data";

import module namespace 
  config = "http://dbx.iro37.ru/zapolnititul/forms/u/config" at "../../config.xqm";

import module namespace 
  buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm" at "funct/buildForm.xqm";

import module namespace
  form = "http://dbx.iro37.ru/zapolnititul/forms/form" at "forms.Main.Form.xqm";
  
declare 
  %public
function data:main( $formMeta, $userData, $currentDataInst ){
   <div class="row">
     <div class="col-md-6 border-right">
       <h3>Экземпляры:</h3>
       <p>{ $formMeta/@label/data() }</p>
       <div>
       {
         for $i in $userData[ @templateID = $formMeta/@id/data() ]
         return 
           <div>
             <a class="px-1" href="{ $config:param( 'host' ) || '/zapolnititul/api/v2/data/delete/' ||$formMeta/@id/data() || '/' || $i/@updated/data() }" onclick="return confirm( 'Удалить?' );">
                <img width="18" src="{ $config:param( 'iconDelete' ) }" alt="Удалить" />
             </a>
             <a href="{ '?datainst=' || web:encode-url( $i/@updated/data() ) }" >
               { $i/@updated/data() }
             </a>
           </div>
           
       }
       </div>
     </div>  
     <div class="col-md-6 border-right">
       <h3 class="my-3"> Экземлпяр:</h3>
       <p>{ $currentDataInst }</p>
       <div class="row">
       {
          let $currentDataSet  := 
            $userData[
              @templateID = $formMeta/@id/data() 
              and web:encode-url( @updated/data() ) = web:encode-url( $currentDataInst )
            ]
           return
              ( 
                data:currentInst( $currentDataSet )
              )
       }
       <div>
       {
         
       }
       </div>
       </div>
     </div>
  </div>
};


declare 
  %public
function data:currentInst( $currentDataSet ){
<div class="container">{
     if ( $currentDataSet )
     then (
       <table class="table-striped">
         <tr >
           <th class="text-center">Свойство</th>
           <th></th>
           <th class="text-center">Значение</th>
          </tr>
         {
           let $model := fetch:xml( web:decode-url( $currentDataSet/@modelURL/data() ) )/table/row
           for $i in $currentDataSet/row/cell
           return
             <tr>
               <td class="px-3">
               {
                 if (  $model/@id = $i/@id )
                 then(
                   $model[ @id = $i/@id ]/cell[ @id = "label" ]/text() 
                 )
                 else (
                   $i/@id/data()
                 )
               } 
               </td>
               <td>:</td>
               <td class="font-italic text-left px-3">{ $i/text()}</td>
              </tr>
       }</table> 
     )
     else(
       <div>
         <p>Сохраненных данных нет</p>
       </div>
     )
 }</div>
};

declare 
  %public
function data:currentInstForm( $currentDataSet ){
<div class="container">{
     if ( $currentDataSet )
     then (
       let $formFields := 
       <csv>
         {
           let $model := fetch:xml( web:decode-url( $currentDataSet/@modelURL/data() ) )/table/row
           for $i in $currentDataSet/row/cell
           return
             <record>
               <ID>
               {
                 if (  $model/@id = $i/@id )
                 then(
                   $model[ @id = $i/@id ]/cell[ @id = "label" ]/text() 
                 )
                 else (
                   $i/@id/data()
                 )
               } 
               </ID>
               <defaultValue>{ $i/text() }</defaultValue>
              </record>
       }</csv> 
       return
         <div>
           <div>{
             buildForm:buildInputForm ( 
              $formFields, 
              map{ 
                "method" : "POST", 
                "action" : "/zapolnititul/api/v1/document" }
             )
           }</div>
           <div>
               {
                 let $meta := (
                   [ "type", $currentDataSet/@aboutType/data() ],
                   [ "templateID", $currentDataSet/@templateID/data() ],
                   [ "action", "update" ],
                   [ "saveRedirect", "/zapolnititul/forms/u/data/" || $currentDataSet/@templateID/data() ]
                 )
                 let $buttons := (
                    map{
                     "method" : "POST",
                     "action" : "/zapolnititul/api/v2/data/save",
                     "class" : "btn btn-info btn-block",
                     "label" : "Сохранить изменения"}
                   
                 )
                 return
                  form:footer( "template", $meta, "_t24_", $buttons )
               }
           </div>
         </div> 
     )
     else(
       <div>
         <p>Сохраненных данных нет</p>
       </div>
     )
 }</div>
};