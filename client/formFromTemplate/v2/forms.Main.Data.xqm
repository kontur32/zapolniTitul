module namespace data = "http://dbx.iro37.ru/zapolnititul/forms/data";

import module namespace 
  config = "http://dbx.iro37.ru/zapolnititul/forms/u/config" at "../../config.xqm";

import module namespace
  form = "http://dbx.iro37.ru/zapolnititul/forms/form" at "forms.Main.Form.xqm";
  
declare 
  %public
function data:main( $formMeta, $userData, $currentDataInst, $currentDataVer ){
  (
     <div class="col-md-4 border-right">
       <h3>Экземпляры формы:</h3>
       <h4>{ '"' || $formMeta/@label/data() || '"'}</h4>
       <div>{ data:listOfInstance( $formMeta/@id, $userData ) }</div>
     </div>,  
     <div class="col-md">
       {
         data:currentVersionForm( $formMeta/@id, $currentDataInst, $currentDataVer, $userData )
       }
     </div>
  )
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
             form:body (
              $currentDataSet/@templateID, 
              $formFields
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
function data:currentInstView( $currentDataSet ){
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

declare function data:instanceLabel( $VersionData )
{
let $f := fetch:xml("http://localhost:8984/zapolnititul/api/v2/forms/" || $VersionData/@templateID ||  "/fields")/csv/record[ID="__ОПИСАНИЕ__"]/labelOfInstance/text()

let $fieldsNameList := tokenize($f, "--") => for-each( normalize-space( ? ) )

let $modelFields := fetch:xml( web:decode-url( $VersionData/@modelURL/data() ) )/table/row

let $fieldsIDList := 
  for $i in $fieldsNameList
   return
     $modelFields[cell[@id="label"]=$i]/@id/data()

return 
   string-join( 
     for $i in $fieldsIDList return $VersionData/row/cell[@id=$i]/text(), " "
   )
};

declare function data:listOfInstance( $currentFormID, $userData ){
  <dl>
       {
         let $data := $userData[ @templateID = $currentFormID ]
         let $instList := distinct-values( $data/@id/data() )
         for $v in $instList
         return
           <div>
             <dt>Экземпляр: {  data:instanceLabel( $data[@id=$v][last()] ) }</dt>
             <div class="ml-2">
             {
               for $i in $data[ @id = $v ]
               count $c
               return 
                 <dd>
                   <a class="float-right" href="{ $config:param( 'host' ) || '/zapolnititul/api/v2/data/delete/' ||$currentFormID || '/' || $i/@updated/data() }" onclick="return confirm( 'Удалить?' );">
                      <i class="fa fa-trash-alt"/>
                   </a>
                   <a href="{
                     web:create-url( '',
                       map{
                         'dataver' : web:encode-url( $i/@updated/data() ),
                         'datainst' : $i/@id/data()
                       }
                     )
                     }" >
                     Версия { $c } : { data:instanceLabel( $i )}
                   </a>
                 </dd>
                   }</div>
                 </div>
       }
       </dl>
};

declare function data:currentVersionForm( $currentFormID, $currentDataInst, $currentDataVer, $userData ){
       let $currentDataSet  := 
            $userData[
              @templateID = $currentFormID and
              @id = $currentDataInst and
              web:encode-url( @updated/data() ) = $currentDataVer 
            ]
       let $lastDataSet := 
         $userData[
              @templateID = $currentFormID and
              @id = $currentDataInst  
            ][ last() ]
           return
           <div>
             <div class="font-weight-bold my-1">{  data:instanceLabel( $currentDataSet ) }</div>
             <div>Версия от: { replace( substring-before( web:decode-url( $currentDataVer ),"." ), "T", " ") } </div>
             <div>Экземпляра: {  data:instanceLabel( $lastDataSet ) }</div>
             <div class="row">
             {
               data:currentInstForm( $currentDataSet )
             }
             </div>
           </div>      
};