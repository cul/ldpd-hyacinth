import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';

import SelectInput from '../SelectInput';
import { getVocabulariesQuery } from '../../../../../graphql/vocabularies';
import GraphQLErrors from '../../../GraphQLErrors';

function VocabularySelect(props) {
  const { loading, error, data } = useQuery(getVocabulariesQuery, { variables: { limit: 100 } });

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const options = data.vocabularies.nodes.map(v => ({ label: v.label, value: v.stringKey }));

  return (
    <SelectInput sm={4} options={options} {...props} />
  );
}

VocabularySelect.propTypes = {
  value: PropTypes.string.isRequired,
};

export default VocabularySelect;
