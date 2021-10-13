import React from 'react';
import PropTypes from 'prop-types';
import { useHistory } from 'react-router-dom';
import { Pagination } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';
import GraphQLErrors from './GraphQLErrors';
import { getDigitalObjectIDsQuery } from '../../graphql/digitalObjects';
import {
  currentResultOffset, decodeSessionSearchParams, encodeSessionSearchParams, setCurrentResultOffset,
} from '../../utils/digitalObjectSearchParams';

const onResultClick = (history, resultOffset, searchParams, resultId) => {
  setCurrentResultOffset(resultOffset);
  const { offset, limit } = searchParams;
  const currentPageOffset = Math.floor(resultOffset / limit) * limit;
  if (offset !== currentPageOffset) encodeSessionSearchParams({ ...searchParams, offset: currentPageOffset });
  history.push(`/digital_objects/${resultId}`);
};

function ResultsPagingBar(props) {
  const { uidCurrent } = props;
  const history = useHistory();
  const resultOffset = currentResultOffset();
  const sessionSearchParams = { ...decodeSessionSearchParams() };
  const {
    searchTerms, searchType, filters, orderBy,
  } = sessionSearchParams;

  const [orderField, orderDirection] = orderBy.split(' ');

  const searchParams = { searchTerms, searchType, filters };

  const newOffset = resultOffset < 1 ? 0 : resultOffset - 1;

  const {
    loading, error, data,
  } = useQuery(
    getDigitalObjectIDsQuery, {
      variables: {
        limit: 3,
        offset: Number(newOffset),
        searchParams,
        orderBy: { field: orderField, direction: orderDirection },
      },
    },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const { digitalObjects: { totalCount, nodes } } = data;

  const uids = [];
  [...nodes.values()].forEach((value) => {
    uids.push(value.id);
  });

  let uidPrev = null;
  let uidNext = null;
  if (uids.length < 1 || !uids.includes(uidCurrent)) return (<></>);

  const [firstResult, secondResult, thirdResult] = uids;
  if (uidCurrent === firstResult) {
  // uidPrev remains null for the first result
    uidNext = secondResult;
  } else {
    uidPrev = firstResult;
    // uidNext remains null for last result
    if (thirdResult) {
      uidNext = thirdResult;
    }
  }
  const displayIndex = resultOffset + 1;
  return (
    <Pagination className="justify-content-center">
      <Pagination.Prev
        onClick={() => onResultClick(history, resultOffset - 1, sessionSearchParams, uidPrev)}
        disabled={displayIndex === 1}
      />
      <>
        <Pagination.Item active>
          {`${displayIndex} of ${totalCount}`}
        </Pagination.Item>
      </>

      <Pagination.Next
        onClick={() => onResultClick(history, resultOffset + 1, sessionSearchParams, uidNext)}
        disabled={displayIndex === totalCount}
      />
    </Pagination>
  );
}

ResultsPagingBar.propTypes = {
  uidCurrent: PropTypes.string.isRequired,
};

export default ResultsPagingBar;
