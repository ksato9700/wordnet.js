#
# Copyright 2013 Kenichi Sato
#
wordnet = require '../src/wordnet'
fs = require 'fs'
assert = require 'assert'
events = require 'events'

#
# expected value
# 

exp =
  w00000:
    id: 'w00000'
    lemma: {writtenForm: '名詞１', partOfSpeech: 'n'}
    senses: [
      {id: 'w00000_s00000', synset: 's00000'},
      {id: 'w00000_s00001', synset: 's00001'}
    ]
  w00001:
    id: 'w00001'
    lemma: {writtenForm: '名詞２', partOfSpeech: 'n'}
    senses: [
      {id: 'w00001_s00002', synset: 's00002'}
    ]
  w00002:
    id: 'w00002'
    lemma: {writtenForm: '動詞１', partOfSpeech: 'v'}
    senses:[
      {id: 'w00002_s00003', synset: 's00003'},
      {id: 'w00002_s00004', synset: 's00004'},
      {id: 'w00002_s00005', synset: 's00005'},
      {id: 'w00002_s00006', synset: 's00006'},
      {id: 'w00002_s00007', synset: 's00007'}
    ]
  w00003:
    id: 'w00003'
    lemma: {writtenForm: '動詞２', partOfSpeech: 'v'}
    senses:[
      {id: 'w00003_s00008', synset: 's00008'}
    ]

  s00000:
    id: 's00000'
    baseConcept: '1'
    relations: [
      {targets: 's00001', relType: 'sim'}
    ]
    definition:
      gloss: '定義１'
      statements: [
        {example: '例１' },
        {example: '例２' },
        {example: '例３' }
      ]
  s00001:
    id: 's00001'
    baseConcept: '2',
    relations: [
      {targets: 's00002', relType: 'mmem'},
      {targets: 's00003', relType: 'hype'},
      {targets: 's00004', relType: 'mmem'}
    ]
    definition:
      gloss: '定義２',
      statements: [
        {example: '例４'}
        {example: '例５'}
      ]
  s10000:
    id: 's10000'
    baseConcept: '3',
    monoExtRefs: [
      {externalSystem: 'abc', externalReference: 'xyz', relType: 'at'},
      {externalSystem: 'efg', externalReference: 'xyz', relType: 'at'},
    ]
    relations: [
      {targets: 's10000', relType: 'self'},
    ]

  sa00000:
    id: 'sa00000'
    relType: 'eq_synonym'
    targets: [
      {ID: 's00000'}
      {ID: 's00001'}
    ]
  sa00001:
    id: 'sa00001'
    relType: 'eq_synonym'
    targets: [
      {ID: 's00002'}
      {ID: 's00003'}
    ]

info =
  languageCoding: 'ISO 639-3'
  label: 'Lexicon Label'
  language: 'jpn'
  owner: 'ksato9700'
  version: '0.1-test'

class DbPlugin_Sample extends events.EventEmitter
  constructor: ->
    super()
    @pause = false

  store_info: (data)->
    assert.deepEqual data, info

  store_entry: (data)->
    assert.deepEqual data, exp[data.id]

dbplugin_sample = new DbPlugin_Sample()
parserStream = new wordnet.ParserStream dbplugin_sample, true

fs.createReadStream("test/wn_test.xml")
.pipe parserStream
