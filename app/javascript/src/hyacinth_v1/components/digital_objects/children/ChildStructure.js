import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Card } from 'react-bootstrap';
import { useQuery, useMutation } from '@apollo/react-hooks';
import { useHistory } from 'react-router-dom';

import DigitalObjectInterface from '../DigitalObjectInterface';
import TabHeading from '../../shared/tabs/TabHeading';
import { getChildStructureDigitalObjectQuery, updateChildStructureMutation } from '../../../graphql/digitalObjects';
import ChildStructureEditor from './ChildStructureEditor';
import GraphQLErrors from '../../shared/GraphQLErrors';
import FormButtons from '../../shared/forms/FormButtons';

const ChildStructure = (props) => {
  const { id } = props;
  const {
    loading: digitalObjectLoading,
    error: digitalObjectError,
    data: digitalObjectData,
  } = useQuery(getChildStructureDigitalObjectQuery, {
    variables: { id },
  });
  const [updateChildStructure, {
    error: updateChildStructureErrors,
  }] = useMutation(
    updateChildStructureMutation,
  );

  const history = useHistory();
  const [childListOrder, setChildListOrder] = useState();

  const onSubmitHandler = () => {
    const orderedInput = [];
    if (childListOrder) {
      childListOrder.forEach((value, i) => {
        orderedInput.push({ uid: value.id, sortOrder: i });
      });
    }

    const variables = {
      input: {
        parentUid: id,
        orderedChildren: orderedInput,
      },
    };

    return updateChildStructure({ variables });
  };

  const onSuccessHandler = (res) => {
    const path = `/digital_objects/${res.data.updateChildStructure.parent.id}/children`;
    history.push(path);
  };

  if (digitalObjectLoading) return (<></>);
  if (digitalObjectError) return (<GraphQLErrors errors={digitalObjectError} />);
  if (updateChildStructureErrors) return (<GraphQLErrors errors={updateChildStructureErrors} />);

  const { digitalObject } = digitalObjectData;
  const { childStructure: { structure } } = digitalObject;

  return (
    <DigitalObjectInterface digitalObject={digitalObject}>
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
                onSaveSuccess={onSuccessHandler}
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
