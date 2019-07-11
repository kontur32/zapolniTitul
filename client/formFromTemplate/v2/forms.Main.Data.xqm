module namespace data = "http://dbx.iro37.ru/zapolnititul/forms/data";

import module namespace session = "http://basex.org/modules/session";

import module namespace 
  config = "http://dbx.iro37.ru/zapolnititul/forms/u/config" at "../../config.xqm";

import module namespace
  form = "http://dbx.iro37.ru/zapolnititul/forms/form" at "forms.Main.Form.xqm";
  
declare 
  %public
function data:main( $formMeta, $userData, $currentDataInst, $currentDataVer ){
  (
     <div class="col-md-4 border-right">
       <h3>Экземпляры данных:</h3>
       <h4>{ '"' || $formMeta/@label/data() || '"'}</h4>
       <div>{<a href='{ "/zapolnititul/api/v2/user/" || session:get( "userid" ) || "/models/" || $formMeta/@id }'>Ссылка на модель</a> }</div>
       <div>{<a href='{ "/zapolnititul/api/v2/user/" || session:get( "userid" ) || "/data/templates/" || $formMeta/@id }'>Ссылка на данные</a> }</div>
       <div>{ data:listOfInstance( $formMeta/@id, $userData ) }</div>
     </div>,
       
     <div class="col-md">
       {
         let $formID := $formMeta/@id/data()
         return
           data:currentVersionForm( $formID, $currentDataInst, $currentDataVer, $userData )
       }
     </div>
  )
};

declare 
  %public
function data:currentInstForm( $currentDataSet ){
<div class="container">
{
     if ( $currentDataSet )
     then (
       let $formFields := 
       <csv>
         {
           let $templateFields := $config:getFormByAPI( $currentDataSet/@templateID/data(), "fields" )
           let $model := fetch:xml( web:decode-url( $currentDataSet/@modelURL/data() ) )/table/row
           
           for $i in $currentDataSet/row/cell
           let $fieldLabel := $model[ @id = $i/@id ]/cell[ @id = "label" ]/text()
           
           return
             <record>
               <ID> {
                   if ( $fieldLabel )
                   then ( $fieldLabel )
                   else ( $i/@id/data() )
               } </ID>
               <label>
                 {
                   if ( $fieldLabel )
                   then ( $fieldLabel )
                   else ( $i/@id/data() )
                 }
               </label>
               {
                 if(
                   $templateFields//record[ ID/text() = $fieldLabel ]/inputType/text() = "hidden" or $i/@id/data() = "id"
                 )
                 then(
                   <inputType>hidden</inputType>
                 )
                 else()
               }
               {
                 if(  $model[ @id = $i/@id ]/cell[ @id = "id" ]/text() = "https://schema.org/DigitalDocument" )
                 then(
                   <inputType>file</inputType>,
                   <link>
                     {
                       "/zapolnititul/api/v2/users/" || $currentDataSet/@userID/data() || "/data/DigitalDocument/" || $i/table/row/@id/data()
                     }
                   </link>
                 )
                 else(
                   (: костыль из-за проблем с выводом $ :)
                   <defaultValue>
                     {
                       replace( $i/text(), "\$", "-" )
                     }
                   </defaultValue>
                 )
               }
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

declare function data:listOfInstance( $currentFormID, $userData ){
  <dl>
       {
         let $data := $userData[ @templateID = $currentFormID ]
         let $instList := distinct-values( $data/@id/data() )
         for $v in $instList
         return
           <div>
             <dt>Экземпляр: {  $data[@id=$v][last()]/@label/data() }</dt>
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
                     Версия { $c } : { $i/@label/data() }
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
             <div class="font-weight-bold my-1">{ $currentDataSet/@label/data() }</div>
             <div>Версия от: { replace( substring-before( web:decode-url( $currentDataVer ),"." ), "T", " ") } </div>
             <div>Экземпляр: {  $lastDataSet/@label/data() }</div>
             <div class="row">
             {
               data:currentInstForm( $currentDataSet )
             }
             </div>
           </div>      
};