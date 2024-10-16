import React from 'react';
import PropTypes from 'prop-types';
import { Card, Button } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';
import { Link } from 'react-router-dom';

import DigitalObjectInterface from '../DigitalObjectInterface';
import DigitalObjectList from '../DigitalObjectList';
import AssetNew from '../new/AssetNew';
import TabHeading from '../../shared/tabs/TabHeading';
import { getChildStructureDigitalObjectQuery } from '../../../graphql/digitalObjects';
import GraphQLErrors from '../../shared/GraphQLErrors';
import { digitalObjectAbility } from '../../../utils/ability';

const Children = (props) => {
  const { id } = props;

  const {
    loading: digitalObjectLoading,
    error: digitalObjectError,
    data: digitalObjectData,
    refetch: refreshDigitalObject,
  } = useQuery(getChildStructureDigitalObjectQuery, {
    variables: { id },
  });

  if (digitalObjectLoading) return (<></>);
  if (digitalObjectError) return (<GraphQLErrors errors={digitalObjectError} />);
  const { digitalObject } = digitalObjectData;
  const { childStructure: { structure } } = digitalObject;
  if (digitalObjectLoading) return (<></>);
  if (digitalObjectError) return (<GraphQLErrors errors={digitalObjectError} />);

  const canReorder = digitalObjectAbility.can('edit_objects', {
    primaryProject: digitalObject.primaryProject,
    otherProjects: digitalObject.otherProjects,
  });
  return (
    <DigitalObjectInterface digitalObject={digitalObject}>
      <TabHeading>Manage Child Assets</TabHeading>
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>
            Add New Asset
          </Card.Title>
          <AssetNew parentId={id} refetch={refreshDigitalObject} />
        </Card.Body>
      </Card>
      { canReorder
          && (
          <Card className="mb-3">
            <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
              <Link to={`/digital_objects/${id}/edit_child_structure`}>
                <Button>
                  Reorder Children
                </Button>
              </Link>
            </div>
          </Card>
          )}
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>
            Child Digital Objects
          </Card.Title>
          <Card.Subtitle className="mb-2">{`${structure.length} Total`}</Card.Subtitle>
          <DigitalObjectList digitalObjects={structure} />
        </Card.Body>
      </Card>
    </DigitalObjectInterface>
  );
};

export default Children;

Children.propTypes = {
  id: PropTypes.string.isRequired,
};
