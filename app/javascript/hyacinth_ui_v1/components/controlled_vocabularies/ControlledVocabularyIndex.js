import React from 'react';
import { Link } from 'react-router-dom';
import { Table } from 'react-bootstrap';
import produce from 'immer';

import ContextualNavbar from '../layout/ContextualNavbar';
import hyacinthApi from '../../util/hyacinth_api';

export default class ControlledVocabularyIndex extends React.Component {
  state = {
    controlledVocabularies: [],
  }

  componentDidMount() {
    hyacinthApi.get('/vocabularies')
      .then((res) => {
        this.setState(produce((draft) => { draft.controlledVocabularies = res.data.vocabularies; }));
      });
  }

  render() {
    const { controlledVocabularies } = this.state;

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
        <p>Need to add pagination</p>
      </>
    );
  }
}
