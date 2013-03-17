#
# Copyright 2013 Kenichi Sato
#
riakjs = require 'riak-js'
events = require 'events'

class DbPlugin_Riak extends events.EventEmitter
  constructor: (riak_opt)->
    super()
    riak_opt ||= {}
    @db = riakjs.getClient riak_opt

    @pending_count = 0
    @pause = false

    instrument =
      'riak.request.start': (event)=>
        @pending_count += 1
        #console.log 'start', event.path
        #console.log @pending_count
        if not @pause and @pending_count > 1024*8
          @pause = true
      'riak.request.finish': (event)=>
        @pending_count -= 1
        #console.log 'finish', event.path
        #console.log @pending_count
        if @pause and @pending_count < 10
          @pause = false
          @emit 'resume'           

    @db.registerListener instrument

  store_info: (data)->
    @dbname = "wordnet-#{data.language}-#{data.version}"
    console.log @dbname
    for k, v of data
      @db.save @dbname, k, v

  store_entry: (data)->
    @db.save @dbname, data.id, data

exports.DbPlugin_Riak = DbPlugin_Riak
