import React from 'react';
import { capitalize } from 'lodash';
import PropTypes from 'prop-types';
import { useHistory } from 'react-router-dom';

import Tab from '../shared/tabs/Tab';
import Tabs from '../shared/tabs/Tabs';
import TabBody from '../shared/tabs/TabBody';
import ContextualNavbar from '../shared/ContextualNavbar';
import { Button } from 'react-bootstrap';
import DigitalObjectSummary from './DigitalObjectSummary';

function DigitalObjectInterface(props) {
  const { digitalObject, children } = props;
  const { id, title, digitalObjectType } = digitalObject;
  const history = useHistory();
  const latestSearchQueryString = sessionStorage.getItem('latestSearchQueryString');

  const returnToSearchHandler = (event) => {
    event.preventDefault();
    history.push(`/digital_objects?${latestSearchQueryString}`);
  };

  const returnToSearchButton = () => {
    if(latestSearchQueryString)
    return (
          <div>
                <Button
                  onClick={returnToSearchHandler}>
                  Return to Search
                  </Button>
          </div>
    );
  };



  return (
    <div className="digital-object-interface">
      <ContextualNavbar
        title={`${capitalize(digitalObjectType)}: ${title}`}
        children={ returnToSearchButton() }
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
