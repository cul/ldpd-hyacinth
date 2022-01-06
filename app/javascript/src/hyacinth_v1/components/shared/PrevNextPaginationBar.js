import React from 'react';
import PropTypes from 'prop-types';
import { Pagination } from 'react-bootstrap';

function PrevNextPaginationBar(props) {
  const {
    pageItems, onClick, limit, offset,
  } = props;

  const page = (Number(offset) / Number(limit)) + 1;
  const hasNext = pageItems > limit;
  const hasPrev = offset > 0;

  const onPageNumberClick = (p) => onClick(limit * (p - 1));

  return (
    <Pagination className="justify-content-center">
      <Pagination.Prev
        onClick={() => onPageNumberClick(page - 1)}
        disabled={!hasPrev}
      />
      <Pagination.Ellipsis />
      <Pagination.Next
        onClick={() => onPageNumberClick(page + 1)}
        disabled={!hasNext}
      />
    </Pagination>
  );
}

PrevNextPaginationBar.propTypes = {
  offset: PropTypes.number.isRequired,
  pageItems: PropTypes.number.isRequired,
  limit: PropTypes.number.isRequired,
  onClick: PropTypes.func.isRequired,
};

export default PrevNextPaginationBar;
