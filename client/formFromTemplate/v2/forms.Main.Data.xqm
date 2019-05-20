module namespace data = "http://dbx.iro37.ru/zapolnititul/forms/data";


declare 
  %public
function data:main( $currentDataSet ){
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