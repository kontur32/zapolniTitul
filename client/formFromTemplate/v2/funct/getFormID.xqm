module namespace getFormID = "http://dbx.iro37.ru/zapolnititul/forms/getFormID";

(:~
 : Возвращает идентификатор последней формы пользователя, 
 : если заданная форма не существует.
 : @id идентификатор формы
 : @userID идентификатор пользователя 
 : @return строку
 :)
declare function getFormID:id( $id as xs:string, $userID as xs:integer ) as xs:string {
 let $isExist := 
   let $formMeta := 
         try {
           fetch:xml( "http://localhost:9984/zapolnititul/api/v2/forms/" || $id || "/meta" )/form
         }
         catch* { }
   return not( empty( $formMeta ) )
 
 return
   if ( $isExist )
   then ( $id )
   else (
     let $userFormID := 
         try {
           fetch:xml( "http://localhost:9984/zapolnititul/api/v2/users/" || $userID || "/forms" )/forms/form[ last() ]/@id/data()
         }
         catch* { }
     return
       $userFormID
   )
};

(:~
 : Возвращает идентификатор последней, 
 : если заданная форма не существует.
 : @id идентификатор формы
 : @return строку
 :)
declare function getFormID:id( $id as xs:string ) as xs:string* {
 let $isExist := 
   let $formMeta := 
         try {
           fetch:xml( "http://localhost:9984/zapolnititul/api/v2/forms/" || $id || "/meta" )/form
         }
         catch* { }
   return not( empty( $formMeta ) )
 
 return 
   if ( $isExist )
   then ( $id )
   else (
     let $total := getFormID:total()
     let $id := 
       try {
          fetch:xml( web:create-url( "http://localhost:9984/zapolnititul/api/v2/forms", map {"offset" : $total - 1, "limit" : 1 } ) )/forms/form/@id/data()
         }
         catch* { }
      return
        if( $id )
        then ( $id )
        else ( "" )
   )
};

(:~
 : Возвращает количество зарегистрированных форм
 : @return строку
 :)
declare
  %private
function getFormID:total() as xs:integer {
  try {
   let $totalFormCount := fetch:xml( "http://localhost:9984/zapolnititul/api/v2/forms" )/forms/@total/data()
   return
     if( $totalFormCount )
     then( $totalFormCount )
     else ( 1 )
  }
  catch* { 1 }
};