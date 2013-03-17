#
# Copyright 2013 Kenichi Sato
#

sax = require 'sax'

class ParserStream extends sax.SAXStream
  constructor: (@outdb, strict, opt)->
    super strict, opt

    @attr_stack = []
    @entry_stack = []

    @on "error", (e)->
      console.log "error: #{e}"

    @on "opentag", (node)->
      @attr_stack.unshift node.attributes
      switch node.name
        when "Lexicon"
          @emit_event "Lexicon", node.attributes
        when "LexicalEntry"
          @entry_stack.unshift
            id: node.attributes.id
            senses: []
        when "Synset"
          @entry_stack.unshift
            id: node.attributes.id
            baseConcept: node.attributes.baseConcept
            relations: []
        when "Definition"
          @entry_stack.unshift
            gloss: node.attributes.gloss
            statements: []
        when "SenseAxis"
          @entry_stack.unshift
            id: node.attributes.id
            relType: node.attributes.relType
            targets: []

    @on "closetag", (name)->
      attributes = @attr_stack.shift()
      switch name
        when "LexicalEntry"
          @emit_event "LexicalEntry", @entry_stack.shift()
        when "Lemma"
          @entry_stack[0].lemma = attributes
        when "Sense"
          @entry_stack[0].senses.push attributes

        when "Synset"
          @emit_event "Synset", @entry_stack.shift()

        when "Definition"
          definition = @entry_stack.shift()
          @entry_stack[0].definition = definition
        when "Statement"
          @entry_stack[0].statements.push attributes
        when "SynsetRelation"
          @entry_stack[0].relations.push attributes
        when "MonolingualExternalRef"
          @entry_stack[0].monoExtRefs ||= []
          @entry_stack[0].monoExtRefs.push attributes

        when "SenseAxis"
          @emit_event "SenseAxis", @entry_stack.shift()
        when "Target"
          @entry_stack[0].targets.push attributes

        when "LexicalResource", "GlobalInformation", "SynsetRelations", "MonolingualExternalRefs", "SenseAxes", "Lexicon"
          # do nothing
        else
          throw name

  emit_event: (tag, value)->
    @outdb.emit tag, tag, value

exports.ParserStream = ParserStream
