window.HUD = {
    template: '#hud_template',
    name: 'HUD',
    data() {
        return {
            job_name: 'Unknown',
            job_grade: 'Unknown',
            job2_name: 'Unknown',
            job2_grade: 'Unknown',
            status: {
                health: 100,
                thirst: 100,
                hunger: 100,
                armor: 100
            },
            shouldHide: false
        }
    },
    mounted() {
        this.mountedCallback();
    },
    watch: {
        job_name() {},
        job_grade() {},
        job2_name() {},
        job2_grade() {},
        status() {},
    },
    methods: {
        CHANGE_STATE({ shouldHide }) {
            this.shouldHide = shouldHide
        },
        UPDATE_STATUS({ status, value }) {
            if (status == undefined || typeof status == 'undefined' || status == null || typeof status != 'string') { status = 'unknown'; }
            if (value == undefined || typeof value == 'undefined' || value == null || typeof value != 'number') { value = -1; }

            switch(status.toLowerCase()) {
                case 'health':
                    if (value >= 0) { this.status.health = value; }
                    break;
                case 'thirst':
                    if (value >= 0) { this.status.thirst = value; }
                    break;
                case 'hunger':
                    if (value >= 0) { this.status.hunger = value; }
                    break;
                case 'armor':
                    if (value >= 0) { this.status.armor = value; }
                    break;
            }
        },
        UPDATE_JOB({ jobName, jobGrade }) {
            if (jobName == undefined || typeof jobName == 'undefined' || jobName == null || typeof jobName != 'string') { jobName = this.job_name; }
            if (jobGrade == undefined || typeof jobGrade == 'undefined' || jobGrade == null || typeof jobGrade != 'string') { jobGrade = this.job_grade; }

            this.job_name = jobName;
            this.job_grade = jobGrade;
        },
        UPDATE_JOB2({ jobName, jobGrade }) {
            if (jobName == undefined || typeof jobName == 'undefined' || jobName == null || typeof jobName != 'string') { jobName = this.job2_name; }
            if (jobGrade == undefined || typeof jobGrade == 'undefined' || jobGrade == null || typeof jobGrade != 'string') { jobGrade = this.job2_grade; }

            this.job2_name = jobName;
            this.job2_grade = jobGrade;
        },
        mountedCallback() {
            if (window.frameworkLoaded) {
                $.post('http://corev_client/hud_loaded', JSON.stringify({}));
    
                this.listener = window.addEventListener('hud_message', (event) => {
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