import React from 'react';
import PropTypes from 'prop-types';
import ErrorList from './ErrorList';

function UserErrorsList({ userErrors }) {
  return (
    <ErrorList errors={userErrors.map((userError) => (`${userError.message} (path=${userError.path.join('/')})`))} />
  );
}

export default UserErrorsList;

UserErrorsList.propTypes = {
  userErrors: PropTypes.arrayOf(PropTypes.shape({
    message: PropTypes.string.isRequired,
    path: PropTypes.arrayOf(PropTypes.string).isRequired,
  })).isRequired,
};
