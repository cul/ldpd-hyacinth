import React from 'react';
import PropTypes from 'prop-types';

function ReadableDate({ isoDate }) {
  return Intl.DateTimeFormat(
    'en-US',
    {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: 'numeric',
      minute: 'numeric',
      second: 'numeric',
    },
  ).format(new Date(isoDate));
}

ReadableDate.propTypes = {
  isoDate: PropTypes.string.isRequired,
};

export default ReadableDate;
