import React from 'react';
import { Card } from 'react-bootstrap';
import PropTypes from 'prop-types';

import FieldGroupArray from '../fields/FieldGroupArray';
import { defaultAssetRights } from '../defaultRights';

const restrictionOnAccessOptions = [
  { value: 'Public Access', label: 'Public Access' },
  { value: 'On-site Access', label: 'On-site Access' },
  { value: 'Specified Group/UNI Access', label: 'Specified Group/UNI Access' },
  { value: 'Closed', label: 'Closed' },
  { value: 'Embargoed', label: 'Embargoed' },
];

// This is temporary! Eventually we should be able to query for this data from the database.
const dynamicFieldGroupConfig = {
  displayLabel: 'CUL Access Condition',
  stringKey: '',
  isRepeatable: true,
  children: [
    {
      stringKey: 'value',
      displayLabel: 'Access Condition',
      fieldType: 'select',
      selectOptions: JSON.stringify(restrictionOnAccessOptions),
      type: 'DynamicField',
    },
    {
      stringKey: 'location',
      displayLabel: 'Location',
      isRepeatable: true,
      type: 'DynamicFieldGroup',
      children: [
        {
          stringKey: 'term',
          displayLabel: 'Term',
          fieldType: 'controlled_term',
          controlledVocabulary: 'location',
          type: 'DynamicField',
        },
      ],
    },
    {
      stringKey: 'embargoReleaseDate',
      displayLabel: 'Closed/Embargo Release Date',
      fieldType: 'date',
      type: 'DynamicField',
    },
    {
      stringKey: 'affiliation',
      displayLabel: 'Affiliation',
      type: 'DynamicFieldGroup',
      isRepeatable: true,
      children: [
        {
          stringKey: 'value',
          displayLabel: 'Value',
          fieldType: 'string',
          type: 'DynamicField',
        },
      ],
    },
    {
      stringKey: 'note',
      displayLabel: 'Note',
      fieldType: 'textarea',
      type: 'DynamicField',
    },
  ],
};


function AccessCondition(props) {
  const { values, onChange } = props;

  return (
    <Card className="mb-3">
      <Card.Body>
        <Card.Title>CUL Access Condition</Card.Title>

        <FieldGroupArray
          value={values}
          defaultValue={defaultAssetRights.restrictionOnAccess[0]}
          dynamicFieldGroup={dynamicFieldGroupConfig}
          onChange={onChange}
        />

      </Card.Body>
    </Card>
  );
}

AccessCondition.propTypes = {
  onChange: PropTypes.func.isRequired,
  values: PropTypes.arrayOf(PropTypes.any).isRequired,
};

export default AccessCondition;
