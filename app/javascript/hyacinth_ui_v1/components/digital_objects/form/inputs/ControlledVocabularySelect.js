import React from 'react';
import PropTypes from 'prop-types';
import { Col, Button, Dropdown } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import ControlledVocabularyMenu from './ControlledVocabularyMenu';

class ControlledVocabularySelect extends React.PureComponent {
  render() {
    const { value, vocabulary, onChange } = this.props;

    return (
      <Col sm={8} style={{ alignSelf: 'center' }}>
        <Dropdown>
          <Dropdown.Toggle drop="down" size="sm" variant="outline-secondary">
            { (value && value.prefLabel) ? value.prefLabel : 'Select one...' }
          </Dropdown.Toggle>

          {
            value && value.prefLabel && (
              <Button
                variant="danger"
                size="sm"
                style={{ padding: '0.05rem 0.35rem', marginLeft: '.25rem' }}
                onClick={() => onChange({})}
              >
                <FontAwesomeIcon icon="times" />
              </Button>
            )
          }

          <Dropdown.Menu
            as={ControlledVocabularyMenu}
            vocabulary={vocabulary}
            onChange={onChange}
          />
        </Dropdown>
      </Col>
    );
  }
}

ControlledVocabularySelect.propTypes = {
  vocabulary: PropTypes.string.isRequired,
  value: PropTypes.shape({
    prefLabel: PropTypes.string,
    uri: PropTypes.string,
  }).isRequired,
  onChange: PropTypes.func.isRequired,
  name: PropTypes.string,
}

export default ControlledVocabularySelect;
