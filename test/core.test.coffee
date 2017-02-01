# This test written in mocha+should.js
should = require('./init');

arangojs = require 'arangojs'
qb = require 'aqb'
chance = require('chance').Chance()
arangodb = require '..'
GeoPoint = require('loopback-datasource-juggler').GeoPoint

describe 'arangodb core functionality:', () ->
  ds = null
  before () ->
    ds = getDataSource()

  describe 'connecting:', () ->
    before () ->
      simple_model = ds.define 'SimpleModel', {
        name:
          type: String
      }

      complex_model = ds.define 'ComplexModel', {
        name:
          type: String
        money:
          type: Number
        birthday:
          type: Date
        icon:
          type: Buffer
        active:
          type: Boolean
        likes:
          type: Array
        address:
          street:
            type: String
          house_number:
            type: String
          city:
            type: String
          zip:
            type: String
          country:
            type: String
        location:
          type: GeoPoint
      }, {
        arangodb:
          collection: 'Complex'
      }

    describe 'connection generator:', () ->
      it 'should create the default connection object when called with an empty settings object', (done) ->
        settings = {}

        connObj = arangodb.generateConnObject settings
        connObj.should.eql 'http://127.0.0.1:8529'
        done()

      it 'should create an connection using the connection settings when url is not set', (done) ->
        settings =
          host: 'right_host'
          port: 32768
          database: 'rightDatabase'
          username: 'rightUser'
          password: 'rightPassword'
          promise: true

        connObj = arangodb.generateConnObject settings
        connObj.should.eql 'http://rightUser:rightPassword@right_host:32768'
        done()

   describe 'authentication:', () ->
     wrongAuth = null
     it "should throw an error when using wrong credentials", (done) ->
         settings =
           password: 'wrong'
         wrongAuth = getDataSource settings
         `(function(){
             wrongAuth.connector.query('FOR year in 2010..2013 RETURN year', function (err, cursor){
               if (err)
                 throw err;
             });
          }).should.throw();`
         done()

  describe 'exposed properties:', () ->
    it 'should expose a property "db" to access the driver directly', (done) ->
      ds.connector.db.should.be.not.null
      ds.connector.db.should.be.Object
      ds.connector.db.should.be.arangojs
      done()

    it 'should expose a property "qb" to access the query builder directly', (done) ->
      ds.connector.qb.should.not.be.null
      ds.connector.qb.should.be.qb
      done()

    it 'should expose a property "api" to access the HTTP API directly', (done) ->
      ds.connector.api.should.not.be.null
      ds.connector.api.should.be.Object
      done()

    it 'should expose a function "version" which callback with the version of the database', (done) ->
      ds.connector.getVersion (err, result) ->
        done err if err
        result.should.exist
        result.should.have.keys 'server', 'version'
        result.version.should.match /[0-9]+\.[0-9]+\.[0-9]+/
        done()

  describe 'connector details:', () ->
    it 'should provide a function "getTypes" which returns the array ["db", "nosql", "arangodb"]', (done) ->
      types = ds.connector.getTypes()
      types.should.not.be.null
      types.should.be.Array
      types.length.should.be.above(2)
      types.should.eql ['db', 'nosql', 'arangodb']
      done()

    it 'should provide a function "getDefaultIdType" that returns String', (done) ->
      defaultIdType = ds.connector.getDefaultIdType()
      defaultIdType.should.not.be.null
      defaultIdType.should.be.a.class
      done()

    it "should convert ArangoDB Types to the respective Loopback Data Types", (done) ->
      firstName = chance.first()
      lastName = chance.last()
      birthdate = chance.birthday({american: false})
      money = chance.integer {min: 100, max: 1000}
      lat = chance.latitude()
      lng = chance.longitude()
      fromDB =
        name:
          first: firstName
          last: lastName
        profession: 'Node Developer'
        money: money
        birthday: birthdate
        icon: new Buffer('a20').toJSON()
        active: true
        likes: ['nodejs', 'loopback']
        location:
          lat: lat
          lng: lng

      jsonData = ds.connector.fromDatabase 'ComplexModel', fromDB
      expected =
        name:
          first: firstName
          last: lastName
        profession: 'Node Developer'
        money: money
        birthday: birthdate
        icon: new Buffer('a20')
        active: true
        likes: ['nodejs', 'loopback']
        location: new GeoPoint {lat: lat, lng: lng}

      jsonData.should.eql expected
      done()

  describe 'connector access', () ->
    it "should get the collection name from the name of the model", (done) ->
      simpleCollection = ds.connector.getCollectionName 'SimpleModel'
      simpleCollection.should.not.be.null
      simpleCollection.should.be.a.String
      simpleCollection.should.eql 'SimpleModel'

      done()

    it "should get the collection name from the 'name' property on the 'arangodb' property", (done) ->
      complexCollection = ds.connector.getCollectionName 'ComplexModel'
      complexCollection.should.not.be.null
      complexCollection.should.be.a.String
      complexCollection.should.eql 'Complex'

      done()

  describe 'querying', () ->
    it "should execute a AQL query with no variables provided as a string", (done) ->
      aql_query_string = [
        "/* Returns the sequence of integers between 2010 and 2013 (including) */",
        "FOR year IN 2010..2013",
        " RETURN year"
      ].join("\n")

      ds.connector.db.query aql_query_string, (err, cursor) ->
        done err if err
        cursor.should.exist
        cursor.all (err, values) ->
          done err if err
          values.should.not.be.null
          values.should.be.a.Array
          values.should.eql [2010, 2011, 2012, 2013]
          done()

    it "should execute a AQL query with bound variables provided as a string", (done) ->
      aql_query_string = [
        "/* Returns the sequence of integers between 2010 and 2013 (including) */",
        "FOR year IN 2010..2013",
        "  LET following_year = year + @difference",
        "  RETURN { year: year, following: following_year }"
      ].join("\n")

      ds.connector.db.query aql_query_string, {difference: 1}, (err, cursor) ->
        done err if err
        cursor.should.exist
        cursor.all (err, values) ->
          done err if err
          values.should.not.be.null
          values.should.be.a.Array
          values.should.eql [{year: 2010, following: 2011}, {year: 2011, following: 2012},
            {year: 2012, following: 2013}, {year: 2013, following: 2014}]
          done()

    it "should execute a AQL query with no variables provided using the query builder object", (done) ->
      aql_query_object = ds.connector.qb.for('year').in('2010..2013').return('year')

      ds.connector.db.query aql_query_object, (err, cursor) ->
        done err if err
        cursor.should.exist
        cursor.all (err, values) ->
          done err if err
          values.should.not.be.null
          values.should.be.a.Array
          values.should.eql [2010, 2011, 2012, 2013]
          done()

    it "should execute a AQL query with bound variables provided using the query builder object", (done) ->
      qb = ds.connector.qb
      aql = qb.for('year').in('2010..2013')
      aql = aql.let 'following', qb.add(qb.ref('year'), qb.ref('@difference'))
      aql = aql.return {
        year: qb.ref('year'),
        following: qb.ref('following')
      }

      ds.connector.db.query aql, {difference: 1}, (err, cursor) ->
        done err if err
        cursor.should.exist
        cursor.all (err, values) ->
          done err if err
          values.should.not.be.null
          values.should.be.a.Array
          values.should.eql [{year: 2010, following: 2011}, {year: 2011, following: 2012},
            {year: 2012, following: 2013}, {year: 2013, following: 2014}]
          done()
