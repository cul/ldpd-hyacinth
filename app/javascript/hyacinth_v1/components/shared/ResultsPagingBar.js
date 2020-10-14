import React from 'react';
import PropTypes from 'prop-types';
import { Pagination } from 'react-bootstrap';

function ResultsPagingBar(props) {
  const {
    totalCount, offset, nodes, uidCurrent, resultIndex, onResultClick,
  } = props;

  let uidPrev = null;
  let uidNext = null;

  // if  offset is 0 and total is N,
  // then this is the first result: prev is disabled and next is nodes[1]
  if (offset === 0) {
    if (nodes.length > 1) {
      if (uidCurrent === nodes[0].id) {
        uidNext = nodes[1].id;
      } else if (uidCurrent === nodes[1].id) {
        uidPrev = nodes[0].id;
        if (nodes.length > 2) {
          uidNext = nodes[2].id;
        }
      }
    }
  }

  // if offset > 0 and offset < totalCount
  if (offset > 0 && offset < totalCount) {
    if (nodes.length === 2) {
      uidPrev = nodes[0].id;
    } else {
      uidPrev = nodes[0].id;
      uidNext = nodes[2].id;
    }
  }

  return (
    <Pagination className="justify-content-center">
      <Pagination.Prev
        onClick={() => onResultClick(offset - 1, resultIndex - 1, uidPrev)}
        disabled={resultIndex === 1}
      />
      <>
        <Pagination.Item>
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
  nodes: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.string,
    }),
  ).isRequired,
  uidCurrent: PropTypes.string.isRequired,
  onResultClick: PropTypes.func.isRequired,
};

export default ResultsPagingBar;
