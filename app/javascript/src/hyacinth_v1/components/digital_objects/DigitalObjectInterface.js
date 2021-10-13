import React from 'react';
import { capitalize } from 'lodash';
import PropTypes from 'prop-types';

import Tab from '../shared/tabs/Tab';
import Tabs from '../shared/tabs/Tabs';
import TabBody from '../shared/tabs/TabBody';
import ContextualNavbar from '../shared/ContextualNavbar';
import ResultsPagingBar from '../shared/ResultsPagingBar';
import DigitalObjectSummary from './DigitalObjectSummary';
import { backToSearchPath } from '../../utils/digitalObjectSearchParams';

function DigitalObjectInterface(props) {
  const { digitalObject, children } = props;
  const { id, displayLabel, digitalObjectType } = digitalObject;

  const rightHandLinksArray = [];

  const pathToSearch = backToSearchPath();
  if (pathToSearch) {
    rightHandLinksArray.push({ link: pathToSearch, label: 'Back to Search' });
  }

  return (
    <div className="digital-object-interface">
      <ContextualNavbar
        title={`${capitalize(digitalObjectType)}: ${displayLabel}`}
        rightHandLinks={rightHandLinksArray}
      />

      <DigitalObjectSummary digitalObject={digitalObject} />

      <Tabs>
        <Tab to={`/digital_objects/${id}/system_data`} name="System Data" />
        <Tab to={`/digital_objects/${id}/metadata`} name="Metadata" />
        <Tab to={`/digital_objects/${id}/rights`} name="Rights" />

        {
          (digitalObjectType === 'ITEM') ? (
            <Tab to={`/digital_objects/${id}/children`} name="Manage Child Assets" />
          )
            : <></>
        }

        {
          (digitalObjectType === 'ASSET') ? (
            <>
              <Tab to={`/digital_objects/${id}/parents`} name="Parents" />
              <Tab to={`/digital_objects/${id}/asset_data`} name="Asset Data" />
            </>
          )
            : <></>
        }

        <Tab to={`/digital_objects/${id}/assignments`} name="Assignments" />
        <Tab to={`/digital_objects/${id}/preserve_publish`} name="Preserve/Publish" />
      </Tabs>

      <TabBody>
        {children}
      </TabBody>
      {
        // only show results paging if we came from a search and if there is more than one result
        // and if the current object was in the search result set
        pathToSearch && <ResultsPagingBar uidCurrent={id} />
      }
    </div>
  );
}

export default DigitalObjectInterface;

DigitalObjectInterface.propTypes = {
  digitalObject: PropTypes.objectOf(PropTypes.any).isRequired,
  children: PropTypes.node.isRequired,
};
