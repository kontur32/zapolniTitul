module namespace complete = "http://dbx.iro37.ru/zapolnititul/forms/complete";

declare function complete:main( $formMeta ) {
  <div>
    <h2>Загрузка шаблона завершена</h2>
    <p>Вы успешно загрузили шаблон <b>{ $formMeta/@label/data() }</b></p>
    <p>Ссылка на форму шаблона 
      <a href="{ '/zapolnititul/forms/u/form/' || $formMeta/@id/data() }">здесь</a>
    </p>
  </div>
};