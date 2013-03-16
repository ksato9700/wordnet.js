#
# Copyright 2013 Kenichi Sato
#

sax = require 'sax'
parserStream = sax.createStream true

events = require 'events'
emitter = new events.EventEmitter()

parserStream.on "error", (e)->
  console.log "error: #{e}"

attributes = []
entry = null

parserStream.on "opentag", (node)->
  attributes.push node.attributes
  switch node.name
    when "LexicalEntry"
      entry =
        id: node.attributes.id
        senses: []

parserStream.on "closetag", (name)->
  attribute = attributes.pop()
  switch name
    when "Lexicon"
      emitter.emit "Lexicon", attribute
    when "LexicalEntry"
      emitter.emit "LexicalEntry", entry
      entry = null
    when "Lemma"
      entry.lemma = attribute
    when "Sense"
      entry.senses.push attribute

exports.parserStream = parserStream
exports.emitter = emitter