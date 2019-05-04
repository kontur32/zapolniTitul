module namespace funct = "http://dbx.iro37.ru/zapolnititul/forms/funct";

declare function funct:id( $id as xs:string, $userID as xs:integer ) as xs:string {
 let $isExist := 
   let $formMeta := 
         try {
           fetch:xml( "http://localhost:8984/zapolnititul/api/v2/forms/" || $id || "/meta" )/form
         }
         catch* { }
   return not( empty( $formMeta ) )
 
 return
   if ( $isExist )
   then ( $id )
   else (
     let $userFormID := 
         try {
           fetch:xml( "http://localhost:8984/zapolnititul/api/v2/users/" || $userID || "/forms" )/forms/form[last()]/@id/data()
         }
         catch* { }
     return
       $userFormID
   )
};

declare function funct:id( $id as xs:string ) as xs:string* {
 let $isExist := 
   let $formMeta := 
         try {
           fetch:xml( "http://localhost:8984/zapolnititul/api/v2/forms/" || $id || "/meta" )/form
         }
         catch* { }
   return not( empty( $formMeta ) )
 
 return 
   if ( $isExist )
   then ( $id )
   else (
     let $total := funct:total()
     let $id := 
       try {
          fetch:xml( web:create-url( "http://localhost:8984/zapolnititul/api/v2/forms", map {"offset" : $total - 1, "limit" : 1 } ) )/forms/form/@id/data()
         }
         catch* { }
      return
        $id
   )
};

declare %private function funct:total() {
  try {
   fetch:xml( "http://localhost:8984/zapolnititul/api/v2/forms" )/forms/@total/data()
  }
  catch* { }
};