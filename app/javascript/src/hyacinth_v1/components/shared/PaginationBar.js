import React from 'react';
import PropTypes from 'prop-types';
import { Pagination } from 'react-bootstrap';

function PaginationBar(props) {
  const {
    totalItems, onClick, limit, offset,
  } = props;

  const page = (Number(offset) / Number(limit)) + 1;
  const totalPages = Math.max(1, Math.ceil(Number(totalItems) / Number(limit)));
  const pageNumbers = [];

  for (let i = 2; i > 0; i -= 1) {
    const newPage = page - i;
    if (newPage > 0) pageNumbers.push(newPage);
  }

  pageNumbers.push(page);

  for (let i = 1; i < 3; i += 1) {
    const newPage = page + i;
    if (newPage <= totalPages) pageNumbers.push(newPage);
  }

  const onPageNumberClick = (p) => onClick(limit * (p - 1));

  return (
    <Pagination className="justify-content-center">
      <Pagination.Prev
        onClick={() => onPageNumberClick(page - 1)}
        disabled={totalPages === 1 || page === 1}
      />
      {
        !pageNumbers.includes(1) && (
          <>
            <Pagination.Item onClick={() => onPageNumberClick(1)}>{1}</Pagination.Item>
            { !pageNumbers.includes(2) && <Pagination.Ellipsis /> }
          </>
        )
        }
      {
        pageNumbers.map((num) => (
          <Pagination.Item key={num} active={page === num} onClick={() => onPageNumberClick(num)}>
            {num}
          </Pagination.Item>
        ))
      }

      {
        !pageNumbers.includes(totalPages) && (
          <>
            { !pageNumbers.includes(totalPages - 1) && <Pagination.Ellipsis /> }
            <Pagination.Item onClick={() => onPageNumberClick(totalPages)}>
              {totalPages}
            </Pagination.Item>
          </>
        )
      }

      <Pagination.Next
        onClick={() => onPageNumberClick(page + 1)}
        disabled={page === totalPages}
      />
    </Pagination>
  );
}

PaginationBar.propTypes = {
  offset: PropTypes.number.isRequired,
  totalItems: PropTypes.number.isRequired,
  limit: PropTypes.number.isRequired,
  onClick: PropTypes.func.isRequired,
};

export default PaginationBar;
