import React from 'react';
import { capitalize } from 'lodash';
import PropTypes from 'prop-types';

import Tab from '../shared/tabs/Tab';
import Tabs from '../shared/tabs/Tabs';
import TabBody from '../shared/tabs/TabBody';
import ContextualNavbar from '../shared/ContextualNavbar';
import DigitalObjectSummary from './DigitalObjectSummary';
import { encodeAndStringifySearch } from '../../utils/encodeAndStringifySearch';

function DigitalObjectInterface(props) {
  const { digitalObject, children } = props;
  const { id, title, digitalObjectType } = digitalObject;
  const latestSearchQueryString = sessionStorage.getItem('searchQueryParams');

  const backToSearchPath = () => {
    const latestSearchQuery = JSON.parse(latestSearchQueryString);
    
    // Delete a couple of search parameters that shouldn't appear in a user-facing search url
    delete latestSearchQuery.offset;
    delete latestSearchQuery.totalCount;
    const search = encodeAndStringifySearch(latestSearchQuery);
    return `/digital_objects?${search}`;
  };

  let rightHandLinksArray = [];

  if (latestSearchQueryString) {
    rightHandLinksArray = [{ link: backToSearchPath(), label: 'Back to Search' }];
  }

  return (
    <div className="digital-object-interface">
      <ContextualNavbar
        title={`${capitalize(digitalObjectType)}: ${title}`}
        rightHandLinks={rightHandLinksArray}
      />

      <DigitalObjectSummary digitalObject={digitalObject} />

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
    </div>
  );
}

export default DigitalObjectInterface;

DigitalObjectInterface.propTypes = {
  digitalObject: PropTypes.objectOf(PropTypes.any).isRequired,
  children: PropTypes.node.isRequired,
};
