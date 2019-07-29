import React from 'react';
import { Link } from 'react-router-dom';
import { Row, Col, Breadcrumb } from 'react-bootstrap';
import produce from 'immer';
import { LinkContainer } from 'react-router-bootstrap';

import ContextualNavbar from '../../layout/ContextualNavbar';
import hyacinthApi, { vocabulary } from '../../../util/hyacinth_api';
import TabHeading from '../../ui/tabs/TabHeading';

export default class TermShow extends React.Component {
  state = {
    term: null,
  }

  componentDidMount() {
    const { match: { params: { stringKey, uri } } } = this.props;

    vocabulary(stringKey).terms().get(uri)
      .then((res) => {
        this.setState(produce((draft) => {
          draft.term = res.data.term;
          draft.loaded = true;
        }));
      });
  }

  render() {
    const { match: { params: { stringKey } } } = this.props;
    const { term } = this.state;

    return (
      term && (
        <>
          <ContextualNavbar
            title={`Term | ${term.prefLabel}`}
            rightHandLinks={[{ link: `/controlled_vocabularies/${stringKey}`, label: 'Back to Search' }]}
          />

          <Breadcrumb>
            <LinkContainer to="/controlled_vocabularies">
              <Breadcrumb.Item>Controlled Vocabularies</Breadcrumb.Item>
            </LinkContainer>
            <LinkContainer to={`/controlled_vocabularies/${stringKey}`}>
              <Breadcrumb.Item>Vocabulary Name</Breadcrumb.Item>
            </LinkContainer>
            <Breadcrumb.Item active>Terms</Breadcrumb.Item>
            <Breadcrumb.Item active>{term.prefLabel}</Breadcrumb.Item>
          </Breadcrumb>

          <Row as="dl">
            <Col as="dt" sm={2}>Pref Label</Col>
            <Col as="dd" sm={10}>{term.prefLabel}</Col>

            <Col as="dt" sm={2}>Alternative Labels</Col>
            <Col as="dd" sm={10}>{term.altLabels.join() || '-- None --'}</Col>

            <Col as="dt" sm={2}>Term Type</Col>
            <Col as="dd" sm={10}>{term.termType}</Col>

            <Col as="dt" sm={2}>Authority</Col>
            <Col as="dd" sm={10}>{term.authority || '-- None --'}</Col>

            <Col as="dt" sm={2}>URI</Col>
            <Col as="dd" sm={10}>{term.uri}</Col>
          </Row>
        </>
      )
    );
  }
}
