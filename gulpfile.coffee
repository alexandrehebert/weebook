'use strict';


# use dependencies

gulp = require 'gulp'
task = gulp.task;
from = gulp.src
to = gulp.dest
$ = do require 'gulp-load-plugins'
$.if = require 'gulp-if-else'
log = $.util.log
rm = require 'del'
sequence = require 'run-sequence'
karma = (require 'karma').server
css =
  minify: (require 'gulp-minify-css')
  compile: (require 'gulp-sass')
ng =
  annotate: (require 'gulp-ng-annotate')
  templates: (require 'gulp-ng-templates')
  configuration: (require 'gulp-ng-config')
bowerFiles = require 'main-bower-files'
browserSync = require 'browser-sync'


# more gulp files

(require 'require-dir') './gulp';


# global variables
args =
  env: if $.util.env.mode? then $.util.env.mode else 'development'
  compressed: $.util.env.mode == 'production'
  debug: $.util.env.debug?
paths =
  bower: 'src/main/vendors/bower_components'
  web: 'src/main/web'
  build: 'build'
  exploded: 'build/exploded'
  test: 'src/test'
{ reload } = browserSync


# some prints

log "Build in #{ args.env } mode."
log 'Debug is ' + (if args.debug then 'enabled' else 'disabled') + '.'
log 'Paths are : '
log paths

# preprocessing tasks

gulp.task 'compile:sass', [], ->
  from [
    paths.web + '/styles/style.scss'
  ]
  .pipe do $.sourcemaps.init
  .pipe css.compile
    errLogToConsole: args.debug
    includePaths: [
      paths.bower + '/bourbon/app/assets/stylesheets'
      paths.bower + '/bitters/app/assets/stylesheets'
      paths.bower + '/neat/app/assets/stylesheets'
      paths.bower + '/fontawesome/scss'
      paths.web + '/**/*.scss'
    ]
  .pipe $.sourcemaps.write debug: args.debug
  .pipe $.concat 'styles.css'
  .pipe $.if args.compressed, css.minify
  .pipe $.size title: 'styles'
  .pipe to paths.build
  .pipe reload stream: true


# build tasks

gulp.task 'build:statics-i18n', [], ->
  from [paths.web + '/i18n/*.json']
  .pipe to paths.build + '/i18n/'

gulp.task 'build:statics', ['build:statics-i18n'], ->
  from [paths.web + '/*.html']
  .pipe to paths.build

gulp.task 'build:vendors', [], ->
  vendorsFiles = do bowerFiles
  log vendorsFiles if args.debug
  from vendorsFiles
  .pipe $.filter '**/*.js'
  .pipe $.concat 'vendors.js'
  .pipe $.if args.compressed, $.uglify
  .pipe $.size title: 'vendors'
  .pipe to paths.build + '/libs'

gulp.task 'build:ng-conf', [], ->
  from ['src/main/conf/' + args.env + '.yml']
  .pipe do $.yaml
  .pipe ng.configuration 'app.conf'
  .pipe $.rename basename: 'conf'
  .pipe $.size title: 'ng-conf'
  .pipe to paths.exploded

gulp.task 'build:ng-templates', [], ->
  from paths.web + '/**/*.html'
  .pipe ng.templates filename: 'templates.js', module: 'app.templates', standalone: true
  .pipe $.if args.compressed, $.uglify
  .pipe $.size title: 'ng-templates'
  .pipe to paths.exploded

gulp.task 'build:ng-app', [], ->
  from paths.web + '/**/*.js'
  .pipe do ng.annotate
  .pipe $.concat 'app.js'
  .pipe $.if args.compressed, $.uglify
  .pipe $.if args.compressed, $.obfuscate
  .pipe $.size title: 'ng-app'
  .pipe to paths.exploded


# dev helpers tasks

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


# packaging tasks

gulp.task 'package:ng', [], ->
  from paths.exploded + '/*.js'
  .pipe $.concat 'app.final.js'
  .pipe to paths.build


# clean tasks

gulp.task 'clean', ['clean:before-build'], (cb) ->
  rm [
    '*.log'
  ], cb

gulp.task 'clean:before-build', (cb) ->
  rm [
    'build'
  ], cb

gulp.task 'clean:after-build', ->
  rm paths.exploded if args.compressed
  #  rm [
  #    paths.build + '/app.js'
  #    paths.build + '/templates.js'
  #    paths.build + '/conf.js'
  #  ], cb
  do $.util.beep


# tests tasks

gulp.task 'test', [], (cb) ->
  karma.start
    configFile: __dirname + '/src/test/karma.conf.coffee',
    files: [

    ],
    singleRun: true
  , cb


# final build task

gulp.task 'build', [], (cb) ->
  sequence 'clean:before-build',
    'compile:sass', ['hints:js', 'hints:html'], ['build:statics', 'build:vendors'],
    ['build:ng-conf', 'build:ng-templates', 'build:ng-app'], 'package:ng',
    'clean:after-build', cb

gulp.task 'default', ['build']
