import React from 'react';
import PropTypes from 'prop-types';
import { Col, Dropdown } from 'react-bootstrap';

import ControlledVocabularyMenu from './controlled_vocabulary/ControlledVocabularyMenu';
import RemoveButton from '../../buttons/RemoveButton';

class ControlledVocabularySelect extends React.PureComponent {
  render() {
    const {
      name, value, vocabulary, onChange,
    } = this.props;

    return (
      <Col sm={8} style={{ alignSelf: 'center' }}>
        <Dropdown name={name} drop="right">
          <Dropdown.Toggle size="sm" variant="outline-secondary">
            { (value && value.prefLabel) ? value.prefLabel : 'Select one...' }
          </Dropdown.Toggle>

          {
            value && value.prefLabel && (
              <RemoveButton onClick={() => onChange({})} />
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

ControlledVocabularySelect.defaultProps = {
  name: '',
};

ControlledVocabularySelect.propTypes = {
  vocabulary: PropTypes.string.isRequired,
  value: PropTypes.shape({
    prefLabel: PropTypes.string,
    uri: PropTypes.string,
  }).isRequired,
  onChange: PropTypes.func.isRequired,
  name: PropTypes.string,
};

export default ControlledVocabularySelect;
