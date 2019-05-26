module namespace sidebar = "http://dbx.iro37.ru/zapolnititul/forms/sidebar";

declare 
  %public
function
  sidebar:userFormsList(
    $currentFormID as xs:string,
    $userForms as element( form )*,
    $params as item()
  )
{
  <div class="container">
       {
         for $f in $userForms
         let $formID := $f/@id/data()
         let $formLabel :=
           if( $f/@label/data() != "" )
           then ( $f/@label/data() )
           else ( "Без имени" )
         let $itemClass := 
           if ( $formID = $currentFormID ) 
              then( "font-weight-bold" )
              else( "" )
         let $href_upload := $params( "uploadForm" ) || $formID
         let $href_delete := 
           web:create-url(
             $params( "host") || $params( "deleteAPI" ) || $formID,
             map{ "redirect" : '/zapolnititul/forms/u' }
           )
         return
         <div class="row">
           <div class="col-md-10 text-truncate">
            <a class="{ $itemClass }" href="/zapolnititul/forms/u/form/{ $formID }" data-toggle="tooltip" data-placement="top" title="{ $formLabel }">
              { $formLabel } 
            </a>
            </div>
            <div class="col-md">
            <a class="float-right" href="{ $href_delete }" onclick="return confirm( 'Удалить?' );">
              <i class="fa fa-trash-alt"/>
            </a>
           </div>
          </div>
       }
  </div>    
};

declare function sidebar:userDataList ( $currentFormID, $userData as element( table )* ) {
  let $formsID := distinct-values( $userData/@templateID/data() )
  return
   <div class="container">
       {
         for $d in $formsID
         let $itemClass := 
           if ( $d = $currentFormID ) 
              then( "font-weight-bold" )
              else( "" )
         let $formLabel := 
           try{
             fetch:xml(
               "http://localhost:8984/zapolnititul/api/v2/forms/" || $d || "/meta"
             )/form/@label/data()}
           catch*{ "Форма не найдена" }
         return
           <div class="row text-truncate">
             <i class="fa fa-check mr-1"/>
             <a class="{ $itemClass }" href="{ $d }">{ $formLabel }</a>
           </div>
       }
   </div>
};