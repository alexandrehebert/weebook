'use strict';

gulp = require 'gulp'
browserSync = require 'browser-sync'

gulp.task 'serve', ['build'], ->
  browserSync {
    server: {baseDir: 'build/'}
    port: 4000
    browser: 'default'
    startPath: '/'
    notify: true
    open: false
  }
  gulp.watch 'src/main/web/**/*.scss', ['compile:sass']
  gulp.watch 'src/main/web/i18n/*.json', ['build:statics-i18n']
  gulp.watch 'src/main/web/*.html', ['build:statics']
  gulp.watch 'src/main/web/**/*.js', ['package:ng', browserSync.reload]
