var editors = {};
var snippets = {};

function beautify() {
    $("textarea").each(function () {
        $(this).val(js_beautify($(this).val()));

        var name = $(this).attr('name');

        var cm_instance = CodeMirror.fromTextArea(this, {
            lineNumbers: true,
            onChange: function() {
                if (!editors[name].changed) {
                    $(".selector[rel="+name+"] select option").each(function () {
                        $(this).removeAttr('selected');
                    });
                    $(".selector[rel="+name+"] select option[value=custom]").attr('selected', 'yes');
                } else {
                    editors[name].changed = false;
                }
            },
            onFocus: function() {
            },
            onBlur: function() {
                $(".selector[rel="+name+"]").hide();
            }
        });

        var selector = $(".selector[rel="+name+"]");

        var mouse_in = function(){
            selector.show();
            var wrapper = $(editors[name].getWrapperElement());
            var w_offset = wrapper.offset();

            /* jQuery bug? Setting both the coordinates and the position
             * attribute in a single call makes the browser miscalculate the
             * final drawing coords. */
            selector.css('position', 'absolute');
            selector.css({
                top: w_offset.top + wrapper.height() - selector.height(),
                left: w_offset.left + wrapper.width() - selector.width()
            });
        }

        var mouse_out = function() {
            selector.hide();
        };

        $(cm_instance.getWrapperElement()).hover(mouse_in, mouse_out);
        selector.hover(mouse_in, mouse_out);

        selector.find('select').change(function() {
            var val = $(this).find("option:selected").val();
            if (val != "custom") {
                editors[name].changed = true;
                editors[name].setValue(snippets[name][val]);
            }
        });

        cm_instance.changed = false;
        editors[name] = cm_instance;

    });
}

$(document).ready(function () {
    $("form.edit").each(beautify);
    $("form.edit").submit(beautify);

    $.ajax({
        url: "/public/snippets.xml",
        dataType: "xml",
        success: function(xml) {
            $(xml).find("category").each(function () {
                var categ = $(this);
                var categ_name = categ.attr('name');
                categ_snippets = {};
                categ.find("snippet").each(function() {
                    var el = $(this);
                    var el_name = el.attr('name');
                    categ_snippets[el_name] = el.text();
                    $(".selector[rel="+categ_name+"] select").append($("<option>").val(el_name).text(el_name));
                });
                snippets[categ_name] = categ_snippets;
            });

            $(".selector select").each(function() {
                var init_val = $(this).attr('data_init');
                $(this).find("option[value="+init_val+"]").attr('selected', 'yes');
            });
        }
    });

    $(".btn-danger").click(function() {
        return confirm("Are you sure?");
    });

    $(".selector").hide();
});
