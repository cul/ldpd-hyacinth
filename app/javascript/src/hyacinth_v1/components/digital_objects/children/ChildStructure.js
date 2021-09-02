import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Card } from 'react-bootstrap';
import { useQuery, useMutation } from '@apollo/react-hooks';
import { useHistory } from 'react-router-dom';

import DigitalObjectInterface from '../DigitalObjectInterface';
import TabHeading from '../../shared/tabs/TabHeading';
import { getChildStructureQuery, updateChildStructureMutation } from '../../../graphql/digitalObjects';
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
  const [updateChildStructure, {
    error: updateChildStructureErrors,
  }] = useMutation(
    updateChildStructureMutation,
  );

  const history = useHistory();
  const [childListOrder, setChildListOrder] = useState();
  const onSubmitHandler = async () => {
    const orderedInput = [];
    if (childListOrder) {
      childListOrder.forEach((value, i) => {
        orderedInput.push({ uid: value.id, sortOrder: i });
      });
    }

    const parentUid = id;
    const orderedChildren = orderedInput;

    let historyPromise = () => {};
    const variables = {
      input: {
        parentUid,
        orderedChildren,
      },
    };

    historyPromise = (res) => {
      const path = `/digital_objects/${res.data.updateChildStructure.parent.id}/children`;
      history.push(path);
      return { redirect: path };
    };
    const result = await updateChildStructure({ variables });
    return historyPromise(result);
  };

  if (childStructureLoading) return (<></>);
  if (childStructureError) return (<GraphQLErrors errors={childStructureError} />);
  if (updateChildStructureErrors) return (<GraphQLErrors errors={updateChildStructureErrors} />);

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
