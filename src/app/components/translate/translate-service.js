'use strict';

angular.module('translator')
    .provider('$translate', function () {

        var options = {
            translationsUrl: null,
            defaultTranslations: {}
        };

        this.config = function (opt) {
            angular.extend(options, opt);
        };

        this.$get = function ($http, $locale, $q) {

            var translations = [];
            if (!options.translationsUrl) {
                throw new Error('Service URL must be configured.');
            }

            function getTranslation(translationId, count) {
                if (!translationId || translationId === '#null' || translationId === '#undefined') {
                    return '';
                }
                // f*** ng-translate
                var t = translations[translationId];
                if (t) {
                    if (angular.isObject(t)) {
                        // f*** ng-pluralize
                        if (count === 1 || angular.isUndefined(count)) {
                            return t.one;
                        }
                        return t.other;
                    } else {
                        return t;
                    }
                }
                return translationId;
            }

            var loadTranslations = function () {
                if (!translations.length) {
                    return $q(function(resolve) {
                        $http.get(options.translationsUrl + $locale.id + '.json')
                            .then(function onTranslationsLoadComplete(data) {
                                translations = data.translations || data;
                                resolve(translations);
                            }, function() {
                                translations = options.defaultTranslations;
                                resolve(translations);
                            });
                    });
                }
                // protect against multiple http.get executions
                throw new Error('shoudnt be loaded multiple times, see routes.yml');
            };

            // API
            return {
                get: getTranslation,
                load: loadTranslations
            };

        };

    })

    .factory('translationsLoader', function ($translate) {
        return $translate.load();
    });
