import React from 'react';
import { useParams } from 'react-router-dom';
import { useQuery } from '@apollo/react-hooks';

import ContextualNavbar from '../shared/ContextualNavbar';
import ControlledVocabularyForm from './ControlledVocabularyForm';
import { getVocabularyQuery } from '../../graphql/vocabularies';
import GraphQLErrors from '../shared/GraphQLErrors';

function ControlledVocabularyEdit() {
  const { stringKey } = useParams();

  const { loading, error, data } = useQuery(
    getVocabularyQuery, {
      variables: { stringKey },
    },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <div className="m-3">
      <ContextualNavbar
        title="Update Controlled Vocabulary"
        rightHandLinks={[{ link: '/controlled_vocabularies', label: 'Back to Controlled Vocabulary' }]}
      />

      <ControlledVocabularyForm formType="edit" vocabulary={data.vocabulary} />
    </div>
  );
}

export default ControlledVocabularyEdit;
