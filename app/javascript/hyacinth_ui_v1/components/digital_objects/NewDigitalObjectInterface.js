import React from 'react';

import Tab from '../ui/tabs/Tab';
import Tabs from '../ui/tabs/Tabs';
import TabBody from '../ui/tabs/TabBody';
import ContextualNavbar from '../layout/ContextualNavbar';
import DigitalObjectSummary from './DigitalObjectSummary';

function DigitalObjectInterface(props) {
  const { minimalDigitalObject, children } = props;
  const { id, digitalObjectType } = minimalDigitalObject;

  return (
    <div className="digital-object-interface">
      <ContextualNavbar
        title={`${capitalize(digitalObjectType)} | ${title}`}
      />

      <DigitalObjectSummary data={minimalDigitalObject} />

      <Tabs>
        <Tab to={`/digital_objects/${id}/system_data`} name="System Data" />
        <Tab to={`/digital_objects/${id}/metadata`} name="Metadata" />
        <Tab to={`/digital_objects/${id}/rights`} name="Rights" />

        {
          (digitalObjectType === 'item') ? (
            <Tab to={`/digital_objects/${id}/children`} name="Manage Child Assets" />
          )
            : <></>
        }

        {
          (digitalObjectType === 'asset') ? (
            <Tab to={`/digital_objects/${id}/parents`} name="Parents" />
          )
            : <></>
        }

        <Tab to={`/digital_objects/${id}/assignment`} name="Assign This" />
        <Tab to={`/digital_objects/${id}/preserve_publish`} name="Preserve/Publish" />
      </Tabs>

      <TabBody>
        {children}
      </TabBody>
    </div>
  );
}

export default DigitalObjectInterface;
