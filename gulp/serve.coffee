'use strict';

gulp = require 'gulp'
browserSync = require 'browser-sync'

gulp.task 'serve', ['build'], ->
  browserSync { 
    server: { baseDir: 'build/' },
    port: 4000,
    browser: 'default',
    startPath: '/'
  }
  gulp.watch 'src/main/web/**/*.scss', [ 'compile:sass' ]
  gulp.watch 'src/main/web/**/*.js', [ 'package:ng', browserSync.reload ]
