Rails.autoloaders.each do |autoloader|
  # inflections for some all-caps module names
  autoloader.inflector.inflect(
    'dc_metadata' => 'DCMetadata',
    'fcrepo3' => 'FCREPO3',
    'nfo' => 'NFO',
    'nie' => 'NIE',
    'olo' => 'OLO',
    'ore' => 'ORE',
    'pimo' => 'PIMO',
    'rdf' => 'RDF',
    'sc' => 'SC',
    'xml_generator' => 'XMLGenerator'
  )
end
