var ws = null;

var channel = {
    clients : [],
    subscribe : function(callback){
        if(typeof callback === 'function'){
            this.clients.push(callback);
            return this.clients.length-1;
        }
        return null;
    },
    push : function(msg){
        for(var i = 0; i < this.clients.length; i++){
            var callback = this.clients[i];
            if(typeof callback === 'function') this.clients[i](msg);
        }
    },
    unsubscribe : function(id){
        this.clients[id] = null;
    }
};


$(function(){
    var trace = function(msg){
        $('div#tweets').prepend($('<p>').html(msg));
    };

    channel.subscribe(function(status){
        var div = $('<div>');
        var icon = $('<img>').attr('src',status.user.profile_image_url).attr('width',48).attr('height',48);
        var name = $('<a>').attr('href', 'http://twitter.com/'+status.user.screen_name).html(status.user.screen_name);
        var permalink = $('<a>').addClass('permalink').attr('href', 'http://twitter.com/'+status.user.screen_name+'/status/'+status.id).html('[detail]');
        div.append(icon);
        div.append('&nbsp;');
        div.append(name);
        div.append($('<br>'));
        div.append(status.text.replace(/(https?:\/\/[^\s]+)/gi, "<a href=\"$1\">$1</a>"));
        div.append('&nbsp;');
        div.append(permalink);
        $('div#tweets').prepend(div);
    });
    
    var connect = function(){
        ws = new WebSocket('ws://'+$('#ws_addr').val());

        ws.onopen = function(){
            trace('connect');
            $('#menu').hide();
            $('#header').hide();
        };
        ws.onclose = function(){
            trace('server closed');
            var tid = setTimeout(function(){
                if(ws == null || ws.readyState != 1){
                    connect();
                }
            }, 3000);
        };
        ws.onmessage = function(e){
            try{
                console.log(e.data);
                var msg = JSON.parse(e.data);
                channel.push(msg);
            }
            catch(e){
                console.error(e);
            }
        };
    };

    $('#btn_open').click(connect);

});