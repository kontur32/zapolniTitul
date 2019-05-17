module namespace nav = "http://dbx.iro37.ru/zapolnititul/forms/nav";

declare 
  %public
function nav:main(
  $page as xs:string,
  $currentFormID as xs:string
) as element() {
  let $items:= 
        (
          ["form", "Мои формы" ],
          ["data", "Мои данные" ],
          ["upload", "Новая форма" ]
        )
        return
        <div>
            <ul class="nav nav-pills">
              {
                for $item in $items
                let $class := if ( $page = $item?1 ) then( "nav-link active" ) else ( "nav-link" )
                let $href := '/zapolnititul/forms/u/' || $item?1 || '/' || $currentFormID 
                return 
                  <li class="nav-item">
                    <a class="{ $class }" href="{ $href }">{ $item?2 }</a>
                  </li>
              }
            </ul>
         </div>
};