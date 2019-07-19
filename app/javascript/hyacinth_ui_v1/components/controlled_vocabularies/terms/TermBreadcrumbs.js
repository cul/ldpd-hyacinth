import React from 'react';
import { Breadcrumb } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';

class TermBreadcrumbs extends React.PureComponent {
  render() {
    const { vocabulary, term } = this.props;

    return (
      <Breadcrumb>
        <LinkContainer to="/controlled_vocabularies">
          <Breadcrumb.Item>Controlled Vocabularies</Breadcrumb.Item>
        </LinkContainer>
        <LinkContainer to={`/controlled_vocabularies/${vocabulary.stringKey}`}>
          <Breadcrumb.Item>{vocabulary.label}</Breadcrumb.Item>
        </LinkContainer>
        <LinkContainer to={`/controlled_vocabularies/${vocabulary.stringKey}`}>
          <Breadcrumb.Item>Terms</Breadcrumb.Item>
        </LinkContainer>
        {
          <Breadcrumb.Item active>{term ? term.prefLabel : 'New Term'}</Breadcrumb.Item>
        }
      </Breadcrumb>
    );
  }
}

export default TermBreadcrumbs;
