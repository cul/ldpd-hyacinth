import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { Table } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';

import { Can } from '../../utils/abilityContext';
import ContextualNavbar from '../shared/ContextualNavbar';
import PaginationBar from '../shared/PaginationBar';
import GraphQLErrors from '../shared/GraphQLErrors';
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

  const onPageNumberClick = (newOffset) => {
    setOffset(newOffset);
    refetch();
  };

  return (
    <>
      <Can I="create" a="Vocabulary" passThrough>
        {
          (can) => (
            <ContextualNavbar
              title="Controlled Vocabularies"
              rightHandLinks={can ? [{ link: '/controlled_vocabularies/new', label: 'New Controlled Vocabulary' }] : []}
            />
          )
        }
      </Can>

      <Table hover responsive>
        <thead>
          <tr>
            <th>Label</th>
            <th>String Key</th>
          </tr>
        </thead>
        <tbody>
          {
            controlledVocabularies && (
              controlledVocabularies.map((controlledVocabulary) => (
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
        onClick={onPageNumberClick}
      />
    </>
  );
}

export default ControlledVocabularyIndex;
