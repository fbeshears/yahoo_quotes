#Cakefile


{exec} = require 'child_process'

task 'build', 'Build project from src/*.coffee to lib/*.js', ->
  exec 'coffee --compile --output lib/ src/', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr



task 'test', 'Run test of iso_date_parser', ->
  exec 'coffee ./test/test.coffee',(err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr





