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
paths =
  bower: 'src/main/vendors/bower_components', web: 'src/main/web', build: 'build'

gulp.task 'compile:sass', [], ->
  from 'src/main/web/**/*.scss'
  .pipe css.fromSASS ({
    sourcemap: true,
    includePaths: [
      paths.bower + '/bourbon/app/assets/stylesheets',
      paths.bower + '/bitters/app/assets/stylesheets',
      paths.bower + '/neat/app/assets/stylesheets',
      paths.bower + '/fontawesome/scss',
      paths.web + '/styles'
    ]
  })
  .pipe $.concat 'styles.css'
  .pipe $.if compressed, css.minify
  .pipe $.size title: 'styles'
  .pipe to paths.build
  .pipe reload stream: true

gulp.task 'build:statics-i18n', [], ->
  from [paths.web + '/i18n/*.json']
  .pipe to paths.build + '/i18n/'

gulp.task 'build:statics', ['build:statics-i18n'], ->
  from [paths.web + '/*.html']
  .pipe to paths.build

gulp.task 'build:vendors', [], ->
  from do bowerFiles
  .pipe $.filter '**/*.js'
  .pipe $.concat 'vendors.js'
  .pipe $.if compressed, $.uglify
  .pipe $.size title: 'vendors'
  .pipe to paths.build + '/libs'

gulp.task 'build:ng-conf', [], ->
  from ['src/main/conf/' + env + '.json']
  .pipe ng.configuration 'app.conf'
  .pipe $.rename basename: 'conf'
  .pipe $.size title: 'ng-conf'
  .pipe to paths.build

gulp.task 'build:ng-templates', [], ->
  from paths.web + '/**/*.html'
  .pipe ng.templates filename: 'templates.js', module: 'app.templates', standalone: true
  .pipe $.if compressed, $.uglify
  .pipe $.size title: 'ng-templates'
  .pipe to paths.build

gulp.task 'build:ng-app', [], ->
  from paths.web + '/**/*.js'
  .pipe do ng.annotate
  .pipe $.concat 'app.js'
  .pipe $.if compressed, $.uglify
  .pipe $.if compressed, $.obfuscate
  .pipe $.size title: 'ng-app'
  .pipe to paths.build

gulp.task 'hints:html', ->
  from paths.web + '/*.html'
  .pipe reload stream: true, once: true
  .pipe do $.htmlhint
  .pipe do $.htmlhint.reporter

gulp.task 'hints:js', ->
  from paths.web + '/**/*.js'
  .pipe reload stream: true, once: true
  .pipe $.jshint '.jshintrc'
  .pipe $.jshint.reporter 'jshint-stylish'
  .pipe $.if !browserSync.active, -> $.jshint.reporter 'fail'

gulp.task 'package:ng', ['build:ng-conf', 'build:ng-templates', 'build:ng-app'], ->
  from paths.build + '/*.js'
  .pipe $.concat 'app.final.js'
  .pipe to paths.build

gulp.task 'clean', (cb) ->
  rm ['build', '*.log'], cb

gulp.task 'build', ['clean'], (cb) ->
  sequence ['compile:sass', 'hints:js', 'hints:html', 'build:statics', 'build:vendors',
            'build:ng-conf', 'build:ng-templates', 'build:ng-app', 'package:ng'], cb

gulp.task 'default', ['build']
