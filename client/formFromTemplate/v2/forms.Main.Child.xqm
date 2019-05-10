module namespace child = "http://dbx.iro37.ru/zapolnititul/forms/child";

import module namespace
  form = "http://dbx.iro37.ru/zapolnititul/forms/form" at "forms.Main.Form.xqm";
import module namespace
  upload = "http://dbx.iro37.ru/zapolnititul/forms/upload" at "forms.Main.Upload.xqm";
import module namespace 
  config = "http://dbx.iro37.ru/zapolnititul/forms/u/config" at "../../config.xqm";

 
declare function child:main ( $formMeta, $formData ) {
  let $formID := $formMeta/@id/data()
  return
  <div>
    <div class="form-group">
       <label class="h4">Укажите название дочернего шаблона</label>
       <input class="form-control" type="text" name="_t24_label" form="template" required=""/>
     </div>
    <p class="h4">Заполните необходимые поля</p>
    {
     form:form ( $formMeta, $formData )
    }
     <div class="form-group">
       { upload:additionalFormParam ( "template" ) }
     </div>
     
    <div class="form-group">
      <input type="hidden" name="_t24_parentID" value="{ $formID }" form="template"/>
      <input type="hidden" name="_t24_redirect" value="{ $config:param( 'host' ) || '/zapolnititul/forms/u/form/' }" form="template"/>
      <button form="template" type="submit" formaction="{ $config:param( 'host' )|| '/zapolnititul/api/v2/forms/post/child'}" formmethod="POST" class="btn btn-success mx-3">
       Сохранить дочернюю форму
      </button>
    </div>
  </div>
};