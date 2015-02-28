'use strict';

function capitalize(input) {
    if (angular.isString(input)) {
        return input.substring(0, 1).toUpperCase() + input.substring(1);
    }
    return '';
}

angular.module('translator')

    .directive('translate', function ($compile, $filter, $interpolate, $parse, $translate) {
        return {
            restrict: 'EA',
            scope: false,
            link: function (scope, element, attrs) {

                var translatePlural = attrs.translate ? $parse(attrs.translate)(scope) : undefined;
                var translateCount = attrs.translate ? $parse(attrs.translate)(scope) : undefined;
                var capitalized = !angular.isUndefined(attrs.capitalize);

                var id = !angular.isUndefined(attrs.translationId) ? attrs.translationId : element.text().trim();

                var translation = $translate.get(id, translateCount);
                if (translatePlural) {
                    translation = $interpolate(translation)(translatePlural);
                }
                if (capitalized) {
                    translation = capitalize(translation);
                }
                // if model changes, translation don't
                element.html(translation);

            }
        };
    })

    .filter('translate', function ($interpolate, $translate) {
        var translateFilter = function translateWithPluralSupport(id, count, parameters) {
            var translation = $translate.get(id, count);
            if (parameters) {
                translation = $interpolate(translation)(parameters);
            }
            return translation;
        };

        // useless coz' we wait for translations to be downloaded before rendering
        // @seealso routes.yml "resolve"
        //translateFilter.$stateful = true;

        return translateFilter;
    })

    .filter('capitalize', function () {
        return function (input) {
            return capitalize(input);
        };
    });