var editors = {};
var changed = false;
var snippets = {};

function beautify() {
  $(this).find("textarea").each(function(){
    $(this).val(js_beautify($(this).val()));
    if ($(this).attr('name') === 'adapter') {
      editors[$(this).attr('name')] = CodeMirror.fromTextArea(this, {
        lineNumbers:true,
        onChange: function(){
          if (!changed) {
            $("select option").each(function(){
              $(this).removeAttr('selected');
            });
            $("select option[value=custom]").attr('selected', 'yes');
          }
          else {
            changed = false;
          }
        }});
    }
    else {
      editors[$(this).attr('name')] = CodeMirror.fromTextArea(this, {lineNumbers:true});
    }
  });

}

$(document).ready(function() {
  $("form.edit").each(beautify);
  $("form.edit").submit(beautify);

  $.ajax({
    url: "/snippets/",
    dataType: "xml",
    success: function(xml) {
      $(xml).find("snippet").each(function(){
        var el = $(this);
        snippets[el.attr('name')] = el.text();
      });
    }
  });

  $("select").change(function(){
    var val = $("select option:selected").val();
    var val = $(this).find("option:selected").val();
    if (val != "custom") {
      changed = true;
      editors['adapter'].setValue(snippets[val]);
    }
  });
});
