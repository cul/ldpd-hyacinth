import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { Table } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';

import ContextualNavbar from '../layout/ContextualNavbar';
import PaginationBar from '../ui/PaginationBar';
import GraphQLErrors from '../ui/GraphQLErrors';
import { getVocabulariesQuery } from '../../graphql/vocabularies';

const limit = 20;

function ControlledVocabularyIndex() {
  const [offset, setOffset] = useState(0);
  const [totalVocabularies, setTotalVocabularies] = useState(0);

  const {
    loading, error, data, refetch,
  } = useQuery(
    getVocabulariesQuery, {
      variables: { limit, offset },
      onCompleted: (vocabData) => { setTotalVocabularies(vocabData.vocabularies.totalCount); },
    },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const { vocabularies: { nodes: controlledVocabularies } } = data;

  const onPageNumberClick = (page) => {
    setOffset(limit * (page - 1));
    refetch();
  };

  return (
    <>
      <ContextualNavbar
        title="Controlled Vocabularies"
        rightHandLinks={[{ link: '/controlled_vocabularies/new', label: 'New Controlled Vocabulary' }]}
      />

      <Table hover>
        <thead>
          <tr>
            <th>Label</th>
            <th>String Key</th>
          </tr>
        </thead>
        <tbody>
          {
            controlledVocabularies && (
              controlledVocabularies.map(controlledVocabulary => (
                <tr key={controlledVocabulary.stringKey}>
                  <td>
                    <Link to={`/controlled_vocabularies/${controlledVocabulary.stringKey}`}>
                      {controlledVocabulary.label}
                    </Link>
                  </td>
                  <td>
                    {controlledVocabulary.stringKey}
                  </td>
                </tr>
              ))
            )
          }
        </tbody>
      </Table>

      <PaginationBar
        offset={offset}
        limit={limit}
        totalItems={totalVocabularies}
        onPageNumberClick={onPageNumberClick}
      />
    </>
  );
}

export default ControlledVocabularyIndex;
