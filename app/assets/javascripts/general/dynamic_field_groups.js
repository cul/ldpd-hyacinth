$(document).ready(function(){
  if ($('#xml-translation-editor').length > 0) {
    if (typeof(ace) != 'undefined') {
      var editor = ace.edit("xml-translation-editor");
      //editor.setTheme("ace/theme/monokai");
      editor.getSession().setMode("ace/mode/json");
      var textarea = $('#xml-translation-editor-textarea');
      textarea.hide();
      editor.getSession().setValue(textarea.val());
      editor.getSession().on('change', function(){
        textarea.val(editor.getSession().getValue());
      });
    }
  }
});
