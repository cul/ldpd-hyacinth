import React from 'react';
import PropTypes from 'prop-types';

import SelectInput from './SelectInput';

function YesNoSelect(props) {
  return (
    <SelectInput
      sm={4}
      options={[{ label: 'Yes', value: 'yes' }, { label: 'No', value: 'no' }]}
      {...props}
    />
  );
}

YesNoSelect.defaultProps = {
  value: '',
};

YesNoSelect.propTypes = {
  onChange: PropTypes.func.isRequired,
  value: PropTypes.oneOf(['', 'yes', 'no']),
};

export default YesNoSelect;
