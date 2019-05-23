module namespace data = "http://dbx.iro37.ru/zapolnititul/forms/data";

import module namespace 
  config = "http://dbx.iro37.ru/zapolnititul/forms/u/config" at "../../config.xqm";

import module namespace 
  buildForm = "http://dbx.iro37.ru/zapolnititul/buildForm" at "funct/buildForm.xqm";

import module namespace
  form = "http://dbx.iro37.ru/zapolnititul/forms/form" at "forms.Main.Form.xqm";
  
declare 
  %public
function data:main( $formMeta, $userData, $currentDataInst, $currentDataVer ){
   <div class="row">
     <div class="col-md-6 border-right">
       <h3>Экземпляры формы:</h3>
       <h4>{ '"' || $formMeta/@label/data() || '"'}</h4>
       <dl>
       {
         let $data := $userData[ @templateID = $formMeta/@id/data() ]
         let $instList := distinct-values( $data/@id/data() )
         for $v in $instList
         return
           <div>
             <dt>Экземпляр: {$v}</dt>
             <div class="ml-2">
             {
               for $i in $data[ @id = $v ]
               count $c
               return 
                 <dd>
                   <a class="px-1" href="{ $config:param( 'host' ) || '/zapolnititul/api/v2/data/delete/' ||$formMeta/@id/data() || '/' || $i/@updated/data() }" onclick="return confirm( 'Удалить?' );">
                      <img width="18" src="{ $config:param( 'iconDelete' ) }" alt="Удалить" />
                   </a>
                   <a href="{
                     web:create-url( '',
                       map{
                         'dataver' : web:encode-url( $i/@updated/data() ),
                         'datainst' : $i/@id/data()
                       }
                     )
                     }" >
                     Версия: { $c }
                   </a>
                 </dd>
                   }</div>
                 </div>
       }
       </dl>
     </div>  
     <div class="col-md-6">
       <div class="my-1">Версия от: { substring-before( web:decode-url( $currentDataVer ),"+" )}</div>
       <div></div>
       <div>Экземпляра: { $currentDataInst }</div>
       <div class="row">
       {
          let $currentDataSet  := 
            $userData[
              @templateID = $formMeta/@id/data() and
              @id = $currentDataInst and
              web:encode-url( @updated/data() ) =  $currentDataVer 
            ]
           return
              ( 
                data:currentInstForm( $currentDataSet )
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
                "action" : "/zapolnititul/api/v1/document"
              }
             )
           }</div>
           <div>
               {
                 let $meta := (
                   [ "type", $currentDataSet/@aboutType/data() ],
                   [ "templateID", $currentDataSet/@templateID/data() ],
                   [ "id",  $currentDataSet/@id/data() ],
                   [ "inst",  $currentDataSet/@updated/data() ],
                   [ "action", "update" ],
                   [ "saveRedirect", 
                     web:create-url(
                       "/zapolnititul/forms/u/data/" || 
                       $currentDataSet/@templateID/data(),
                       map{ "datainst" : $currentDataSet/@updated/data() }
                     )
                   ]
                 )
                 let $buttons := (
                    map{
                     "method" : "POST",
                     "action" : "/zapolnititul/api/v2/data/save",
                     "class" : "btn btn-info btn-block",
                     "label" : "Сохранить новую версию"}
                   
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