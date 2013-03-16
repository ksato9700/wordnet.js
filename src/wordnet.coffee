#
# Copyright 2013 Kenichi Sato
#

sax = require 'sax'
parserStream = sax.createStream true

events = require 'events'
emitter = new events.EventEmitter()

parserStream.on "error", (e)->
  console.log "error: #{e}"

attr_stack = []
entry = null
synset = null
definition = null
saxis = null

parserStream.on "opentag", (node)->
  attr_stack.push node.attributes
  switch node.name
    when "LexicalEntry"
      entry =
        id: node.attributes.id
        senses: []
    when "Synset"
      synset =
        id: node.attributes.id
        baseConcept: node.attributes.baseConcept
        relations: []
    when "Definition"
      definition =
        gloss: node.attributes.gloss
        statements: []
    when "SenseAxis"
      saxis =
        id: node.attributes.id
        relType: node.attributes.relType
        targets: []

parserStream.on "closetag", (name)->
  attributes = attr_stack.pop()
  switch name
    when "Lexicon"
      emitter.emit "Lexicon", attributes
    when "LexicalEntry"
      emitter.emit "LexicalEntry", entry
      entry = null
    when "Lemma"
      entry.lemma = attributes
    when "Sense"
      entry.senses.push attributes

    when "Synset"
      emitter.emit "Synset", synset
      synset = null
    when "Definition"
      synset.definition = definition
      definition = null
    when "Statement"
      definition.statements.push attributes
    when "SynsetRelation"
      synset.relations.push attributes
    when "MonolingualExternalRef"
      synset.monoExtRefs ||= []
      synset.monoExtRefs.push attributes

    when "SenseAxis"
      emitter.emit "SenseAxis", saxis
      saxis = null
    when "Target"
      saxis.targets.push attributes

    when "LexicalResource", "GlobalInformation", "SynsetRelations", "MonolingualExternalRefs", "SenseAxes"
      # do nothing
    else
      throw name

exports.parserStream = parserStream
exports.emitter = emitter