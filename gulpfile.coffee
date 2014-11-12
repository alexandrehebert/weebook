'use strict';

# use dependencies
gulp = require 'gulp'
from = gulp.src
to = gulp.dest
$ = do require 'gulp-load-plugins'

gutil = require 'gulp-util'
rm = require 'del'
concat = require 'gulp-concat'
sequence = require 'run-sequence'
json2ng = require 'gulp-ng-config'
css2sass = require 'gulp-sass'
rename = require 'gulp-rename'
bowerFiles = require 'main-bower-files'
browserSync = require 'browser-sync'
reload = browserSync.reload

# more gulp files
(require 'require-dir') './gulp';

# global variables
env = if gutil.env.mode then gutil.env.mode else 'development'

gulp.task 'compile-sass', ->
  from 'src/main/web/**/*.scss'
  .pipe do css2sass
  .pipe to 'build'
  .pipe reload stream:true

gulp.task 'build-conf', [], ->
  from ['src/main/conf/' + env + '.json']
  .pipe json2ng 'app.conf'
  .pipe $.rename basename:'conf'
  .pipe to 'build'

gulp.task 'build-statics', [], ->
  from ['src/main/web/**/*.html']
  .pipe to 'build'

gulp.task 'build-vendors', [], ->
  from do bowerFiles
  .pipe $.filter '**/*.js'
  .pipe $.concat 'vendors.js'
  .pipe to 'build/libs'

gulp.task 'clean', (cb) ->
  rm ['.tmp', 'dist'], cb

gulp.task 'build', ['clean'], (cb) ->
  sequence ['compile-sass', 'build-conf', 'build-statics', 'build-vendors'], cb

gulp.task 'default', ['build']
