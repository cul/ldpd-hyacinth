import React from 'react';
import { useParams } from 'react-router-dom';
import { useQuery } from '@apollo/react-hooks';

import ContextualNavbar from '../../layout/ContextualNavbar';
import TermForm from './TermForm';
import TermBreadcrumbs from './TermBreadcrumbs';
import { getVocabularyQuery } from '../../../graphql/vocabularies';
import GraphQLErrors from '../../ui/GraphQLErrors';

function TermNew() {
  const { stringKey } = useParams();

  const { loading, error, data } = useQuery(
    getVocabularyQuery, {
      variables: { stringKey },
    },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const { vocabulary } = data;

  return (
    <>
      <ContextualNavbar
        title="Create Term"
        rightHandLinks={[{ link: `/controlled_vocabularies/${vocabulary.stringKey}`, label: `Back to ${vocabulary.label}` }]}
      />

      <TermBreadcrumbs vocabulary={vocabulary} />

      <TermForm formType="new" vocabulary={vocabulary} />
    </>
  );
}

export default TermNew;
