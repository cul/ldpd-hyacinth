import React from 'react';
import PropTypes from 'prop-types';

import DigitalObjectInterface from '../NewDigitalObjectInterface';
import EditButton from '../../ui/buttons/EditButton';
import TabHeading from '../../ui/tabs/TabHeading';

function MetadataTab(props) {
  const { digitalObject, editButton, children } = props;

  return (
    <DigitalObjectInterface digitalObject={digitalObject}>
      <TabHeading>
        Metadata
        { editButton
          && (
            <EditButton
              className="float-right"
              size="lg"
              link={`/digital_objects/${digitalObject.id}/metadata/edit`}
            />
          )
        }
      </TabHeading>
      { children }
    </DigitalObjectInterface>
  );
}

export default MetadataTab;

MetadataTab.defaultProps = {
  editButton: false,
};

MetadataTab.propTypes = {
  editButton: PropTypes.bool,
  digitalObject: PropTypes.objectOf(PropTypes.any).isRequired,
  children: PropTypes.node.isRequired,
};
