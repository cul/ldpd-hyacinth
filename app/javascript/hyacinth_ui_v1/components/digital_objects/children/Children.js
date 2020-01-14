import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Card } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';

import DigitalObjectInterface from '../DigitalObjectInterface';
import DigitalObjectList from '../DigitalObjectList';
import AssetNew from '../new/AssetNew';
import TabHeading from '../../ui/tabs/TabHeading';
import { getChildStructureQuery } from '../../../graphql/digitalObjects';
import GraphQLErrors from '../../ui/GraphQLErrors';

const Children = (props) => {
  const { id } = props;
  const [inputId] = useState(AssetNew.randomInputId());
  const {
    loading: childStructureLoading,
    error: childStructureError,
    data: childStructureData,
    refetch: refreshChildStructure,
  } = useQuery(getChildStructureQuery, {
    variables: { id },
  });

  if (childStructureLoading) return (<></>);
  if (childStructureError) return (<GraphQLErrors errors={childStructureError} />);
  const { childStructure: { parent, structure } } = childStructureData;
  return (
    <DigitalObjectInterface digitalObject={parent}>
      <TabHeading>Manage Child Assets</TabHeading>
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>
            Add New Asset
          </Card.Title>
          <AssetNew parentId={id} refetch={refreshChildStructure} inputId={inputId} />
        </Card.Body>
      </Card>
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>
            Child Digital Objects
          </Card.Title>
          <Card.Subtitle>{`${structure.length} Total`}</Card.Subtitle>
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
