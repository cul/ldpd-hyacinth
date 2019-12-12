import React from 'react';
import { Link } from 'react-router-dom';
import { Table } from 'react-bootstrap';
import produce from 'immer';

import ContextualNavbar from '../layout/ContextualNavbar';
import { vocabularies } from '../../util/hyacinth_api';
import PaginationBar from '../ui/PaginationBar';

const limit = 20;

export default class ControlledVocabularyIndex extends React.Component {
  state = {
    controlledVocabularies: [],
    totalRecords: '',
    offset: 0,
  }

  componentDidMount() {
    this.vocabulariesFetch(1);
  }

  onPageNumberClick = (page) => {
    this.vocabulariesFetch(page);
  }

  vocabulariesFetch = (page) => {
    vocabularies.all(`offset=${limit * (page - 1)}&limit=${limit}`).then((res) => {
      this.setState(produce((draft) => {
        draft.controlledVocabularies = res.data.vocabularies;
        draft.totalRecords = res.data.totalRecords;
        draft.offset = res.data.offset;
      }));
    });
  }

  render() {
    const { controlledVocabularies, totalRecords, offset } = this.state;

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
          totalItems={totalRecords}
          onPageNumberClick={this.onPageNumberClick}
        />
      </>
    );
  }
}
