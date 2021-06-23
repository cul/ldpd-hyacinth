# DataCite DOI implementation

## DataCite Documentation and References

- DataCite Rest API Guide: https://support.datacite.org/docs/api
- DataCite REST API Reference: https://support.datacite.org/reference/introduction
- DataCite Metadata Schema 4.4: https://schema.datacite.org/meta/kernel-4.4/

## DataCite background info

### DOI states, EZID vs DataCite

- reserved (EZID) <==> draft (DataCite)
- public (EZID) <==> findable (DataCite)
- unavailable (EZID) <==> registered (DataCite)

### Required DataCite Properties

DataCite requires the following properties for a DOI in the findable state (including minting a findable DOI)

- creators
- publisher
- publication year
- resource type general (controlled?)
- title
- url

## Introduction to the overall implementation of DataCite DOIs in Hyacinth

There are three main classes in this implementation

- Datacite::RestApi::V2::Api
This class is the direct interface to the DataCite REST API. It includes three methods, one each for the GET, POST, and PUT requests that can
be sent to the DataCite REST API. If included/relevant, the request body is given as an argument in JSON format.
- Datacite::RestApi::V2::Data
This class is used to populate and construct the JSON structure that will be sent via a request body to the DataCite REST API (see above)
- Datacite
This is the class that is used by the rest of Hyacinth to mint and update DOIs. It makes use of the above two classes. This class also contains
the mapping functionality between Hyacinth fields and DataCite properties.

There is also a legacy class, Datacite::Metadata
This class wraps the Digital Object Data from a DigitalObject and provides methods to access metadata.
NOTE: this class SHOULD move out of the datacite subdir since it is independent of the datacite functionality. Also, I would prefer to
rename it HyacinthMetadata. Finally, this class should be preferred over a Digital Object as an argument to doi-related methods that need
access to the metadata within a Digital Object since it offers a standardized interface to the metadata.

## Running implementation in rails console using higher-level functionality

### Using Datacite#mint_doi to mint a draft DOI

This is the same method that will be used in the client code in Hyacinth to mint a DOI

```
2.6.4 :001 > dc = Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite.new
 => #<Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite:0x000055f03ff47510>
2.6.4 :002 > doi = dc.mint_doi
 => "10.33555/qg65-ty77"
2.6.4 :003 > puts doi
10.33555/qg65-ty77
 => nil
 ```

## Running implementation in rails console using lower-level functionality

The functionality used here is supplied by lower-level classes that are normally not called by client code. However, they offer
more granular functionality which may be useful when debugging

### get info for a given DOI (GET)

```
2.6.4 :001 > conf.return_format = "" # supress output for clarity
2.6.4 :002 > api =  Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Api.new('https://api.test.datacite.org','USERNAME','PASSWORD')
2.6.4 :003 > resp = api.get_dois('10.33555/9fa4-xx07')
2.6.4 :004 > puts resp.body
{"data":{"id":"10.33555/9fa4-xx07","type":"dois","attributes":{"doi":"10.33555/9fa4-xx07","prefix":"10.33555","suffix":"9fa4-xx07", --REST REMOVED for BREVITY---
```

### mint a reserved DOI (POST)

```
2.6.4 :001 > conf.return_format = "" # supress output for clarity
2.6.4 :002 > api =  Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Api.new
2.6.4 :003 > resp = api.post_dois('{"data":{"type":"dois","attributes":{"prefix":"10.33555"}}}')
```

Note that if no arguments are given when instantiating the Api instance, the information in the datacite config file will be used
Note that in the example above, we passed in the payload content as json. In the example below, we will use a Data instance:

```
2.6.4 :001 > conf.return_format = "" # supress output for clarity
2.6.4 :002 > api =  Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Api.new('https://api.test.datacite.org','USERNAME','PASSWORD')
2.6.4 :003 > data = Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Data.new('10.33555')
2.6.4 :004 > data.build_mint(:draft)
2.6.4 :005 > resp = api.post_dois(data.generate_json_payload)
2.6.4 :008 > puts api.parse_doi_from_api_response_body(resp.body)
10.33555/6zy2-pw34
2.6.4 :009 >
```

The Api class supplies methods to parse out relevant information from the response, as can be seen above.

### Update an existing DOI (PUT)

```
2.6.4 :001 > conf.return_format = "" # supress output for clarity
2.6.4 :002 > api =  Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Api.new('https://api.test.datacite.org','USERNAME','PASSWORD')
2.6.4 :003 > data = Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Data.new
2.6.4 :004 > data.creators = ['Mouse, Katie', 'Mouse, John']
2.6.4 :005 > data.publisher = 'Columbia University'
2.6.4 :006 > data.publication_year = 2021
2.6.4 :007 > data.resource_type_general = 'Text'
2.6.4 :008 > data.title = "A Great Book"
2.6.4 :009 > data.url = "https://www.columbia.edu"
2.6.4 :010 > data.build_metadata_update
2.6.4 :012 > resp = api.put_dois('10.33555/6zy2-pw34', data.generate_json_payload)
2.6.4 :013 > puts resp.body
{"data":{"id":"10.33555/6zy2-pw34","type":"dois","attributes":{"doi":"10.33555/6zy2-pw34","prefix":"10.33555","suffix":"6zy2-pw34","identifiers":[],"alternateIdentifiers":[],"creators":[{"name":"Mouse, Katie","affiliation":[],"nameIdentifiers":[]},{"name":"Mouse, John","affiliation":[],"nameIdentifiers":[]}],"titles":[{"title":"A Great Book"} ETC...
```

As seen in the example above, if the prefix is not passed when the Data is instantiated (as it was in the previous example), it will get it from the config file.

