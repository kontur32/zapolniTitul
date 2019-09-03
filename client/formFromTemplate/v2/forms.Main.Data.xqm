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
       <div>{
         let $formID := $formMeta/@id/data()
         let $formType := $config:getFormByAPI( $formID, "fields" )//record[ ID = "__ОПИСАНИЕ__" ]/type/text()
         return 
           if( $formType = "property" )
           then(
             <div>{<a href='{ "/zapolnititul/api/v2/user/" || session:get( "userid" ) || "/models/" || $formMeta/@id }'>Ссылка на модель</a> }</div>
           )
           else()
       }</div>
       <div>{ data:listOfInstance( $formMeta/@id, $userData ) }</div>
       <div>{
         <a href='{ "/zapolnititul/api/v2/user/" || session:get( "userid" ) || "/data/templates/" || $formMeta/@id }'>Данные</a>
       }</div>
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
     let $templateFields := $config:getFormByAPI( $currentDataSet/@templateID/data(), "fields" )
     let $model := fetch:xml( web:decode-url( $currentDataSet/@modelURL/data() ) )/table/row
     return
     if ( $currentDataSet )
     then (
(:------------- новая версия ---------------------:)
        let $formFields :=
          <csv/> update insert node
          (
            for $i in $templateFields/csv/record
            let $id := $i/ID/text()
            
            return 
                $i update 
                  insert node
                    (
                      <defaultValue>
                        {  $currentDataSet/row/cell[ @id = $id ]/text() }
                      </defaultValue>, 
                      if( $id = "https://schema.org/DigitalDocument" or $currentDataSet/row/cell[ @id = $id ]/table/row/@id/data() or 1 )
                      then(
                        <link>
                        {
                           "/zapolnititul/api/v2/users/" || $currentDataSet/@userID/data() || "/data/DigitalDocument/" || $currentDataSet/row/cell[ @id = $id ]/table/row/@id/data()
                        }
                        </link>
                      )
                      else(
                         (: костыль из-за проблем с выводом $ :)
                         <defaultValue>
                           {
                              replace( $currentDataSet/row/cell[ @id = $id ]/table/row/cell/text(), "\$", "-" )
                           }
                         </defaultValue>
                      )
                    )
                  into . ,
            <record>
              <ID>id</ID>
              <label>id</label>
              <inputType>hidden</inputType>
              <defaultValue>{ $currentDataSet/row/cell[ @id = "id" ]/text() }</defaultValue>
            </record>
          ) 
          into .
        (:-------- конец новой версии -------------------:)   
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
             <dt>
               <a href="{
                     web:create-url( '',
                       map{
                         'dataver' : web:encode-url(  $data[@id=$v][last()]/@updated/data() ),
                         'datainst' :  $data[@id=$v][last()]/@id/data()
                       }
                     )
                     }">Экземпляр: {  $data[@id=$v][last()]/@label/data() }
                 </a>
              </dt>
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