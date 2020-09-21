window.WHEEL = {
    template: '#wheel-template',
    name: 'WHEEL',
    data() {
        return {
            namespace: 'unknown',
            name: 'unknown',
            shouldHide: true,
            items: [],
            showing: false,
            anchorX: 0,
            anchorY: 0,
            min: 100
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
        CHANGE_STATE({ shouldHide, x, y }) {
            if (!shouldHide) {
                this.onMouseOpen(x, y);
            } else {
                this.onMouseClose();
            }

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
            this.addItem(item);
        },
        ADD_ITEMS({ items, removeAll }) {
            removeAll = removeAll || false;

            if (removeAll) {
                this.items = [];
            }

            for (var i = 0; i < items.length; i++) {
                var item = items[i];

                this.addItem(item);
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

                document.body.addEventListener('mousemove', this.onMouseMove);
                document.body.addEventListener('touchmove', e => this.onMouseMove(e.touches[0]));
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
        },
        addItem(item) {
            if (typeof item == 'undefined' || item == null) {
                return;
            }
            
            const _item = {
                show: false
            }

            if (typeof item.namespace != 'undefined' && item.namespace != null) {
                _item.namespace = item.namespace || this.namespace || 'unknown';
            }

            if (typeof item.name != 'undefined' && item.name != null) {
                _item.name = item.name || this.name || 'unknown';
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
                _item.class = 'disabled'
            } else {
                _item.class = ''
            }

            this.items.push(_item)
        },
        onMouseMove({ clientX: x, clientY: y }) {
            if (!this.showing) return;
        
            const wheel = this.getWheel();

            let dx = x - this.anchorX;
            let dy = y - this.anchorY;
            let mag = Math.sqrt(dx * dx + dy * dy);
            let index = 0;
        
            if (mag >= this.min) {
                let deg = Math.atan2(dy, dx) + 0.625 * Math.PI;
                while (deg < 0) deg += Math.PI * 2;
                index = Math.floor(deg / Math.PI * 4) + 1;
            }
        
            wheel.setAttribute('data-chosen', index);
        },
        onMouseOpen(x, y) {
            const wheel = this.getWheel();

            this.showing = true;
            this.anchorX = x;
            this.anchorY = y;
        
            wheel.style.setProperty('--x', `${x}px`);
            wheel.style.setProperty('--y', `${y}px`);
            wheel.classList.add('on');
        },
        onMouseClose() {
            const wheel = this.getWheel();

            this.showing = false;

            let chosen = wheel.getAttribute('data-chosen') || 0;

            if (typeof chosen == 'undefined') {
                chosen = 0;
            } else if (typeof chosen == 'string') {
                chosen = parseInt(chosen) || 0;
            } else if (typeof chosen != 'number') {
                chosen = 0;
            }

            if (chosen != 0) {
                $.post('http://corev_client/wheel_results', JSON.stringify({
                    selected: chosen,
                    __namespace: this.namespace || 'unknown',
                    __name: this.name || 'unknown'
                }));
            }

            wheel.setAttribute('data-chosen', 0);
            wheel.classList.remove('on');
        },
        getWheel() {
            return document.querySelector('.wheel');
        }
    },
    computed: {
        getItems() {
            if (typeof this.items == 'undefined' || this.items == null) {
                this.items = [];
            }

            var startIndex = this.items.length || 0;

            for (var i = startIndex; i < 8; i++) {
                this.items[i] = {
                    namespace: this.namespace,
                    name: this.name,
                    show: false,
                    title: '',
                    description: '',
                    id: -1,
                    icon: '',
                    lib: '',
                    class: 'disabled'
                }
            }

            return this.items
        }
    }
};