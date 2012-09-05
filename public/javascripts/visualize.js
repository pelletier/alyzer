var visualize = (function() {
    return (function(widget, name, reduce, couch_url, couch_db) {
        $.ajax({
            url: couch_url+"/"+couch_db+"/_design/alyzer_views/_view/"+name+"?group_level="+(0+reduce)+"&callback=?",
            type: 'get',
            dataType: 'jsonp',
            success: function(data) {
                adapter(data['rows']);
                var d = new Date();
                $("#last_update").html(d.toTimeString());
            }
        });
    });
})();
