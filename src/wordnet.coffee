#
# Copyright 2013 Kenichi Sato
#

sax = require 'sax'

class ParserStream extends sax.SAXStream
  constructor: (@outdb, strict, opt)->
    super strict, opt

    @attr_stack = []
    @entry = null
    @synset = null
    @definition = null
    @saxis = null

    @on "error", (e)->
      console.log "error: #{e}"

    @on "opentag", (node)->
      @attr_stack.push node.attributes
      switch node.name
        when "LexicalEntry"
          @entry =
            id: node.attributes.id
            senses: []
        when "Synset"
          @synset =
            id: node.attributes.id
            baseConcept: node.attributes.baseConcept
            relations: []
        when "Definition"
          @definition =
            gloss: node.attributes.gloss
            statements: []
        when "SenseAxis"
          @saxis =
            id: node.attributes.id
            relType: node.attributes.relType
            targets: []

    @on "closetag", (name)->
      attributes = @attr_stack.pop()
      switch name
        when "Lexicon"
          @emit_event "Lexicon", attributes
        when "LexicalEntry"
          @emit_event "LexicalEntry", @entry
          @entry = null
        when "Lemma"
          @entry.lemma = attributes
        when "Sense"
          @entry.senses.push attributes

        when "Synset"
          @emit_event "Synset", @synset
          @synset = null

        when "Definition"
          @synset.definition = @definition
          @definition = null
        when "Statement"
          @definition.statements.push attributes
        when "SynsetRelation"
          @synset.relations.push attributes
        when "MonolingualExternalRef"
          @synset.monoExtRefs ||= []
          @synset.monoExtRefs.push attributes

        when "SenseAxis"
          @emit_event "SenseAxis", @saxis
          @saxis = null
        when "Target"
          @saxis.targets.push attributes

        when "LexicalResource", "GlobalInformation", "SynsetRelations", "MonolingualExternalRefs", "SenseAxes"
          # do nothing
        else
          throw name

  emit_event: (tag, value)->
    @outdb.emit tag, tag, value

exports.ParserStream = ParserStream
