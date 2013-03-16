#
# Copyright 2013 Kenichi Sato
#
wordnet = require '../src/wordnet'
fs = require 'fs'
assert = require 'assert'

#
# expected value
# 

entries =
  w00000:
    lemma: {writtenForm: '名詞１', partOfSpeech: 'n'}
    senses: [
      {id: 'w00000_s00000', synset: 's00000'},
      {id: 'w00000_s00001', synset: 's00001'}
    ]
  w00001:
    lemma: {writtenForm: '名詞２', partOfSpeech: 'n'}
    senses: [
      {id: 'w00001_s00002', synset: 's00002'}
    ]
  w00002:
    lemma: {writtenForm: '動詞１', partOfSpeech: 'v'}
    senses:[
      {id: 'w00002_s00003', synset: 's00003'},
      {id: 'w00002_s00004', synset: 's00004'},
      {id: 'w00002_s00005', synset: 's00005'},
      {id: 'w00002_s00006', synset: 's00006'},
      {id: 'w00002_s00007', synset: 's00007'}
    ]
  w00003:
    lemma: {writtenForm: '動詞２', partOfSpeech: 'v'}
    senses:[
      {id: 'w00003_s00008', synset: 's00008'}
    ]

lexicon =
  languageCoding: 'ISO 639-3'
  label: 'Lexicon Label'
  language: 'jpn'
  owner: 'ksato9700'
  version: '1.0'

fs.createReadStream("test/wn_test.xml")
.pipe wordnet.parserStream

wordnet.emitter.on "Lexicon", (data)->
  for k, v of lexicon
    assert.equal data[k], v

wordnet.emitter.on "LexicalEntry", (data)->
  assert entries[data.id], "id=#{data.id} is not expected"
  for k,v of entries[data.id]
    assert.deepEqual data[k], v
