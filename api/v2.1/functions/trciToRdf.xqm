(:
  функции для преобразования TRCI в RDF-штрих
:)

module namespace trciToRdf = 'http://dbx.iro37.ru/zapolnititul/api/v2.1/trciToRdf/';

declare namespace с = 'http://dbx.iro37.ru/сущности/';
declare namespace п = 'http://dbx.iro37.ru/признаки/';

(: преобразует TRCI в RDF :)

declare function trciToRdf:tokenData( $tokenData as element( table )* ){
  element { xs:QName( 'с:токенДоступаOAuth2' ) }{
    attribute { 'about' } { $tokenData//row/@id/data() },
    for $i in $tokenData//cell
    return
      element { xs:QName( 'п:' || $i/@id/data() ) } { $i/text() } 
  }
};

declare function trciToRdf:transformRow( $storeData as element( row ), $rootElement ){
   element { xs:QName( $rootElement ) }{
      attribute { 'about' } { $storeData/@id/data() },
      for $i in $storeData/cell
      let $признак :=
        replace( tokenize( $i/@id/data(), '/' )[ last() ], ' ', '-' )
      return
        element { xs:QName( 'п:' || $признак ) } { $i/text() },
      element { 'п:userID' } {  $storeData/@userID/data() }
    }
};

declare function trciToRdf:storeData( $storeData as element( row ) ){
   trciToRdf:transformRow( $storeData, 'с:хранилищеNextcloud' )
};

declare function trciToRdf:sourceData( $sourceData as element( row ) ){
  trciToRdf:transformRow( $sourceData, 'с:ресурсNextcloud' )
};
