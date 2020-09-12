window.frameworkLoaded = false;

$(function(){
    window.addEventListener('message', function(event) {
        var item = event.data || event.detail;
        
        if (typeof item == 'undefined' || item == null) {
            return
        }

        var module = item.__module

        if (typeof module == 'undefined' || module == null) {
            module = 'core'
        }

        switch(module) {
            case 'menu':
                const menuEvent = new CustomEvent('menu_message', {
                    detail: item
                });

                window.dispatchEvent(menuEvent)
                
                break;
            case 'chat':
                const chatEvent = new CustomEvent('chat_message', {
                    detail: item
                });

                window.dispatchEvent(chatEvent)
                break;
            case 'hud':
                const hudEvent = new CustomEvent('hud_message', {
                    detail: item
                });

                window.dispatchEvent(hudEvent)
                break;
            case 'loaded':
                window.frameworkLoaded = true;
                break;
            default:
                break;
        }
    });
});