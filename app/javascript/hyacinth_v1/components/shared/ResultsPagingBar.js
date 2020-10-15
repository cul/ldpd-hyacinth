import React from 'react';
import PropTypes from 'prop-types';
import { Pagination } from 'react-bootstrap';

function ResultsPagingBar(props) {
  const {
    totalCount, offset, uids, uidCurrent, resultIndex, onResultClick,
  } = props;

  let uidPrev = null;
  let uidNext = null;
  const [firstResult, secondResult, thirdResult] = uids;


  // offset is zero for the first or second result
  if (offset === 0) {
    // previous value remains null for the first result
    if (uidCurrent === firstResult) {
      uidNext = secondResult;
    } else if (uidCurrent === secondResult) {
      uidPrev = firstResult;
      if (thirdResult) {
        uidNext = thirdResult;
      }
    }
  }

  // setting values for all other cases
  if (offset > 0 && offset < totalCount) {
    uidPrev = firstResult;
    // thirdId is null for the last result
    if (thirdResult) {
      uidNext = thirdResult;
    }
  }

  return (
    <Pagination className="justify-content-center">
      <Pagination.Prev
        onClick={() => onResultClick(offset - 1, resultIndex - 1, uidPrev)}
        disabled={resultIndex === 1}
      />
      <>
        <Pagination.Item active>
          {resultIndex}
          {' '}
of
          {' '}
          {totalCount}
        </Pagination.Item>
      </>

      <Pagination.Next
        onClick={() => onResultClick(offset + 1, resultIndex + 1, uidNext)}
        disabled={resultIndex === totalCount}
      />
    </Pagination>
  );
}

ResultsPagingBar.propTypes = {
  offset: PropTypes.number.isRequired,
  resultIndex: PropTypes.number.isRequired,
  totalCount: PropTypes.number.isRequired,
  uids: PropTypes.arrayOf(PropTypes.string).isRequired,
  uidCurrent: PropTypes.string.isRequired,
  onResultClick: PropTypes.func.isRequired,
};

export default ResultsPagingBar;
