var serverport = 8080;

var config = {
	router: {
                baseurl: {
                        dev: 'http://localhost:'+serverport,
                        prod: 'http://87.106.80.36:'+serverport
                },

                category: {
                        get: '/api/categories',
                        post: '/api/categories',
                        put: '/api/categories',
                        delete: '/api/categories'
                },

                question: {
                        get: '/api/questions', // /:categoryId
                        post: '/api/questions',
                        put: '/api/questions',
                        delete: '/api/questions'
                },

                game: {
                       	randomQuestions: '/game/questions' // /:categoryId
                },

                web: {
                      	upload: '/upload',
                        index: '',
                        questions: '/questions' // /:categoryId
                }
        }
};
