module namespace data = "http://dbx.iro37.ru/zapolnititul/forms/data";


declare 
  %public
function data:main( $data ){
<div class="container">{
     if ( $data )
     then (
       <table class="table-striped">
         <tr >
           <th class="text-center">Свойство</th>
           <th></th>
           <th class="text-center">Значение</th>
          </tr>
         {
           let $model := fetch:xml( web:decode-url( $data/@modelURL/data() ) )/table/row
           for $i in $data/row/cell
           return
             <tr>
               <td class="px-3">
               { $model[ @id = $i/@id ]/cell[ @id = "label" ]/text() }
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