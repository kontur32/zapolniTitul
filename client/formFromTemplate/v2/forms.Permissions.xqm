module namespace permissions = "http://dbx.iro37.ru/zapolnititul/forms/permissions";

import module namespace session = "http://basex.org/modules/session";

declare %perm:check('/zapolnititul/forms/u') function permissions:check-login() {
  let $user := session:get('userid')
  where not( $user )
  return web:redirect('/zapolnititul')
};