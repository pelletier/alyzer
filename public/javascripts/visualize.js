var visualize = (function() {
    return (function(widget, name, reduce) {
        $.ajax({
            url: "/couchdb/" + name,
            type: 'get',
            data: { arguments: { group_level: (0+reduce) } },
            dataType: 'json',
            success: function(data) {
                adapter(data['rows']);
                var d = new Date();
                $("#last_update").html(d.toTimeString());
            }
        });
    });
})();
