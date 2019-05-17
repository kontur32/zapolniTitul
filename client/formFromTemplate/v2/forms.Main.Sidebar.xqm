module namespace sidebar = "http://dbx.iro37.ru/zapolnititul/forms/sidebar";

declare function sidebar:userFormsList ( $userForms as element( form )*, $params as item() ) {
  let $result := 
   <div class="container">
           {
             for $f in $userForms
             let $href_upload := 
                $params( "uploadForm" ) || $f/@id/data()
             let $href_delete := 
               web:create-url( $params( "host") || $params( "deleteAPI" ) || $f/@id/data(), map{ "redirect" : '/zapolnititul/forms/u' } )
             return
             <div class="row">
               <div class="col">
                <a href="{ $href_upload }">
                  <img width="18" src="{ $params( 'iconUpload' ) }" alt="Обновить" />
                </a>
               
                <a class="px-1" href="{ $href_delete }" onclick="return confirm( 'Удалить?' );">
                  <img width="18" src="{ $params( 'iconDelete' ) }" alt="Удалить" />
                </a>
               
                <a href="/zapolnititul/forms/u/form/{ $f/@id/data() }" data-toggle="tooltip" data-placement="top" title="{ $f/@label/data() }">
                  <span class="d-inline-block text-truncate" style="max-width: 180px;">
                    { if( $f/@label/data() !="" ) then ( $f/@label/data() ) else ( "Без имени" ) }
                  </span>
                </a>
               </div>
              </div>
           }
         </div>
  return
    $result         
};

declare function sidebar:userDataList ( $userData as element( table )* ) {
  let $result := 
   <div class="container">
     <ul>
       {
         for $d in $userData
         let $formID := $d/@templateID/data()
         let $formLabel := fetch:xml("http://localhost:8984/zapolnititul/api/v2/forms/" || $formID || "/meta")/form/@label/data()
         return
           <li>
             <a href="{ $formID }">{ $formLabel }</a>
           </li>
       }
     </ul>
   </div>
  return
    $result
};