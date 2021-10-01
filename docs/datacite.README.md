# DataCite DOI implementation

## DataCite Documentation and References

- DataCite Rest API Guide: https://support.datacite.org/docs/api
- DataCite REST API Reference: https://support.datacite.org/reference/introduction
- DataCite Metadata Schema 4.4: https://schema.datacite.org/meta/kernel-4.4/

## DataCite background info

### DataCite DOI states

- draft
- findable
- registered

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

There is also a helper class, HyacinthMetadata
This class wraps the Digital Object Data from a DigitalObject and provides methods to access metadata.

To use the Datacite adapter as your external identifier adapter, your hyacinth.yml configuration should include something like this:

```
production:
  external_identifier_adapter:
    type: Datacite
    rest_api: 'https://api.test.datacite.org'
    user: apitest
    password: apitest
    prefix: '10.33555'
    default_properties:
      creators:
        - name: 'Placeholder Creator'
      publisher: 'Columbia University'
      types:
        - resourceTypeGeneral: 'Text'
      titles:
        - title: 'Placeholder Title'
    data_mapping:
      genre_uri:
        'http://vocab.getty.edu/aat/300048715':
          resourceTypeGeneral: Text
          resourceType: Article
    logger:
      log_level: debug
      dev: 'datacite.log'
```
The above example references the Datacite public test URL and test credentials.  In production, you'll want to swap these for the production URL and real credentials.

## Running implementation in rails console using higher-level functionality

### Using Datacite#mint_doi to mint a draft DOI

This is the same method that will be used in the client code in Hyacinth to mint a DOI

```
2.6.4 :001 > config = Rails.config_for(:hyacinth).deep_symbolize_keys[:external_identifier_adapter]
2.6.4 :002 > dc = Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite.new(config)
 => #<Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite:0x000055f03ff47510>
2.6.4 :003 > doi = dc.mint
 => "10.33555/qg65-ty77"
2.6.4 :004 > puts doi
10.33555/qg65-ty77
 => nil
 ```

## Running implementation in rails console using lower-level functionality

The functionality used here is supplied by lower-level classes that are normally not called by client code. However, they offer
more granular functionality which may be useful when debugging

### Get info for a given DOI

```
2.6.4 :001 > conf.return_format = "" # supress output for clarity
2.6.4 :002 > api =  Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Api.new(rest_api: 'https://api.test.datacite.org', prefix: '10.33555', user: 'USERNAME', password: 'PASSWORD')
2.6.4 :003 > resp = api.get_doi('10.33555/9fa4-xx07')
2.6.4 :004 > puts resp.body
{"data":{"id":"10.33555/9fa4-xx07","type":"dois","attributes":{"doi":"10.33555/9fa4-xx07","prefix":"10.33555","suffix":"9fa4-xx07", --REST REMOVED for BREVITY---
```

### Mint a reserved DOI

```
2.6.4 :001 > conf.return_format = "" # supress output for clarity
2.6.4 :002 > api =  Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Api.new(rest_api: 'https://api.test.datacite.org', prefix: '10.33555', user: 'USERNAME', password: 'PASSWORD')
2.6.4 :003 > resp = api.create_doi('{"data":{"type":"dois","attributes":{"prefix":"10.33555"}}}')
```

Note that the Api libraries are designed to operate against the external_identifier_adapter module configuration. In the example above, we passed in the payload content as json. In the example below, we will use a Data instance and the adapter configuration:

```
2.6.4 :001 > config = Rails.config_for(:hyacinth).deep_symbolize_keys[:external_identifier_adapter]
2.6.4 :002 > api =  Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Api.new(config)
2.6.4 :003 > data = Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Data.new(config)
2.6.4 :004 > payload = data.build_mint(nil, :draft)
2.6.4 :005 > resp = api.create_doi(payload)
2.6.4 :006 > puts api.parse_doi_from_api_response_body(resp.body)
10.33555/6zy2-pw34
```

The Api class supplies methods to parse out relevant information from the response, as can be seen above.

### Update an existing DOI

```
2.6.4 :001 > conf.return_format = "" # supress output for clarity
2.6.4 :002 > api =  Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Api.new(rest_api: 'https://api.test.datacite.org', prefix: '10.33555', user: 'USERNAME', password: 'PASSWORD')
2.6.4 :003 > attributes = { prefix: "10.33555" }
2.6.4 :004 > attributes[:titles] = [{ title: "A Great Book"}]
2.6.4 :005 > attributes[:creators] = ['Mouse, Katie', 'Mouse, John'].map {|v| { name: v } }
2.6.4 :006 > attributes[:publicationYear] = 2021
2.6.4 :007 > attributes[:publisher] = 'Columbia University'
2.6.4 :008 > attributes[:types] = { resourceTypeGeneral: 'Text' }
2.6.4 :009 > attributes[:url] = "https://www.columbia.edu"
2.6.4 :010 > data = { type: :"dois", attributes: attributes }
2.6.4 :011 > payload = JSON.generate(data: data)
2.6.4 :012 > resp = api.update_doi('10.33555/6zy2-pw34', payload)
2.6.4 :013 > puts resp.body
{"data":{"id":"10.33555/6zy2-pw34","type":"dois","attributes":{"doi":"10.33555/6zy2-pw34","prefix":"10.33555","suffix":"6zy2-pw34","identifiers":[],"alternateIdentifiers":[],"creators":[{"name":"Mouse, Katie","affiliation":[],"nameIdentifiers":[]},{"name":"Mouse, John","affiliation":[],"nameIdentifiers":[]}],"titles":[{"title":"A Great Book"} ETC...
```

