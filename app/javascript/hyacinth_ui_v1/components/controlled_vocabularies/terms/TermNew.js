import React from 'react';
import produce from 'immer';
import ContextualNavbar from '../../layout/ContextualNavbar';
import TermForm from './TermForm';
import TermBreadcrumbs from './TermBreadcrumbs';

import hyacinthApi, { vocabulary } from '../../../util/hyacinth_api';

class TermNew extends React.Component {
  state = {
    vocabulary: null,
  }

  componentDidMount = () => {
    const { match: { params: { stringKey, uri } } } = this.props;

    vocabulary(stringKey).get()
      .then((res) => {
        this.setState(produce((draft) => {
          draft.vocabulary = res.data.vocabulary;
        }));
      });
  }

  render() {
    const { vocabulary } = this.state;

    return (
      vocabulary && (
        <>
          <ContextualNavbar
            title="Create Term"
            rightHandLinks={[{ link: `/controlled_vocabularies/${vocabulary.stringKey}`, label: `Back to ${vocabulary.label}` }]}
          />

          <TermBreadcrumbs vocabulary={vocabulary} />

          <TermForm formType="new" vocabulary={vocabulary} />
        </>
      )
    );
  }
}

export default TermNew;
