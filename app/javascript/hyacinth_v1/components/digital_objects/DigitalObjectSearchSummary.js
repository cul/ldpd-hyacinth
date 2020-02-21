import { useMutation } from '@apollo/react-hooks';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import PropTypes from 'prop-types';
import React, { useState } from 'react';
import { Button, Card, Collapse } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { createBatchExportMutation } from '../../graphql/batchExports';
import GraphQLErrors from '../shared/GraphQLErrors';

const DigitalObjectSearchSummary = (props) => {
  const { totalCount, limit, offset } = props;
  const firstResultNumForPage = offset + 1;
  const lastResultNumForPage = totalCount < offset + limit ? totalCount : offset + limit;

  const [latestExportUrlHref, setLatestExportUrlHref] = useState(null);

  const [createBatchExport, { error: createBatchExportError }] = useMutation(
    createBatchExportMutation,
  );

  if (createBatchExportError) {
    return (<GraphQLErrors errors={createBatchExportError} />);
  }

  const exportCurrentSearch = () => {
    const variables = { input: { searchParams: '{}' } }; // TODO: Use real searchParams
    createBatchExport({ variables }).then((res) => {
      const { data: { createBatchExport: { batchExport: { id: newExportJobId } } } } = res;
      setLatestExportUrlHref(`/batch_exports?highlight=${newExportJobId}`);
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
          <Collapse in={latestExportUrlHref != null}>
            <div>
              <strong>
                Export has been queued as a background job.
                {' '}
                {
                  latestExportUrlHref && (
                    <Link to={latestExportUrlHref}>Click here to monitor the job status.</Link>
                  )
                }
              </strong>
            </div>
          </Collapse>
        </small>
      </Card.Body>
    </Card>
  );
};

DigitalObjectSearchSummary.propTypes = {
  totalCount: PropTypes.number.isRequired,
  limit: PropTypes.number.isRequired,
  offset: PropTypes.number.isRequired,
};

export default DigitalObjectSearchSummary;
