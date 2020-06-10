import { useMutation } from '@apollo/react-hooks';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import PropTypes from 'prop-types';
import React, { useState } from 'react';
import {
  Col, Row, Button, Card, Collapse,
} from 'react-bootstrap';
import { Link } from 'react-router-dom';

import { createBatchExportMutation } from '../../../graphql/batchExports';
import GraphQLErrors from '../../shared/GraphQLErrors';
import SelectInput from '../../shared/forms/inputs/SelectInput';
import Label from '../../shared/forms/Label';
import InputGroup from '../../shared/forms/InputGroup';

const sortOptions = [
  { label: 'Title A-Z', value: 'TITLE ASC' },
  { label: 'Title Z-A', value: 'TITLE DESC' },
  { label: 'Relevance', value: 'RELEVANCE DESC' },
  { label: 'Most Recently Modified First', value: 'LAST_MODIFIED DESC' },
  { label: 'Least Recently Modified First', value: 'LAST_MODIFIED ASC' },
];

const ResultCountAndOptions = (props) => {
  const {
    totalCount, limit, offset, searchParams, onPerPageChange, onOrderByChange, orderBy,
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
          <Row className="align-items-center">
            <Col xs={12} md={6}>
              { `${firstResultNumForPage} - ${lastResultNumForPage} of ${totalCount} results` }
              &nbsp;&bull;&nbsp;
              <Button variant="link" size="sm" className="m-0 p-0" onClick={exportCurrentSearch}>
                Export Current Search to CSV
                {' '}
                <FontAwesomeIcon icon="file-export" />
              </Button>
            </Col>

            <Col sm={6} md={3} lg={{ offset: 1, span: 2 }}>
              <InputGroup className="mb-0 justify-content-center align-items-center">
                <Label xs={4} sm={4} md={6} className="text-right px-1">Per Page:</Label>
                <SelectInput onChange={onPerPageChange} xs={6} sm={6} size="sm" className="pl-1" value={limit} options={[20, 50, 100].map(i => ({ label: i.toString(), value: i }))} />
              </InputGroup>
            </Col>

            <Col sm={6} md={3}>
              <InputGroup className="mb-0 justify-content-center align-items-center">
                <Label xs={2} sm={2} md={4} className="text-right px-1">Sort:</Label>
                <SelectInput onChange={onOrderByChange} xs={8} sm={8} size="sm" className="pl-1" value={orderBy} options={sortOptions} />
              </InputGroup>
            </Col>
          </Row>

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
      </Card.Body>
    </Card>
  );
};

ResultCountAndOptions.propTypes = {
  searchParams: PropTypes.objectOf(PropTypes.any).isRequired,
  totalCount: PropTypes.number.isRequired,
  limit: PropTypes.number.isRequired,
  offset: PropTypes.number.isRequired,
  onPerPageChange: PropTypes.func.isRequired,
  onOrderByChange: PropTypes.func.isRequired,
  orderBy: PropTypes.string.isRequired,
};

export default ResultCountAndOptions;
