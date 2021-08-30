import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Card } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';

import DigitalObjectInterface from '../DigitalObjectInterface';
import TabHeading from '../../shared/tabs/TabHeading';
import { getChildStructureQuery } from '../../../graphql/digitalObjects';
import ChildStructureEditor from './ChildStructureEditor';
import GraphQLErrors from '../../shared/GraphQLErrors';
import FormButtons from '../../shared/forms/FormButtons';

const ChildStructure = (props) => {
  const { id } = props;
  const {
    loading: childStructureLoading,
    error: childStructureError,
    data: childStructureData,
  } = useQuery(getChildStructureQuery, {
    variables: { id },
  });

  const [childListOrder, setChildListOrder] = useState();
  const onSubmitHandler = () => {
    // to be implemented.  if childListOrder is undefined, update was clicked but no changes had been made - return as success
    // to be implemented. success returns to manage child assets page
  };

  if (childStructureLoading) return (<></>);
  if (childStructureError) return (<GraphQLErrors errors={childStructureError} />);
  const { childStructure: { parent, structure } } = childStructureData;
  return (
    <DigitalObjectInterface digitalObject={parent}>
      <TabHeading>Edit Child Structure</TabHeading>
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>
            Child Digital Objects
          </Card.Title>
          <Card.Subtitle>{`${structure.length} Total`}</Card.Subtitle>
          <Card className="mb-3">
            <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
              <FormButtons
                formType="edit"
                cancelTo="children"
                onSave={onSubmitHandler}
              />
            </div>
          </Card>

          <ChildStructureEditor digitalObjects={structure} onRearrange={setChildListOrder} />
        </Card.Body>
      </Card>
    </DigitalObjectInterface>
  );
};

export default ChildStructure;

ChildStructure.propTypes = {
  id: PropTypes.string.isRequired,
};
