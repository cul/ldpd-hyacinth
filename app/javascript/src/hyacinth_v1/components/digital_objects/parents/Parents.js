import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useQuery, useMutation } from '@apollo/react-hooks';
import {
  Row, Col, Form, Button,
} from 'react-bootstrap';

import ParentsList from './ParentsList';
import DigitalObjectInterface from '../DigitalObjectInterface';
import TabHeading from '../../shared/tabs/TabHeading';
import {
  getParentsQuery,
  addParentMutation,
} from '../../../graphql/digitalObjects';
import GraphQLErrors from '../../shared/GraphQLErrors';
import FontAwesomeIcon from '../../../utils/lazyFontAwesome';

function Parents(props) {
  const { id } = props;
  const {
    loading: parentsLoading,
    error: parentsError,
    data: parentsData,
    refetch: refetchParents,
  } = useQuery(getParentsQuery, {
    variables: { id },
  });

  const [addParent, { error: addParentError }] = useMutation(addParentMutation);
  const [parentId, setParentId] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    const variables = { input: { id, parentId } };
    addParent({ variables }).then(refetchParents);
    setParentId('');
  };

  if (parentsLoading) return (<></>);
  if (parentsError) return (<GraphQLErrors errors={parentsError} />);

  const { digitalObject: { parents, ...digitalObject } } = parentsData;

  return (
    <DigitalObjectInterface digitalObject={digitalObject}>
      <TabHeading>Parent Digital Objects</TabHeading>
      <ParentsList digitalObjects={parents} childId={digitalObject.id} refetchParents={refetchParents} />
      <GraphQLErrors errors={addParentError} />
      <Form onSubmit={handleSubmit}>
        <Row>
          <Col sm={1}>
            <Form.Label>Add Parent</Form.Label>
          </Col>
          <Col sm={8}>
            <Form.Control
              type="text"
              name="parentUid"
              value={parentId}
              onChange={(e) => setParentId(e.target.value)}
              placeholder="Enter Parent UID"
            />
          </Col>
          <Col sm={1}>
            <Button variant="success" size="sm" onClick={handleSubmit}>
              <FontAwesomeIcon icon="plus" />
            </Button>
          </Col>
        </Row>

      </Form>

    </DigitalObjectInterface>
  );
}

export default Parents;

Parents.propTypes = {
  id: PropTypes.string.isRequired,
};
