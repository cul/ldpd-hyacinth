import React from 'react';
import PropTypes from 'prop-types';
import { Alert } from 'react-bootstrap';

function ErrorList({ errors }) {
  if (!errors || errors.length === 0) return (null);

  return (
    <Alert variant="danger">
      <Alert.Heading as="h5">The following error(s) occurred:</Alert.Heading>
      <ul>
        {
          errors.map((error, eIndex) => (
            // eslint-disable-next-line react/no-array-index-key
            <li key={eIndex}>{error}</li>
          ))
        }
      </ul>
    </Alert>
  );
}

export default ErrorList;

ErrorList.defaultProps = {
  errors: [],
};

ErrorList.propTypes = {
  errors: PropTypes.arrayOf(PropTypes.string),
};
