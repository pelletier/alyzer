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
    $("form#new_view input[name=name]").change(function(){
        $(this).val(slugify($(this).val()));
    });
});
