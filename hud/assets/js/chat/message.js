Vue.component('message', {
    template: '#message_template',
    data() {
        return {};
    },
    computed: {
    },
    methods: {
    },
    props: {
        type: {
            type: String,
            default: 'ooc'
        },
        time: {
            type: String,
            default: () => {
                var today = new Date();

                return today.getHours() + ":" + today.getMinutes();
            }
        },
        icon: {
            type: String,
            default: 'globe-europe',
        },
        iconlib: {
            type: String,
            default: 'fas'
        },
        sender: {
            type: String,
            default: 'Anoniem',
        },
        message: {
            type: String,
            default: '',
        },
    },
});

  