'use strict';

angular.module('app.weebook',
    [
        'app.conf',
        'app.templates',
        'pascalprecht.translate',
        'ui.router'
    ]).
    config(function ($translateProvider, $stateProvider, $urlRouterProvider, routes) {

        // additionnal states found in routes configuration file
        for (var routeName in routes) {
            $stateProvider.state(routeName, routes[routeName]);
        }
        $urlRouterProvider.when('', '/')
            .otherwise('/404');

        // init ng-translate
        // $translateProvider.determinePreferredLanguage();
        $translateProvider.useStaticFilesLoader({
            prefix: '/i18n/',
            suffix: '.json'
        });

        $translateProvider.use('fr_FR');

    }).
    run(function ($state, $rootScope) {

        // default state & routes definition
        $rootScope.$on('$stateChangeError', function () {
            $state.go('404');
        });

    });
