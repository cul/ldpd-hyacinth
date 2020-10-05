import React from 'react';
import PropTypes from 'prop-types';
import { Pagination } from 'react-bootstrap';

function ResultsPagingBar(props) {
  const {
    totalResults, offset, uidPrev, uidNext, onResultClick,
  } = props;

  return (
    <Pagination className="justify-content-center">
      <Pagination.Prev
        onClick={() => onResultClick(offset - 1, uidPrev)}
        disabled={offset === 0}
      />
      <>
        <Pagination.Item >{offset + 1} of {totalResults}</Pagination.Item>
      </>

      <Pagination.Next
        onClick={() => onResultClick(offset + 1, uidNext)}
        disabled={offset === totalResults}
      />
    </Pagination>
  );
}

ResultsPagingBar.propTypes = {
  offset: PropTypes.number.isRequired,
  totalResults: PropTypes.number.isRequired,
  onResultClick: PropTypes.func.isRequired,
};

export default ResultsPagingBar;
