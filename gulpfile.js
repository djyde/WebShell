var gulp = require('gulp')
  , jade = require('gulp-jade')
  , postcss = require('gulp-postcss')
  , nested = require('postcss-nested')
  , autoprefixer = require('autoprefixer')
  , pimport = require('postcss-import')

gulp.task('default', function(){
  gulp.watch('./index.jade', ['jade'])
  gulp.watch('./style.css', ['style'])
})

gulp.task('jade', function(){
  gulp.src('./index.jade')
    .pipe(jade())
    .pipe(gulp.dest('./'))
})

gulp.task('style', function(){
  gulp.src('./style.css')
    .pipe(postcss([pimport, nested, autoprefixer]))
    .pipe(gulp.dest('./static'))
})