#
# Copyright 2013 Kenichi Sato
#
ParserStream = require('../src/wordnet').ParserStream
DbPlugin_Riak = require('../src/dbplugin_riak').DbPlugin_Riak

fs = require 'fs'
assert = require 'assert'
async = require 'async'

dbplugin_riak = new DbPlugin_Riak()
parserStream = new ParserStream dbplugin_riak, true

#
# expected values
#
KEYS = [
  'label' 
  'language',
  'languageCoding',
  'owner',
  's00000',
  's00001',
  's10000',
  'sa00000',
  'sa00001',
  'version',
  'w00000',
  'w00001',
  'w00002',
  'w00003'
]

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

  languageCoding: 'ISO 639-3'
  label: 'Lexicon Label'
  language: 'jpn'
  owner: 'ksato9700'
  version: '0.1-test'

db = require('riak-js').getClient()
buckets = 'wordnet-jpn-0.1-test'


async.series [
  #
  # remove the data first
  #
  (callback)->
    async.each KEYS, (key, cb)->
      db.remove buckets, key, (err, data)->
        if not err or err.statusCode == 404
          cb null
        else
          cb err
    , (err)->
      callback err
  ,
  #
  # read from a file and store it to Riak DB
  #
  (callback)->
    s = fs.createReadStream("test/wn_test.xml").pipe parserStream
    s.on 'done', ->
      callback null
  ,

  #
  # verify the result
  #

  # keys
  (callback)->
    keys = []
    keys_event = db.keys buckets
    keys_event.on 'keys', (keylist)->
     keys = keys.concat keylist
    keys_event.on 'end', (keylist)->
      keys.sort()
      assert.deepEqual keys, KEYS
      callback null
    keys_event.start()
  ,
  # number of entries
  (callback)->
    db.count buckets, (err, count)->
      assert.equal err, null
      assert.equal count, KEYS.length
      callback null
  ,
  # compare values
  (callback)->
    async.each KEYS, (key, cb)->
      db.get buckets, key, (err, data)->
        assert.equal err, null
        assert.deepEqual data, exp[key]
        cb null
    , (err)->
        callback err
  ], (err, results)->
    assert.equal err, null
