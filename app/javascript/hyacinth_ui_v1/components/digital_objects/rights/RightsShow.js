import React from 'react';

import DigitalObjectInterface from '../NewDigitalObjectInterface';
import EditButton from '../../ui/buttons/EditButton';
import TabHeading from '../../ui/tabs/TabHeading';

function RightsShow(props) {
  const { digitalObject } = props;
  const { id, rights } = digitalObject;
  console.log('rights show got:');
  console.log(digitalObject);
  return (
    <DigitalObjectInterface digitalObject={digitalObject}>
      <TabHeading>
        Rights
        <EditButton
          className="float-right"
          size="lg"
          link={`/digital_objects/${id}/rights/edit`}
        />
        <div className="card">
          <div className="card-body">
            <code>{ JSON.stringify(rights) }</code>
          </div>
        </div>
      </TabHeading>
    </DigitalObjectInterface>
  );
}

export default RightsShow;
