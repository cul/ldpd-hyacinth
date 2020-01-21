import React from 'react';
import PropTypes from 'prop-types';
import { Breadcrumb } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';

function TermBreadcrumbs(props) {
  const { vocabulary: { stringKey, label }, term } = props;

  return (
    <Breadcrumb>
      <LinkContainer to="/controlled_vocabularies">
        <Breadcrumb.Item>Controlled Vocabularies</Breadcrumb.Item>
      </LinkContainer>
      <LinkContainer to={`/controlled_vocabularies/${stringKey}`}>
        <Breadcrumb.Item>{label}</Breadcrumb.Item>
      </LinkContainer>
      <LinkContainer to={`/controlled_vocabularies/${stringKey}`}>
        <Breadcrumb.Item>Terms</Breadcrumb.Item>
      </LinkContainer>
      {
        <Breadcrumb.Item active>{term ? term.prefLabel : 'New Term'}</Breadcrumb.Item>
      }
    </Breadcrumb>
  );
}

TermBreadcrumbs.defaultProps = {
  term: null,
};

TermBreadcrumbs.propTypes = {
  vocabulary: PropTypes.shape({
    stringKey: PropTypes.string,
  }).isRequired,
  term: PropTypes.shape({
    prefLabel: PropTypes.string,
  }),
};

export default TermBreadcrumbs;
