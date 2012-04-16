String.prototype.escape_html = function(){
    var span = document.createElement('span');
    var txt =  document.createTextNode('');
    span.appendChild(txt);
    txt.data = this;
    return span.innerHTML;
};

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
    var status = function(msg){
        $('#status').text(msg).css('opacity', 1.0).animate({opacity: 0}, 2000);
    };

    channel.subscribe(function(status){
        var div = $('<div>');
        var icon = $('<img>').attr('src',status.user.profile_image_url).attr('width',24).attr('height',24);
        var name = $('<a>').attr('href', 'http://twitter.com/'+status.user.screen_name).text(status.user.screen_name);
        var permalink = $('<a>').addClass('permalink').attr('href', 'http://twitter.com/'+status.user.screen_name+'/status/'+status.id).text('[detail]');
        div.append(icon);
        div.append('&nbsp;');
        div.append(name);
        div.append($('<br>'));
        div.append($('<span>').html(status.text.escape_html().replace(/(https?:\/\/[^\s]+)/gi, "<a href=\"$1\">$1</a>")));
        div.append('&nbsp;');
        div.append(permalink);
        $('#tweets').prepend(div);
    });
    
    var connect = function(){
        ws = new WebSocket('ws://'+$('#ws_addr').val());

        ws.onopen = function(){
            status('connect');
            $('#menu').hide();
            $('#header').hide();
        };
        ws.onclose = function(){
            status('server closed');
            var tid = setTimeout(function(){
                if(ws == null || ws.readyState != 1){
                    connect();
                }
            }, 3000);
        };
        ws.onmessage = function(e){
            try{
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
