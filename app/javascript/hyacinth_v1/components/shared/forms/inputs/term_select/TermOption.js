import React from 'react';
import PropTypes from 'prop-types';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
  Button, Dropdown, Badge, Collapse,
} from 'react-bootstrap';

function TermOption(props) {
  const {
    term, expanded, onSelect, onCollapseToggle,
  } = props;

  return (
    <div className="px-3 py-1">
      <Button variant="link" onClick={onCollapseToggle} className="p-0">
        <FontAwesomeIcon icon="info-circle" />
      </Button>

      <Dropdown.Item
        className="px-1 mx-1"
        onClick={onSelect}
        key={term.uri}
        data-uri={term.uri}
        style={{ display: 'inline' }}
      >
        {`${term.prefLabel} `}
      </Dropdown.Item>

      {
        term.termType === 'temporary'
          ? <Badge variant="danger">Temporary Term</Badge>
          : <a className="badge badge-primary" href={term.uri} target="_blank" rel="noopener noreferrer">{term.authority}</a>
      }
      <Collapse in={expanded}>
        <div>
          <ul className="list-unstyled px-4" style={{ fontSize: '.8rem' }}>
            <li>
              <strong>URI:</strong>
              {term.uri}
              <a className="px-1" href={term.uri} target="_blank" rel="noopener noreferrer">
                <FontAwesomeIcon icon="external-link-square-alt" />
              </a>
            </li>
            <li>
              <strong>Type:</strong> {term.termType}
            </li>
            {
              term.termType !== 'temporary' && (
                <li>
                  <strong>Authority:</strong> {term.authority}
                </li>
              )
            }
          </ul>
        </div>
      </Collapse>
    </div>
  );
}

TermOption.propTypes = {
  term: PropTypes.shape({
    prefLabel: PropTypes.string,
    uri: PropTypes.string,
  }).isRequired,
  onSelect: PropTypes.func.isRequired,
  expanded: PropTypes.bool.isRequired,
  onCollapseToggle: PropTypes.func.isRequired,
};

export default TermOption;
