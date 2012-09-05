var visualize = (function() {
    return (function(widget, name, reduce) {
        $.ajax({
            url: "http://localhost:5984/alyzer/_design/alyzer_views/_view/"+name+"?group_level="+(0+reduce)+"&callback=?",
            type: 'get',
            dataType: 'jsonp',
            success: function(data) {
                adapter(data['rows']);
            }
        });
    });
})();
