import React from 'react';
import { useParams } from 'react-router-dom';
import { useQuery } from '@apollo/react-hooks';

import ContextualNavbar from '../../layout/ContextualNavbar';
import TermForm from './TermForm';
import TermBreadcrumbs from './TermBreadcrumbs';
import GraphQLErrors from '../../ui/GraphQLErrors';
import { getTermQuery } from '../../../graphql/terms';

function TermEdit() {
  const { stringKey, uri } = useParams();

  const { loading, error, data } = useQuery(
    getTermQuery, {
      variables: { vocabularyStringKey: stringKey, uri: decodeURIComponent(uri) },
    },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const { vocabulary, vocabulary: { term } } = data;

  return (
    <>
      <ContextualNavbar
        title={`Term | ${term.prefLabel}`}
        rightHandLinks={[{ link: `/controlled_vocabularies/${vocabulary.stringKey}`, label: 'Back to Search' }]}
      />

      <TermBreadcrumbs vocabulary={vocabulary} term={term} />

      <div className="m-3">
        <TermForm formType="edit" vocabulary={vocabulary} term={term} key={term.uri} />
      </div>
    </>
  );
}

export default TermEdit;
