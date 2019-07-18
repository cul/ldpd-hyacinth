import React from 'react';
import produce from 'immer';

import hyacinthApi, { vocabulary } from '../../../util/hyacinth_api';
import ContextualNavbar from '../../layout/ContextualNavbar';
import TermForm from './TermForm';
import TermBreadcrumbs from './TermBreadcrumbs';

class TermEdit extends React.Component {
  state = {
    vocabulary: null,
    term: null
  }

  componentDidMount = () => {
    const { match: { params: { stringKey, uri } } } = this.props;

    vocabulary(stringKey).get()
      .then((res) => {
        this.setState(produce((draft) => {
          draft.vocabulary = res.data.vocabulary;
        }));
      });

    vocabulary(stringKey).terms().get(uri)
      .then((res) => {
        this.setState(produce((draft) => {
          draft.term = res.data.term;
        }));
      });
  }

  render() {
    const { match: { params: { stringKey, uri } } } = this.props;
    const { vocabulary, term } = this.state;

    return (
      (vocabulary && term) && (
        <>
          <ContextualNavbar
            title={`Term | ${term.prefLabel}`}
            rightHandLinks={[{ link: `/controlled_vocabularies/${vocabulary.stringKey}`, label: 'Back to Search' }]}
          />

          <TermBreadcrumbs vocabulary={vocabulary} term={term} />

          <div className="m-3">
            <TermForm formType="edit" vocabulary={vocabulary} term={term} key={uri} />
          </div>
        </>
      )
    );
  }
}

export default TermEdit;
