# Hyacinth 3 Language Tags

Hyacinth has a subsystem for loading [IANA language tag data](https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry) to identify and validate language tags according to the [BCP 47 spec](https://tools.ietf.org/search/bcp47).

## Configuring System Defaults

The deployed application should include a configuration file at `config/lang.yml` with keys for `default_lang_value` (a BCP 47 tag value) and `default_lang_subtags` (property hashes of the fallback subtag data necessary to support the tag). If the subtags described in `default_lang_subtags` do not exist, they will be loaded in the language initializer. An example configuration can be seen at `config/templates/lang.template.yml`.

## Models

The subsystem makes use of two database models: `Language::Tag` and `Language::Subtag`.

### Language::Tag

Tags are the fully composed values representing language data, unless they are of `type = 'grandfathered'`, they represent only an intersection of existing subtags. This means that Language::Tag records can generally be created lazily if the subtag corpus has been loaded, as indicated by `type = 'redundant'`.

The API entry point for such creation is `Language::Tag.for(tag_value)`, where `tag_value` is a string for a possible tag, such as _"en-US"_. `Language::Tag.for` will return, creating as necessary, the record corresponding the canonical BCP 47 ordering of the subtags indicated by `tag_value`. **These tags are cases sensitive!**

### Language::Subtag

Subtags are individual language descriptors - language family, script, region, etc. - combined to identify the language characteristics associated with a tag. There is not an HTML interface for creating these subtags, but data in the canonical IANA format can be loaded/updated via rake task, see lib/tasks/hyacinth/languages.rake.
