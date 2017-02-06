# This test written in mocha+should.js
should = require('./init');

GeoPoint = require('loopback-datasource-juggler').GeoPoint

describe 'arangodb migration functionality', () ->

  before () ->
    ds = getDataSource()

    inline_model = ds.define 'InlineModel',{
      hashIndex1:
        type: String
        index: true

      hashIndex2:
        type: String
        index:
          hash: true

      hashIndexSparsed:
        type: String
        index:
          hash:
            sparse: true

      hashIndexUnique:
        type: String
        index:
          hash:
            unique: true

      skiplist:
        type: String
        index:
          skiplist: true

      skiplistSparsed:
        type: String
        index:
          skiplist:
            sparse: true

      skiplistUnique:
        type: String
        index:
          skiplist:
            unique : true

      fulltext:
        type: String
        index:
          fulltext: true

      fulltextMinWordLength:
        type: String
        index:
          fulltext:
            minWordLength: 4
      capSizeOnly:
        type: String
        index:
          size: 10

      capByteSize:
        type: String
        index:
          size: 10
          byteSize: 100
      geo:
        type: GeoPoint


    }

    explicit_model = ds.define 'ExplicitModel',{
      hashIndex1:
        type: String
      hashIndex2:
        type: String
      hashIndexSparsed:
        type: String
      hashIndexUnique:
        type: String
      skiplist:
        type: String
      skiplistSparsed:
        type: String
      skiplistUnique:
        type: String
      fulltext:
        type: String
      fulltext:
        type: String
      fulltextMinWordLength:
        type: String
      capSizeOnly:
        type: String
      capByteSize:
        type: String
    }


  describe 'inline defined indexes', () ->
    describe 'hash index', () ->
      it 'should define a hash index when defined as boolean "index":true'

      it 'should define a hash index when defined as object with key "hash": true'


    describe 'skiplist index', () ->
    describe 'fulltext index', () ->
    describe 'geo index', () ->
    describe 'cap constraint index', () ->
    describe 'explicit defined indexes', () ->
    describe 'hash index', () ->
    describe 'skiplist index', () ->
    describe 'fulltext index', () ->
    describe 'cap constraint index', () ->


  describe 'hash indexes:', () ->
    describe 'defined explicit:', () ->
      it 'should define a hash index from model settings'

      it 'should define a sparsed hash index from model settings'

    describe 'defined inline:', () ->
      it 'should define a hash index from property settings'

      it 'should define a sparsed hash index from property settings'


  describe 'skiplist indexes:', () ->
    describe 'defined inline:', () ->
      it 'should define a skiplist index from model settings'

      it 'should define a sparsed skiplist index from model settings'


    describe 'defined explicit:', () ->
      it 'should define a skiplist indexes from property settings'

      it 'should define a sparsed skiplist indexes from property settings'



  describe 'fulltext indexes:', () ->
    describe 'defined inline:', () ->
      it 'should define a fulltext index from model settings'


      it 'should define a fulltext index from model settings'


    describe 'defined explicit:', () ->

  describe 'geo indexes:', () ->
    describe 'defined inline:', () ->

    describe 'defined explicit:', () ->

  describe 'cap indexes:', () ->
    describe 'defined inline:', () ->

    describe 'defined explicit:', () ->
