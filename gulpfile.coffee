'use strict';

# use dependencies
gulp = require 'gulp'
from = gulp.src
to = gulp.dest
$ = do require 'gulp-load-plugins'
$.if = require 'gulp-if-else'

rm = require 'del'
sequence = require 'run-sequence'
css =
  minify: (require 'gulp-minify-css'), fromSASS: (require 'gulp-sass')
ng =
  annotate: (require 'gulp-ng-annotate'), templates: (require 'gulp-ng-templates'), configuration: (require 'gulp-ng-config')
bowerFiles = require 'main-bower-files'
browserSync = require 'browser-sync'
reload = browserSync.reload

# more gulp files
(require 'require-dir') './gulp';

# global variables
env = if $.util.env.mode then $.util.env.mode else 'development'
compressed = env == 'production'

gulp.task 'compile-sass', [], ->
  from 'src/main/web/**/*.scss'
  .pipe css.fromSASS ({
    includePaths: [
      'src/main/vendors/bower_components/bourbon/app/assets/stylesheets',
      'src/main/vendors/bower_components/bitters/app/assets/stylesheets',
      'src/main/vendors/bower_components/neat/app/assets/stylesheets',
      'src/main/web/styles'
    ]
  })
  .pipe $.concat 'styles.css'
  .pipe $.if compressed, css.minify
  .pipe $.size title: 'styles'
  .pipe to 'build'
  .pipe reload stream: true

gulp.task 'build-statics', [], ->
  from ['src/main/web/*.html']
  .pipe to 'build'

gulp.task 'build-vendors', [], ->
  from do bowerFiles
  .pipe $.filter '**/*.js'
  .pipe $.concat 'vendors.js'
  .pipe $.if compressed, $.uglify
  .pipe $.size title: 'vendors'
  .pipe to 'build/libs'

gulp.task 'build-ng-conf', [], ->
  from ['src/main/conf/' + env + '.json']
  .pipe ng.configuration 'app.conf'
  .pipe $.rename basename: 'conf'
  .pipe $.size title: 'ng-conf'
  .pipe to 'build'

gulp.task 'build-ng-templates', [], ->
  from 'src/main/web/**/*.html'
  .pipe ng.templates filename: 'templates.js', module: 'app.templates', standalone: true
  .pipe $.if compressed, $.uglify
  .pipe $.size title: 'ng-templates'
  .pipe to 'build'

gulp.task 'build-ng-app', [], ->
  from 'src/main/web/**/*.js'
  .pipe do ng.annotate
  .pipe $.concat 'app.js'
  .pipe $.if compressed, $.uglify
  .pipe $.if compressed, $.obfuscate
  .pipe $.size title: 'ng-app'
  .pipe to 'build'

gulp.task 'clean', (cb) ->
  rm ['.tmp', 'dist'], cb

gulp.task 'build', ['clean'], (cb) ->
  sequence ['compile-sass', 'build-statics', 'build-vendors',
            'build-ng-conf', 'build-ng-templates', 'build-ng-app'], cb

gulp.task 'default', ['build']
