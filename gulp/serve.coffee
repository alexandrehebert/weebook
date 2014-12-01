'use strict';

gulp = require 'gulp'
browserSync = require 'browser-sync'
{ reload } = browserSync

gulp.task 'serve', ['build'], ->
  browserSync {
    server: {baseDir: 'build/'}
    port: 4000
    browser: 'default'
    startPath: '/'
    notify: true
    open: false
  }
  gulp.watch 'src/main/web/**/*.scss', ['compile:sass', reload]
  gulp.watch 'src/main/web/i18n/*.json', ['build:statics-i18n', reload]
  gulp.watch 'src/main/web/*.html', ['build:statics', reload]
  gulp.watch 'src/main/web/**/*.js', ['package:ng', reload]
  gulp.watch 'src/main/conf/*.yml', ['build:ng-conf', reload]
  gulp.watch 'build/exploded/*.js', ['package:ng', reload]
