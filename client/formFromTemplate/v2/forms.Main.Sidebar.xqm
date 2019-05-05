module namespace sidebar = "http://dbx.iro37.ru/zapolnititul/forms/sidebar";

declare function sidebar:userFormsList ( $userForms as element(form)*, $params as item() ) {
  let $result := 
   <div class="row">
           {
             for $f in $userForms
             let $href_upload := 
                $params( "uploadForm" ) || $f/@id/data()
             let $href_delete := 
               web:create-url( $params( "deleteAPI" ) || $f/@id/data(), map{ "redirect" : $params( 'host' ) || '/zapolnititul/forms/u' } )
             return
             <p class="row">
                <a class="px-2" href="{ $href_upload }">
                  <img width="18" src="{ $params( 'iconUpload' ) }" alt="Обновить" />
                </a>
                <a class="pr-2" href="{ $href_delete }" onclick="return confirm( 'Удалить?' );">
                  <img width="18" src="{ $params( 'iconDelete' ) }" alt="Удалить" />
                </a>
                <a href="/zapolnititul/forms/u/form/{ $f/@id/data() }">
                  <span class="d-inline-block text-truncate" style="max-width: 240px;">
                    { if( $f/@label/data() !="" ) then ( $f/@label/data() ) else ( "Без имени" ) }
                  </span>
                </a>
              </p>
           }
         </div>
  return
    $result         
};