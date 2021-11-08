import React from 'react';
import { Link } from 'react-router-dom';
import { useMutation } from '@apollo/react-hooks';
import PropTypes from 'prop-types';
import { Badge, Card, Button } from 'react-bootstrap';
import { startCase } from 'lodash';
import { removeParentMutation } from '../../../graphql/digitalObjects';
import { digitalObjectAbility } from '../../../utils/ability';
import GraphQLErrors from '../../shared/GraphQLErrors';

const ParentsList = (props) => {
  const {
    digitalObjects, childId, refetchParents,
  } = props;

  const [removeParent, { error: removeParentError }] = useMutation(removeParentMutation);

  const onDelete = (parentId) => {
    const variables = { input: { id: childId, parentId } };
    removeParent({ variables }).then(refetchParents);
  };

  return (
    <>
      {
        digitalObjects.map((digitalObject) => (
          <Card key={digitalObject.id} className="parent mb-3">
            <GraphQLErrors errors={removeParentError} />
            <Card.Header className="px-2 py-1">
              <Link
                to={`/digital_objects/${digitalObject.id}`}
              >
                {digitalObject.displayLabel}
              </Link>
              {(
                digitalObjectAbility.can('update_objects', {
                  primaryProject: digitalObject.primaryProject,
                  otherProjects: digitalObject.otherProjects,
                }))
              && (
              <Button
                id={`remove_parent_${digitalObject.id}`}
                variant="danger"
                size="sm"
                className="float-end"
                onClick={() => onDelete(digitalObject.id)}
              >
                Remove Parent
              </Button>
              )}
            </Card.Header>
            <Card.Body className="p-2">
              <ul className="list-unstyled small">
                <li>
                  <strong>UID: </strong>
                  {digitalObject.id}
                </li>
              </ul>
              <Badge bg="secondary">{startCase(digitalObject.digitalObjectType)}</Badge>
            </Card.Body>
          </Card>
        ))
      }
    </>
  );
};

ParentsList.defaultProps = {
};

ParentsList.propTypes = {
  digitalObjects: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.string.isRequired,
      digitalObjectType: PropTypes.string.isRequired,
      displayLabel: PropTypes.string.isRequired,
    }),
  ).isRequired,
  childId: PropTypes.string.isRequired,
  refetchParents: PropTypes.func.isRequired,
};

export default ParentsList;
