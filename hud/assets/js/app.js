(function(){
    window.menus = {};

    menus.template = document.getElementById('menu-template').innerHTML;
    menus.currentResource = 'ddrp_core';
    menus.opened = {};
    menus.currentMenu = {};
    menus.pos = {};

    menus.open = function(namespace, name, data) {
        if (typeof data == 'undefined') { return; }
        if (typeof menus.opened[namespace] == 'undefined') { menus.opened[namespace] = {} }
        if (typeof menus.pos[namespace] == 'undefined') { menus.pos[namespace] = {}; }
        if (typeof data.items == 'undefined') { data.items = [] }

        data.__namespace = namespace;
        data.__name = name;
        data.__open = false;

        for (let i = 0; i < data.items.length; i++) {
            if (typeof data.items[i] != 'undefined') {
                data.items[i].__namespace = namespace;
                data.items[i].__name = name;
                data.items[i].index = i;

                if (typeof data.items[i].type == 'undefined') {
                    data.items[i].type = 'default';
                }

                if (typeof data.items[i].selected != 'undefined' && data.items[i].selected) {
                    menus.pos[namespace][name] = i;
                }

                if (typeof data.items[i].disabled == 'undefined' || !data.items[i].disabled || data.items[i].disabled == 0) {
                    data.items[i].disabled = false;
                } else {
                    data.items[i].disabled = true;
                }
            }
        }

        const cachedPosition = 0;
        const filteredMenuItems = menus.filterDisabled(data);

        if (typeof menus.pos[namespace][name] != 'undefined') {
            cachedPosition = menus.pos[namespace][name]
        }

        if (typeof filteredMenuItems == 'undefined' ||
            filteredMenuItems == null) {
                menus.pos[namespace][name] = 0;
        } else if (typeof filteredMenuItems[0] == 'undefined' ||
            filteredMenuItems[0] == null) {
                menus.pos[namespace][name] = 0;
        } else {
            let posStillExists = false;

            for (let i = 0; i < menu.length; i++) {
                if (menu[i].pos == cachedPosition) {
                    posStillExists = true;
                    menus.pos[namespace][name] = menu[i].pos;
                    break;
                }
            }

            if (!posStillExists) {
                menus.pos[namespace][name] = menu[0].pos;
            }
        }

        if (data.items.length > 0) {
            if (typeof data.items[menus.pos[namespace][name]].description != 'undefined') {
                menus.description = data.items[menus.pos[namespace][name]].description;
            } else {
                menus.description = '';
            }
        } else {
            menus.description = '';
        }

        menus.opened[namespace][name] = data;
        menus.currentMenu = data;

        menus.render();

        SendMessage(namespace, name, 'open', menus.opened[namespace][name]);
    };

    menus.close = function(_namespace, _name) {
        if (typeof menus.currentMenu == 'undefined' || menus.currentMenu == null) { return; }

        const namespace = menus.currentMenu.__namespace
        const name = menus.currentMenu.__name

        if (typeof namespace == 'undefined' || typeof name == 'undefined' || namespace == null || name == null) { return; }
        if (_namespace != namespace || _name != name) { return; }
        if (typeof menus.opened[namespace] == 'undefined' || typeof menus.opened[namespace][name] == 'undefined') { return; }
       
        menus.opened[namespace][name].__open = false;
        menus.currentMenu = null;

        menus.render();

        SendMessage(namespace, name, 'close', menus.opened[namespace][name]);
    };

    menus.filterDisabled = function(menu) {
        let items = [];

        if (typeof menu == 'undefined' || menu == null || typeof menu.items == 'undefined' || menu.items == null) {
            return [];
        }

        if (menu.items.length > 0) {
            for (let i = 0; menu.items.length; i++) {
                if (typeof menu.items[i] != 'undefined') {
                    menu.items[i].pos = i;
    
                    if (typeof menu.items[i].disabled == 'undefined' ||
                        menu.items[i].disabled == null ||
                        menu.items[i].disabled == false) {
                            items.push(menu.items[i]);
                        }
                }
            }
        }

        return items;
    };

    menus.render = function() {
        let menuContainer = document.getElementById('menus');

        if (typeof menus.currentMenu == 'undefined' || menus.currentMenu == null) {
            menuContainer.innerHTML = '';
            return;
        }

        const namespace = menus.currentMenu.__namespace
        const name = menus.currentMenu.__name

        let menu = menus.opened[namespace][name]
        let view = JSON.parse(JSON.stringify(menu));

        menuContainer.innerHTML = Mustache.render(menus.template, view);
    };

    menus.change = function(namespace, name, data) {
        SendMessage(namespace, name, 'change', data);
    }

    menus.submit = function(namespace, name, data) {
        SendMessage(namespace, name, 'submit', data);
    }

    window.onData = (data) => {
        console.log(JSON.stringify(data))

        switch (data.action) {
            case 'openMenu': {
                menus.open(data.__namespace, data.__name, data.data);
                break;
            }

            case 'closeMenu': {
                menus.close(data.__namespace, data.__name);
                break;
            }

            case 'controlPressed': {
                switch (data.control) {
                    case 'ENTER': {
                        if (typeof menus.currentMenu == 'undefined' || menus.currentMenu == null) { return; }

                        const namespace = menus.currentMenu.__namespace
                        const name = menus.currentMenu.__name

                        if (typeof namespace == 'undefined' || typeof name == 'undefined' || namespace == null || name == null) { return; }

                        if (typeof data == 'undefined') { return; }
                        if (typeof menus.opened[namespace] == 'undefined') { return; }
                        if (typeof menus.opened[namespace][name] == 'undefined') { return; }

                        let menu = menus.opened[namespace][name];
                        let position = menus.pos[namespace][name];
                        
                        if (menu.items.length > 0) {
                            menus.submit(namespace, name, {
                                __namespace: namespace,
                                __name: name,
                                index: position
                            });
                        }

                        break;
                    }

                    case 'BACKSPACE': {
                        menus.close(data.__namespace, data.__name);
                        break;
                    }

                    case 'TOP': {
                        if (typeof menus.currentMenu == 'undefined' || menus.currentMenu == null) { return; }

                        const namespace = menus.currentMenu.__namespace
                        const name = menus.currentMenu.__name

                        if (typeof namespace == 'undefined' || typeof name == 'undefined' || namespace == null || name == null) { return; }

                        if (typeof data == 'undefined') { return; }
                        if (typeof menus.opened[namespace] == 'undefined') { return; }
                        if (typeof menus.opened[namespace][name] == 'undefined') { return; }

                        let menu = menus.opened[namespace][name];
                        let filteredMenuItems = menus.filterDisabled(menu);
                        let position = menus.pos[namespace][name] + 0;

                        if (filteredMenuItems.length > 0) {
                            if (position > 0) {
                                let index = 0;

                                for (let i = 0; i < filteredMenuItems.length; i++) {
                                    if (position == filteredMenuItems[i].pos) {
                                        index = i;
                                    }
                                }

                                index--;

                                if (index < 0) {
                                    index = filteredMenuItems.length - 1
                                } else if (index > filteredMenuItems.length) {
                                    index = 0;
                                }

                                menus.pos[namespace][name] = filteredMenuItems[index].pos;
                            } else {
                                menus.pos[namespace][name] = filteredMenuItems[filteredMenuItems.length - 1].pos;
                            }

                            for(i = 0; i < menu.items.length; i++) {
                                if (i == menus.pos[namespace][name]) {
                                    menus.opened[namespace][name].items[i].selected = true;
                                } else {
                                    menus.opened[namespace][name].items[i].selected = false;
                                }
                            }

                            menus.render();
                            menus.change(namespace, name, {
                                __namespace: namespace,
                                __name: name,
                                oldIndex: position,
                                newIndex: menus.pos[namespace][name]
                            });
                        }

                        break;
                    }

                    case 'DOWN': {
                        if (typeof menus.currentMenu == 'undefined' || menus.currentMenu == null) { return; }

                        const namespace = menus.currentMenu.__namespace
                        const name = menus.currentMenu.__name

                        if (typeof namespace == 'undefined' || typeof name == 'undefined' || namespace == null || name == null) { return; }

                        if (typeof data == 'undefined') { return; }
                        if (typeof menus.opened[namespace] == 'undefined') { return; }
                        if (typeof menus.opened[namespace][name] == 'undefined') { return; }

                        let menu = menus.opened[namespace][name];
                        let filteredMenuItems = menus.filterDisabled(menu);
                        let position = menus.pos[namespace][name] + 0;

                        if (filteredMenuItems.length > 0) {
                            if (position < filteredMenuItems[filteredMenuItems.length - 1].pos) {
                                let index = 0;

                                for (let i = 0; i < filteredMenuItems.length; i++) {
                                    if (position == filteredMenuItems[i].pos) {
                                        index = i;
                                    }
                                }

                                index++;

                                if (index < 0) {
                                    index = 0
                                } else if (index > filteredMenuItems.length) {
                                    index = filteredMenuItems.length - 1;
                                }

                                menus.pos[namespace][name] = filteredMenuItems[index].pos;
                            } else {
                                menus.pos[namespace][name] = filteredMenuItems[0].pos;
                            }

                            for(i = 0; i < menu.items.length; i++) {
                                if (i == menus.pos[namespace][name]) {
                                    menus.opened[namespace][name].items[i].selected = true;
                                } else {
                                    menus.opened[namespace][name].items[i].selected = false;
                                }
                            }

                            menus.render();
                            menus.change(namespace, name, {
                                __namespace: namespace,
                                __name: name,
                                oldIndex: position,
                                newIndex: menus.pos[namespace][name]
                            });
                        }

                        break;
                    }

                    default: break;
                }

                break;
            }

            default: break;
        }
    };

    window.onload = function(e) {
        window.addEventListener('message', (event) => {
            onData(event.data);
        });
    };
})();