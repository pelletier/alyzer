var editors = {};
var changed = false;
var snippets = {};

function beautify() {
    $(this).find("textarea").each(function () {
        $(this).val(js_beautify($(this).val()));
        var form_name = $(this).closest('form').find('input[name=name]').attr('value');
        if (editors[form_name] === undefined) {
            editors[form_name] = {};
        }
        if ($(this).attr('name') === 'adapter') {
            editors[form_name][$(this).attr('name')] = CodeMirror.fromTextArea(this, {
                lineNumbers: true,
                onChange: function () {
                    if (!changed) {
                        $("select option").each(function () {
                            $(this).removeAttr('selected');
                        });
                        $("select option[value=custom]").attr('selected', 'yes');
                    } else {
                        changed = false;
                    }
                }
            });
        } else {
            editors[form_name][$(this).attr('name')] = CodeMirror.fromTextArea(this, {
                lineNumbers: true
            });
        }
    });
}

function slugify(text) {
    text = text.toLowerCase();
    text = text.replace(/[^-a-zA-Z0-9,&\s]+/ig, '');
    text = text.replace(/-/gi, "_");
    text = text.replace(/\s/gi, "-");
    text = text.replace(/^[-_ ]+/, "");
    text = text.replace(/[-_ ]+$/, "");
    return text;
}

$(document).ready(function () {
    $("form.edit").each(beautify);
    $("form.edit").submit(beautify);

    $.ajax({
        url: "/public/snippets.xml",
        dataType: "xml",
        success: function (xml) {
            $(xml).find("snippet").each(function () {
                var el = $(this);
                snippets[el.attr('name')] = el.text();
            });
        }
    });

    $("select").change(function () {
        var val = $(this).find("option:selected").val();
        if (val != "custom") {
            changed = true;
            var name = $(this).closest('form').find('input[name=name]').attr('value');
            editors[name]['adapter'].setValue(snippets[val]);
        }
    });

    $("form#new_view input[name=name]").change(function(){
        $(this).val(slugify($(this).val()));
    });

});
