'use strict';

angular.module('app.weebook', ['app.conf', 'app.templates', 'pascalprecht.translate']).
    config(function ($translateProvider) {

        // init ng-translate
        // $translateProvider.determinePreferredLanguage();
        $translateProvider.useStaticFilesLoader({
            prefix: '/i18n/',
            suffix: '.json'
        });

        $translateProvider.use('fr_FR');

    }).
    run(function () {

    });
