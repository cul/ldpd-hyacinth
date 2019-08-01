import React from 'react';
import { Link } from 'react-router-dom';
import { Table } from 'react-bootstrap';
import produce from 'immer';

import ContextualNavbar from '../layout/ContextualNavbar';
import { vocabularies } from '../../util/hyacinth_api';
import PaginationBar from '../ui/PaginationBar';

const perPage = 20;

export default class ControlledVocabularyIndex extends React.Component {
  state = {
    controlledVocabularies: [],
    totalRecords: '',
    page: 1,
  }

  componentDidMount() {
    this.vocabulariesFetch(1);
  }

  onPageNumberClick = (page) => {
    this.vocabulariesFetch(page);
  }

  vocabulariesFetch = (page) => {
    vocabularies.all(`page=${page}&per_page=${perPage}`).then((res) => {
      this.setState(produce((draft) => {
        draft.controlledVocabularies = res.data.vocabularies;
        draft.totalRecords = res.data.totalRecords;
        draft.page = res.data.page;
      }));
    });
  }

  render() {
    const { controlledVocabularies, totalRecords, page } = this.state;

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
          currentPage={page}
          perPage={perPage}
          totalItems={totalRecords}
          onPageNumberClick={this.onPageNumberClick}
        />
      </>
    );
  }
}
