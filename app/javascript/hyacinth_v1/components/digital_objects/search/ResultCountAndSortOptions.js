import { useMutation } from '@apollo/react-hooks';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import PropTypes from 'prop-types';
import React, { useState } from 'react';
import { Button, Card, Collapse } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { createBatchExportMutation } from '../../../graphql/batchExports';
import GraphQLErrors from '../../shared/GraphQLErrors';

const ResultCountAndSortOptions = (props) => {
  const {
    totalCount, limit, offset, searchParams,
  } = props;
  const firstResultNumForPage = offset + 1;
  const lastResultNumForPage = totalCount < offset + limit ? totalCount : offset + limit;

  const [latestExportId, setLatestExportId] = useState(null);

  const [createBatchExport, { error: createBatchExportError }] = useMutation(
    createBatchExportMutation,
  );

  if (createBatchExportError) {
    return (<GraphQLErrors errors={createBatchExportError} />);
  }

  const exportCurrentSearch = () => {
    const variables = { input: { searchParams } };
    createBatchExport({ variables }).then((res) => {
      const { data: { createBatchExport: { batchExport: { id: newExportJobId } } } } = res;
      setLatestExportId(newExportJobId);
    });
  };

  return (
    <Card className="mb-3">
      <Card.Body>
        <small>
          { `${firstResultNumForPage} - ${lastResultNumForPage} of ${totalCount} results` }
          &nbsp;&bull;&nbsp;
          <Button variant="link" size="sm" className="m-0 p-0" onClick={exportCurrentSearch}>
            Export Current Search to CSV
            {' '}
            <FontAwesomeIcon icon="file-export" />
          </Button>
          <Collapse in={latestExportId != null}>
            <div>
              <strong>
                {`Export with id ${latestExportId} been queued as a background job. `}
                {
                  latestExportId && (
                    <Link to={`/batch_exports?highlight=${latestExportId}`}>Click here to monitor the job status.</Link>
                  )
                }
              </strong>
            </div>
          </Collapse>
        </small>
        {
          // TODO: Later on, add sort and per page dropdowns here.
        }
      </Card.Body>
    </Card>
  );
};

ResultCountAndSortOptions.propTypes = {
  searchParams: PropTypes.objectOf(PropTypes.any).isRequired,
  totalCount: PropTypes.number.isRequired,
  limit: PropTypes.number.isRequired,
  offset: PropTypes.number.isRequired,
};

export default ResultCountAndSortOptions;
