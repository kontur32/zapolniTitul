module namespace sidebar = "http://dbx.iro37.ru/zapolnititul/forms/sidebar";

declare function sidebar:userFormsList ( $userID as xs:integer, $params as item() ) {
  let $userForms := 
    try {
      fetch:xml( "http://localhost:8984/zapolnititul/api/v2/users/" || $userID || "/forms")/forms/form
    }
    catch*{
      "Не удалось получить список форм пользователя"
    }
  let $result := 
   <div class="row">
           {
             for $f in $userForms
             let $href_upload := 
                $params( "uploadForm" ) || $f/@id/data()
             let $href_delete := 
               web:create-url( $params( "deleteAPI" ) || $f/@id/data(), map{ "redirect" : $params( 'host' ) || '/zapolnititul/forms/u' } )
             return
             <div class="row">
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
              </div>
           }
         </div>
  return
    $result         
};