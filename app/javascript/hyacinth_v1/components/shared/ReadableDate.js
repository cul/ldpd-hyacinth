import React from 'react';
import PropTypes from 'prop-types';
import * as moment from 'moment';

function ReadableDate({ date, format }) {
  return moment(date).format(format);
}

ReadableDate.defaultProps = {
  format: 'MMMM Do YYYY, h:mm:ss a',
};

ReadableDate.propTypes = {
  format: PropTypes.string,
  date: PropTypes.string.isRequired,
};

export default ReadableDate;
