'use strict';

module.exports = (karma) ->

  # set the karma conf
  karma.set (

    colors: true
    autoWatch: true
    singleRun: true
    logLevel: karma.LOG_DEBUG
    basePath: '../../'

    files: [
      '*.js'
    ]
    preprocessors:
      '**/*.coffee': 'coffee'
    frameworks: [
      'jasmine'
    ]
    plugins: [
      'karma-*'
    ]
    browsers: [
      'Chrome'
    ]
    reporters: [
      'dots'
      'progress'
      'junit'
      'coverage'
    ]
    coverageReporter: {
      type: 'html'
      dir: 'logs/reports/coverage/'
    }
    junitReporter: {
      outputFile: 'logs/reports/junit/test-results.xml'
      suite: ''
    }

  )

