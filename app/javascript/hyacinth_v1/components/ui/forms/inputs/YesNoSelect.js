import React from 'react';
import PropTypes from 'prop-types';

import SelectInput from './SelectInput';

class YesNoSelect extends React.PureComponent {
  render() {
    const options = [{ label: 'Yes', value: 'yes' }, { label: 'No', value: 'no' }];

    return (
      <SelectInput sm={4} options={options} {...this.props} />
    );
  }
}

YesNoSelect.defaultProps = {
  inputName: '',
};

YesNoSelect.propTypes = {
  inputName: PropTypes.string,
  onChange: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
};

export default YesNoSelect;
