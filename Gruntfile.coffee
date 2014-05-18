module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    coffeelint:
      app:
        files:
          src: [
            'Gruntfile.coffee'
            'src/**/*.coffee'
            'test/**/*.coffee'
          ]
      options:
        max_line_length:
          value: 120
          level: 'warn'

    coffee:
      compile:
        files:
          'dist/factory.js': 'src/**/*.coffee'
      options:
        bare: yes

    watch:
      scripts:
        files: [
          'Gruntfile.coffee'
          'src/**/*.coffee'
          'test/**/*.coffee'
        ]
        tasks: ['test']
        options:
          interrupt: yes

    simplemocha:
      all:
        src: ['test/**/*.coffee']
      options:
        reporter: 'spec'
        ui: 'bdd'

    uglify:
      build:
        src: 'dist/factory.js'
        dest: 'dist/factory.min.js'

    usebanner:
      build:
        options:
          position: 'top'
          banner: '/*! <%= pkg.name %> <%= pkg.version %> */\n'
          linebreak: false
        files:
          src: ['dist/factory*.js']

    env:
      coverage:
        COVER: true

    instrument:
      files : ['dist/factory.js']

    makeReport:
      src: 'build/reports/coverage.json'
      options:
        print: 'detail'

    clean:
      coverage:
        ['build/**/*']

  grunt.loadNpmTasks 'grunt-banner'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-simple-mocha'
  grunt.loadNpmTasks 'grunt-env'
  grunt.loadNpmTasks 'grunt-istanbul'

  grunt.registerTask 'test', [
    'coffeelint'
    'coffee'
    'simplemocha'
  ]

  grunt.registerTask 'build', [
    'test'
    'uglify'
    'usebanner'
  ]

  grunt.registerTask 'coverage', [
    'clean:coverage'
    'env:coverage'
    'coffee'
    'instrument'
    'simplemocha'
    'storeCoverage'
    'makeReport'
  ]
