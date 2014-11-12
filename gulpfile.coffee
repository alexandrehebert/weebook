'use strict';

# use dependencies
gulp = require 'gulp'
from = gulp.src
to = gulp.dest
$ = do require 'gulp-load-plugins'

gutil = require 'gulp-util'
rm = require 'del'
sequence = require 'run-sequence'
css = minify:(require 'gulp-minify-css'), fromSASS:(require 'gulp-sass')
ng = annotate:(require 'gulp-ng-annotate'), templates:(require 'gulp-ng-templates'), configuration:(require 'gulp-ng-config')
bowerFiles = require 'main-bower-files'
browserSync = require 'browser-sync'
reload = browserSync.reload

# more gulp files
(require 'require-dir') './gulp';

# global variables
env = if gutil.env.mode then gutil.env.mode else 'development'

gulp.task 'compile-sass', ->
  from 'src/main/web/**/*.scss'
  .pipe do css.fromSASS
  .pipe to 'build'
  .pipe reload stream:true

gulp.task 'build-statics', [], ->
  from ['src/main/web/*.html']
  .pipe to 'build'

gulp.task 'build-vendors', [], ->
  from do bowerFiles
  .pipe $.filter '**/*.js'
  .pipe $.concat 'vendors.js'
  .pipe to 'build/libs'

# -- TODO uglify / concat / minify / obfuscate
gulp.task 'build-ng-conf', [], ->
  from ['src/main/conf/' + env + '.json']
  .pipe ng.configuration 'app.conf'
  .pipe $.rename basename:'conf'
  .pipe to 'build'
# --
gulp.task 'build-ng-templates', [], ->
  from 'src/main/web/**/*.html'
  .pipe ng.templates {filename:'app-templates.js', module:'app.templates', standalone:true}
  .pipe to 'build'
# --
gulp.task 'build-ng-app', [], ->
  from 'src/main/web/**/*.js'
  .pipe do ng.annotate
  .pipe to 'build'
# -- ENDTODO

gulp.task 'clean', (cb) ->
  rm ['.tmp', 'dist'], cb

gulp.task 'build', ['clean'], (cb) ->
  sequence ['compile-sass', 'build-statics', 'build-vendors',
            'build-ng-conf', 'build-ng-templates', 'build-ng-app'], cb

gulp.task 'default', ['build']
