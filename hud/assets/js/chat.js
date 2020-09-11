window.APP = {
    template: '#app_template',
    name: 'APP',
    data() {
        return {
            showInput: false,
            showWindow: false,
            shouldHide: true,
            message: '',
            messages: [],
            backingSuggestions: [],
            removedSuggestions: [],
            oldMessages: [],
            oldMessagesIndex: -1
        }
    },
    mounted() {
        this.mountedCallback();
    },
    watch: {
        messages() {
            if (this.showWindowTimer) {
                clearTimeout(this.showWindowTimer);
            }

            this.showWindow = true;
            this.resetShowWindowTimer();

            const messagesObj = this.$el.querySelector('.core-chat-inner-messages');

            this.$nextTick(() => {
                messagesObj.scrollTop = messagesObj.scrollHeight;
            });
        },
    },
    computed: {
        suggestions() {
            return this.backingSuggestions.filter((suggestion) => removedSuggestions.find(removedSuggestion => removedSuggestion == suggestion.name) == undefined);
        },
    },
    methods: {
        CHANGE_STATE({ shouldHide }) {
            this.shouldHide = shouldHide
        },
        OPEN_CHAT() {
            this.showInput = true;
            this.showWindow = true;

            if (this.showWindowTimer) {
                clearTimeout(this.showWindowTimer)
            }

            this.focusTimer = setInterval(() => {
                if (this.$refs.input) {
                    this.$refs.input.focus();
                } else {
                    clearInterval(this.focusTimer);
                }
            }, 100);
        },
        ADD_MESSAGE({ message }) {
            this.messages.push(message);
        },
        CLEAR_CHAT() {
            this.messages = [];
        },
        ADD_SUGGESTION({ suggestion }) {
            this.addSuggestion(suggestion)
        },
        ADD_SUGGESTIONS({ suggestions, removeAll }) {
            removeAll = removeAll || false;

            if (removeAll) {
                this.backingSuggestions = []
                this.removedSuggestions = []
            }

            for (var suggestion in suggestions) {
                this.addSuggestion(suggestion)
            }
        },
        REMOVE_SUGGESTION({ name }) {
            const suggestionIndex = this.backingSuggestions.findIndex(suggestion => suggestion.name == name);

            if (suggestionIndex >= 0) {
                this.backingSuggestions = this.backingSuggestions.splice(suggestionIndex, 1)
            }

            const removedSuggestionIndex = this.removedSuggestions.findIndex(removedSuggestion == name);

            if (removedSuggestionIndex < 0) {
                this.removedSuggestions.push(name);
            }
        },
        clearShowWindowTimer() {
            if (this.showWindowTimer) {
                clearTimeout(this.showWindowTimer)
            }
        },
        resetShowWindowTimer() {
            this.clearShowWindowTimer();
            this.showWindowTimer = setTimeout(() => {
                if (!this.showInput) {
                    this.showWindow = false;
                }
            }, 7000)
        },
        keyUp() {
            this.resize();
        },
        keyDown(e) {
            if (e.which === 38 || e.which === 40) {
                e.preventDefault();
                this.moveOldMessageIndex(e.which === 38);
            } else if (e.which == 33) {
                var buf = document.getElementsByClassName('core-chat-inner-messages')[0];
                buf.scrollTop = buf.scrollTop - 100;
            } else if (e.which == 34) {
                var buf = document.getElementsByClassName('core-chat-inner-messages')[0];
                buf.scrollTop = buf.scrollTop + 100;
            }
        },
        moveOldMessageIndex(up) {
            if (up && this.oldMessages.length > this.oldMessagesIndex + 1) {
                this.oldMessagesIndex += 1;
                this.message = this.oldMessages[this.oldMessagesIndex];
            } else if (!up && this.oldMessagesIndex - 1 >= 0) {
                this.oldMessagesIndex -= 1;
                this.message = this.oldMessages[this.oldMessagesIndex];
            } else if (!up && this.oldMessagesIndex - 1 === -1) {
                this.oldMessagesIndex = -1;
                this.message = '';
            }
        },
        resize() {
            const input = this.$refs.input;

            input.style.height = '5px';
            input.style.height = `${input.scrollHeight + 2}px`;
        },
        send(e) {
            if(this.message !== '') {
                $.post('http://corev_client/chat_results', JSON.stringify({
                    message: this.message,
                }));
                this.oldMessages.unshift(this.message);
                this.oldMessagesIndex = -1;
                this.hideInput();
            } else {
                this.hideInput(true);
            }
        },
        hideInput(canceled = false) {
            if (canceled) {
                $.post('http://corev_client/chat_results', JSON.stringify({ canceled }));
            }

            this.message = '';
            this.showInput = false;

            clearInterval(this.focusTimer);

            this.resetShowWindowTimer();
        },
        addSuggestion(suggestion) {
            const existingSuggestion = this.backingSuggestions.find(a => a.name == suggestion.name);

            if (existingSuggestion) {
                if (suggestion.help || suggestion.params) {
                    existingSuggestion.help = suggestion.help || existingSuggestion.help || '';
                    existingSuggestion.params = suggestion.params || existingSuggestion.params || [];
                }

                return;
            }

            if (!suggestion.params) { suggestion.params = []; }

            this.backingSuggestions.push(suggestion);

            const removedSuggestionIndex = this.removedSuggestions.findIndex(removedSuggestion == name);

            if (removedSuggestionIndex >= 0) {
                this.removedSuggestions = this.removedSuggestions.splice(removedSuggestionIndex, 1);
            }
        },
        mountedCallback() {
            if (window.frameworkLoaded) {
                $.post('http://corev_client/chat_loaded', JSON.stringify({}));
    
                this.listener = window.addEventListener('chat_message', (event) => {
                    const item = event.data || event.detail;
    
                    if (this[item.action]) {
                        this[item.action](item);
                    }
                });
            } else {
                window.setTimeout(this.mountedCallback, 100);
            }
        }
    },
};