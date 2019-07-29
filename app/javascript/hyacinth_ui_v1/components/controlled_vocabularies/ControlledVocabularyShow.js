import React from 'react';
import { Link, Route, Switch, Redirect } from 'react-router-dom';
import produce from 'immer';
import { Row, Col, Button } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import PageNotFound from '../layout/PageNotFound';
import Tab from '../ui/tabs/Tab';
import Tabs from '../ui/tabs/Tabs';
import TabBody from '../ui/tabs/TabBody';
// import CoreData from './core_data/CoreData';
// import FieldSet from './field_sets/FieldSet';
// import PublishTarget from './publish_targets/PublishTarget';
// import EnabledDynamicFields from './enabled_dynamic_fields/EnabledDynamicFields';
import hyacinthApi, { vocabulary } from '../../util/hyacinth_api';
import ControlledVocabularyForm from './ControlledVocabularyForm';
import Terms from './terms/Terms';
import ContextualNavbar from '../layout/ContextualNavbar';
import TermIndex from './terms/TermIndex';

export default class ControlledVocabularyShow extends React.Component {
  state = {
    vocabulary: null,
  }

  componentDidMount = () => {
    const { match: { params: { stringKey } } } = this.props;

    vocabulary(stringKey).get()
      .then((res) => {
        this.setState(produce((draft) => {
          draft.vocabulary = res.data.vocabulary;
        }));
      });
  }

  render() {
    const { match: { url }} = this.props;
    const { vocabulary } = this.state;

    return (
      <>
        {
          vocabulary && (
            <>
              <ContextualNavbar
                title={`Controlled Vocabulary | ${vocabulary.label}`}
                rightHandLinks={[{ link: '/controlled_vocabularies', label: 'Back to All Controlled Vocabularies' }]}
              />
              <div className="m-1">
                <h3>Vocabulary</h3>

                <Row as="dl">
                  <Col as="dt" sm={2}>String Key</Col>
                  <Col as="dd" sm={10}>{vocabulary.stringKey}</Col>

                  <Col as="dt" sm={2}>Label</Col>
                  <Col as="dd" sm={10}>{vocabulary.label}</Col>

                  <Col as="dt" sm={2}>Custom Fields</Col>
                  <Col as="dd" sm={10}>{Object.values(vocabulary.customFields).map(v => v.label).join(', ') || '-- None --'}</Col>
                </Row>
              </div>

              <hr />
              <h3>
                Terms
                <LinkContainer to={`/controlled_vocabularies/${vocabulary.stringKey}/terms/new`}>
                  <Button variant="outline-primary" className="float-right">
                    <FontAwesomeIcon icon="plus" />
                    {' Add New Term'}
                  </Button>
                </LinkContainer>
              </h3>

              <TermIndex />
            </>
          )
        }
      </>
    );
  }
}
