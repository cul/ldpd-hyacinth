import React from 'react';
import PropTypes from 'prop-types';

import DigitalObjectInterface from '../NewDigitalObjectInterface';
import EditButton from '../../ui/buttons/EditButton';
import TabHeading from '../../ui/tabs/TabHeading';

function RightsTab(props) {
  const { digitalObject, editButton, children } = props;

  return (
    <DigitalObjectInterface digitalObject={digitalObject}>
      <TabHeading>
        Rights
        { editButton
          && (
            <EditButton
              className="float-right"
              size="lg"
              link={`/digital_objects/${digitalObject.id}/rights/edit`}
            />
          )
        }
      </TabHeading>
      { children }
    </DigitalObjectInterface>
  );
}

export default RightsTab;

RightsTab.defaultProps = {
  editButton: false,
};

RightsTab.propTypes = {
  editButton: PropTypes.bool,
  digitalObject: PropTypes.objectOf(PropTypes.any).isRequired,
  children: PropTypes.node.isRequired,
};
