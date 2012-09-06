var visualize = (function() {
    return (function(widget, name, reduce) {
        var params = {};
        if (reduce) {
            params['group_level'] = 1;
        }
        else {
            params['reduce'] = false;
        }

        $.ajax({
            url: "/couchdb/" + name,
            type: 'get',
            data: { arguments: params},
            dataType: 'json',
            success: function(data) {
                adapter(data['rows']);
                var d = new Date();
                $("#last_update").html(d.toTimeString());
            }
        });
    });
})();
