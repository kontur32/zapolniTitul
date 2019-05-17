module namespace nav = "http://dbx.iro37.ru/zapolnititul/forms/nav";

declare 
  %public
function nav:main(
  $page as xs:string,
  $currentFormID as xs:string
) as element() {
  let $items:= 
        (
          ["form", '/zapolnititul/forms/u/' || 'form' || '/' || $currentFormID,  "Мои формы" ],
          ["data", '/zapolnititul/forms/u/' || 'data' || '/' || $currentFormID, "Мои данные" ],
          ["upload", '/zapolnititul/forms/u/' || 'upload' || '/' || 'new', "Новая форма" ]
        )
        return
        <div>
            <ul class="nav nav-pills">
              {
                for $item in $items
                let $class := if ( $page = $item?1 ) then( "nav-link active" ) else ( "nav-link" )
                return 
                  <li class="nav-item">
                    <a class="{ $class }" href="{ $item?2 }">{ $item?3 }</a>
                  </li>
              }
            </ul>
         </div>
};