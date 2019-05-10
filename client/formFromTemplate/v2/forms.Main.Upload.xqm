module namespace upload = "http://dbx.iro37.ru/zapolnititul/forms/upload";

declare function upload:main( $isData, $id, $redirect ) {
  <div>
    <h1>Загрузка шаблона</h1>
    <div class="form-group">
     <form method="POST" action="/zapolnititul/api/v2/forms/post" enctype="multipart/form-data" id="upload">
        <div class="form-group">
         <label>Укажите название шаблона</label>
         <input class="form-control" type="text" name="label" required=""/>
       </div>
       <div class="form-group">
         <label>Выберите файл с шаблоном</label>
         <input class="form-control" type="file" name="template" required="" accept=".docx"/>
       </div>
       
       { upload:additionalFormParam ( "upload" ) }
       
        <input type="hidden" name="id" value="{ $id }"/>
        <input type="hidden" name="redirect" value="{ $redirect }"/>
        <p>и нажмите </p>
        <input class="btn btn-primary" type="submit" value="Загрузить..."/>
     </form>
    </div>
  </div>
};

declare function upload:additionalFormParam ( $formID ) {
  <div>
    <button class="btn btn-info" type="button" data-toggle="collapse" data-target="#uploadAdditional" aria-expanded="false" aria-controls="uploadAdditional">
    Дополнительные параметры шаблона
    </button>
    <div class="collapse" id="uploadAdditional">
      <div class="card card-body">
        <div class="form-group">
          <label>Выберите файл с данными (.xlsx)</label>
          <input class="form-control" type="file" name="data" accept=".xlsx" form="{ $formID}"/>
        </div>
        <div class="form-group">
          <label>Выберите файл с изображением шаблона</label>
          <input class="form-control" type="file" name="template-image" accept="image/*" form="{ $formID}"/>
        </div>
      </div>
    </div>
  </div>
};