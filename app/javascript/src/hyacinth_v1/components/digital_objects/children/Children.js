import React from 'react';
import PropTypes from 'prop-types';
import { Card } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';

import DigitalObjectInterface from '../DigitalObjectInterface';
import DigitalObjectChildList from './DigitalObjectChildList';
import AssetNew from '../new/AssetNew';
import TabHeading from '../../shared/tabs/TabHeading';
import { getChildStructureQuery } from '../../../graphql/digitalObjects';
import GraphQLErrors from '../../shared/GraphQLErrors';
import FormButtons from '../../shared/forms/FormButtons';

const onRearrange = (newListOrder, setChildListOrder) => {
  setChildListOrder(newListOrder);
};

const Children = (props) => {
  const { id } = props;
  const {
    loading: childStructureLoading,
    error: childStructureError,
    data: childStructureData,
    refetch: refreshChildStructure,
  } = useQuery(getChildStructureQuery, {
    variables: { id },
  });

  const [childListOrder, setChildListOrder] = useState();
  const onSubmitHandler = () => {};

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
          <AssetNew parentId={id} refetch={refreshChildStructure} />
        </Card.Body>
      </Card>

      <Card className="mb-3">
        <Card.Body>
          <Card.Title>
            Child Digital Objects
          </Card.Title>
          <FormButtons
            formType="edit"
            onSave={onSubmitHandler}
          />
          <Card.Subtitle>{`${structure.length} Total`}</Card.Subtitle>
          <DigitalObjectChildList digitalObjects={structure} onRearrange={setChildListOrder} />
        </Card.Body>
      </Card>
    </DigitalObjectInterface>

  );
};

export default Children;

Children.propTypes = {
  id: PropTypes.string.isRequired,
};
