'use strict';

angular.module('app.weebook',
    [
        'app.conf',
        'app.templates',
        'pascalprecht.translate',
        'ngRoute', 'route-segment', 'view-segment'
    ]).
    config(function ($translateProvider, $routeProvider, $routeSegmentProvider, routes) {

        $routeSegmentProvider.options.autoLoadTemplates = true;
        $routeProvider.otherwise({redirectTo: '/'});

        // additionnal states found in routes configuration file
        var rootDeep = -1;
        var defaultRoutesDatas = {
            untilResolved: {
                templateUrl: 'components/loading/loading.html'
            },
            resolveFailed: {
                templateUrl: 'error/error.html',
                controller: 'HomeController'
            }
        };

        function walkRoutes(_routes, parent, parentsUrl, parentsId) {
            rootDeep++;
            _.each(_routes, function (route, routeName) {
                var routeId = !!parentsId ? parentsId + '.' + routeName : routeName;
                var routeUrl = !!parentsUrl ? parentsUrl + route.url : route.url;
                console.log(_.times(rootDeep, function () {
                    return ' ';
                }).join('') + routeName + '[' + routeId + '] : ' + routeUrl);
                $routeSegmentProvider.when(routeUrl, routeId);
                route = _.extend(route, defaultRoutesDatas);
                parent.segment(routeName, route);
                if (!!route['./']) {
                    walkRoutes(route['./'], parent.within(routeName), routeUrl, routeName);
                }
            }, $routeSegmentProvider);
            rootDeep--;
        }

        walkRoutes(routes, $routeSegmentProvider);

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
