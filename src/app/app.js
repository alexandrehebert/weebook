'use strict';

//angular.module('app.boot', ['app.conf', 'translator'])
//    .config(function ($translateProvider, translations) {
//        $translateProvider.config({
//            translationsUrl: '/i18n/',
//            defaultTranslations: translations
//        });
//    })
//    .run(function (translationsLoader) {
//        translationsLoader.then(function () {
//            angular.bootstrap(document.body, ['app.weebook']);
//        });
//    });

angular.module('app.weebook',
    [
        'app.conf', 'app.templates', 'app.routes', 'translator'
    ])
    .config(function ($translateProvider, $routesProvider, translations) {

        $routesProvider.walkRoutes({});

        $translateProvider.config({
            translationsUrl: '/i18n/',
            defaultTranslations: translations
        });

    })
    .run(function () {

    });
