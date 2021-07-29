import React from 'react';
import PropTypes from 'prop-types';
import { Button, Card } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';
import { LinkContainer } from 'react-router-bootstrap';

import { dynamicFieldGroupChildrenQuery } from '../../graphql/dynamicFieldGroups';
import DynamicFieldsAndGroupsTable from '../shared/dynamic_fields/DynamicFieldsAndGroupsTable';

function DynamicFieldGroupChildren(props) {
  const { id } = props;

  // Quering for children seperately so we can refetch when they are resorted.
  // We are only running this on the edit form.
  const { data: childrenResult, refetch: childrenRefetch } = useQuery(
    dynamicFieldGroupChildrenQuery, { variables: { id }, skip: !id },
  );

  return (
    <Card>
      <Card.Header>Child Fields and Field Groups</Card.Header>
      <Card.Body>
        <DynamicFieldsAndGroupsTable
          rows={childrenResult ? childrenResult.dynamicFieldGroup.children : []}
          onChange={childrenRefetch}
        />

        {
          id && (
            <>
              <LinkContainer className="m-1" to={`/dynamic_fields/new?dynamicFieldGroupId=${id}`}>
                <Button variant="secondary">New Child Field</Button>
              </LinkContainer>

              <LinkContainer className="m-1" to={`/dynamic_field_groups/new?parentId=${id}&parentType=DynamicFieldGroup`}>
                <Button variant="secondary">New Child Field Group</Button>
              </LinkContainer>
            </>
          )
        }
      </Card.Body>
    </Card>
  );
}

DynamicFieldGroupChildren.defaultProps = {
  id: null,
};

DynamicFieldGroupChildren.propTypes = {
  id: PropTypes.string,
};

export default DynamicFieldGroupChildren;
