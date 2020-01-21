import React from 'react';
import PropTypes from 'prop-types';

import TermOptions from './TermOptions';

const TermMenu = React.forwardRef((props, ref) => {
  const {
    className,
    onChange,
    style,
    'aria-labelledby': labeledBy,
    vocabulary,
    close,
  } = props;

  return (
    <div ref={ref} style={{ ...style, width: '100%' }} className={className} aria-labelledby={labeledBy}>
      <TermOptions
        vocabularyStringKey={vocabulary}
        onChange={onChange}
        close={close}
      />
    </div>
  );
});

TermMenu.propTypes = {
  vocabulary: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
  close: PropTypes.func.isRequired,
  className: PropTypes.string.isRequired,
  'aria-labelledby': PropTypes.string.isRequired,
};

export default TermMenu;
