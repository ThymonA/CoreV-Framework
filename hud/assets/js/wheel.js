window.WHEEL = {
    template: '#wheel-template',
    name: 'WHEEL',
    data() {
        return {
            namespace: 'unknown',
            name: 'unknown',
            shouldHide: true,
            items: []
        }
    },
    mounted() {
        this.mountedCallback();
    },
    watch: {
        items() {},
        namespace() {},
        name() {}
    },
    methods: {
        CHANGE_STATE({ shouldHide }) {
            this.shouldHide = shouldHide
        },
        SET_NAMESPACE({ namespace, name }) {
            if (typeof namespace != 'undefined' && namespace != null) {
                this.namespace = namespace || 'unknown';
            }

            if (typeof name != 'undefined' && name != null) {
                this.name = name || 'unknown';
            }
        },
        CLEAR_ITEMS() {
            this.items = [];
        },
        ADD_ITEM({ item }) {
            if (typeof item == 'undefined' || item == null) {
                return;
            }
            
            const _item = {
                show: false
            }

            if (typeof item.namespace != 'undefined' && item.namespace != null) {
                _item.namespace = item.namespace || 'unknown';
            }

            if (typeof item.name != 'undefined' && item.name != null) {
                _item.name = item.name || 'unknown';
            }

            if (typeof item.title != 'undefined' && item.title != null) {
                _item.show = true;
                _item.title = item.title || 'Unknown';
            }

            if (typeof item.description != 'undefined' && item.description != null) {
                _item.show = true;
                _item.description = item.description || '';
            }

            if (typeof item.id != 'undefined' && item.id != null) {
                _item.show = true;
                _item.id = item.id || this.getCurrentItemIndex();
            } else {
                _item.id = item.id || this.getCurrentItemIndex();
            }

            if (typeof item.icon != 'undefined' && item.icon != null) {
                _item.show = true;
                _item.icon = item.icon || 'fa-angle-right';
            }

            if (typeof item.lib != 'undefined' && item.lib != null) {
                _item.show = true;
                _item.lib = item.lib || 'fad';
            }

            if (!_item.show) {
                _item.class = 'blank'
            } else {
                _item.class = 'wheelitem'
            }
        },
        ADD_ITEMS({ items, removeAll }) {
            removeAll = removeAll || false;

            if (removeAll) {
                this.items = []
            }

            for (var item in items) {
                this.ADD_ITEM(item)
            }
        },
        mountedCallback() {
            if (window.frameworkLoaded) {
                $.post('http://corev_client/wheel_loaded', JSON.stringify({}));
    
                this.listener = window.addEventListener('wheel_message', (event) => {
                    const item = event.data || event.detail;
    
                    if (this[item.action]) {
                        this[item.action](item);
                    }
                });
            } else {
                window.setTimeout(this.mountedCallback, 100);
            }
        },
        getCurrentItemIndex() {
            if (typeof this.items != 'undefined' && this.items != null) {
                return this.items.length + 1;
            } else {
                return 0;
            }
        }
    },
};